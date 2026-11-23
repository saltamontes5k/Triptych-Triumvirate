// Fall of Illsalin monster-mission panel (RoF2 native task journal).
// Included at the end of zone/client_spirit_shroud.cpp so the provider can use the
// file-local Catalog()/Q()/S() helpers. No form entry, session, escrow, or opcode
// allocation lives here: the panel only reads fall_shroud_roles + the shroud
// catalog and writes fall_shroud_choices.
#include "task_client_state.h"
#include "../common/rof2_monster_task_wire.h"
#include "../common/rof2_monster_task_selector.h"
#include "../common/shroud/aa_preview.h"

namespace {

struct FallSelectorView {
    uint32_t task_id = Rof2MonsterTaskSelector::FallOfIllsalin;
    uint64_t occurrence = 0;
    uint32_t character_id = 0;
    bool selection_locked = false;
    std::array<uint32_t, 3> catalogue_opaque_fields{};
    std::array<uint32_t, 2> result_opaque_fields{};
    std::vector<std::shared_ptr<const SpiritShroud::Template>> profiles;
    std::vector<Rof2MonsterTaskWire::Role> roles;
};

// The five roles are content rows; the panel never invents a form. A missing
// table, missing catalog row, or drifted form just hides the panel.
std::vector<std::shared_ptr<const SpiritShroud::Template>> FallPanelProfiles()
{
    std::vector<std::shared_ptr<const SpiritShroud::Template>> profiles;
    auto rows = Q(database, "SELECT class_id,template_id FROM fall_shroud_roles ORDER BY class_id");
    if (rows.RowCount() != 5) return profiles;
    for (auto row : rows) {
        const auto class_id = N(row[0]);
        const auto template_id = N(row[1]);
        if (class_id != 1 && class_id != 2 && class_id != 9 && class_id != 12 && class_id != 14) return {};
        if (!template_id || template_id > UINT32_MAX) return {};
        auto forms = Catalog(uint32_t(template_id), true);
        if (forms.size() != 1) return {};
        const auto &form = forms.front();
        if (form.class_id != class_id || form.race != 467 || form.level != 70 ||
            form.verified || !form.has_native_resources) return {};
        profiles.push_back(std::make_shared<const SpiritShroud::Template>(std::move(forms.front())));
    }
    return profiles;
}

class FallSelectorProvider {
public:
    explicit FallSelectorProvider(Client &client) : client_(client) {}

    std::optional<FallSelectorView> CurrentEligibleView()
    {
        if (client_.ClientVersion() != EQ::versions::ClientVersion::RoF2) return std::nullopt;
        const auto run = client_.GetSharedTaskId();
        const auto *state = client_.GetTaskState();
        if (run <= 0 || !state || state->GetActiveSharedTask().task_id != Rof2MonsterTaskSelector::FallOfIllsalin) {
            return std::nullopt;
        }
        // Match the fork: the panel belongs to Undershore (362) before the instance.
        if (!zone || zone->GetZoneID() != 362 || zone->GetInstanceID() || zone->GetInstanceVersion()) {
            return std::nullopt;
        }
        try {
            FallSelectorView view;
            view.occurrence = static_cast<uint64_t>(run);
            view.character_id = client_.CharacterID();
            view.profiles = FallPanelProfiles();
            if (view.profiles.size() != 5) return std::nullopt;
            for (const auto &profile : view.profiles) {
                view.roles.push_back({profile->id, 0, 0, 0, true, profile->name});
            }
            return view;
        } catch (const std::exception &) {
            return std::nullopt;
        }
    }

    struct Details {
        std::array<uint32_t, 4> prefix;
        std::string text;
    };

    std::optional<Details> GetTemplateDetails(const FallSelectorView &view, uint32_t id)
    {
        const auto profile = std::find_if(view.profiles.begin(), view.profiles.end(),
            [id](const auto &p) { return p->id == id; });
        if (profile == view.profiles.end() || !zone) return std::nullopt;
        try {
            const auto abilities = SpiritShroud::SelectionAbilities(**profile,
                [](uint32_t rank) { return zone->GetAlternateAdvancementRank(rank); });
            const auto bytes = SpiritShroud::Details(**profile, &abilities);
            constexpr std::size_t ordinary_prefix_size = 8;
            if (bytes.size() <= ordinary_prefix_size + 1 || bytes.back() != 0) return std::nullopt;
            return Details{{0, 0, id, 0},
                std::string(bytes.begin() + ordinary_prefix_size, bytes.end() - 1)};
        } catch (const std::exception &) {
            return std::nullopt;
        }
    }

    Rof2MonsterTaskWire::SelectionResult SelectRole(const FallSelectorView &view, uint32_t id)
    {
        using Result = Rof2MonsterTaskWire::SelectionResult;
        if (client_.FallShroudSelectedTemplate(view.occurrence) == id) return Result::AlreadySelected;
        if (!client_.SelectFallShroudRole(view.occurrence, id)) return Result::Ineligible;
        return Result::Selected;
    }

private:
    Client &client_;
};

void SendFallSelectorPacket(Client &client, uint16_t wire, const Rof2MonsterTaskWire::Bytes &body)
{
    using namespace Rof2MonsterTaskWire;
    EmuOpcode opcode;
    switch (wire) {
    case CatalogueOpcode: opcode = OP_FallMonsterCatalogue; break;
    case TemplateDetailsOpcode: opcode = OP_FallMonsterDetails; break;
    case SelectionResultOpcode: opcode = OP_FallMonsterSelectionResult; break;
    default: return;
    }
    EQApplicationPacket packet(opcode, static_cast<uint32_t>(body.size()));
    std::copy(body.begin(), body.end(), packet.pBuffer);
    client.QueuePacket(&packet);
}

} // namespace

void Client::SendFallOfIllsalinCatalogue()
{
    FallSelectorProvider provider(*this);
    Rof2MonsterTaskSelector::SendCatalogue(provider, [&](uint16_t wire, const auto &body) {
        SendFallSelectorPacket(*this, wire, body);
    });
}

void Client::Handle_OP_FallMonsterSelect(const EQApplicationPacket *packet)
{
    if (ClientVersion() != EQ::versions::ClientVersion::RoF2 || !packet) return;
    using namespace Rof2MonsterTaskWire;
    uint16_t wire;
    switch (packet->GetOpcode()) {
    case OP_FallMonsterCatalogue: wire = CatalogueOpcode; break;
    case OP_FallMonsterDetails: wire = TemplateDetailsOpcode; break;
    case OP_FallMonsterSelectRole: wire = SelectRoleOpcode; break;
    default: return;
    }
    FallSelectorProvider provider(*this);
    Rof2MonsterTaskSelector::Dispatch(wire, packet->pBuffer, packet->size, provider,
        [&](uint16_t response, const auto &body) { SendFallSelectorPacket(*this, response, body); });
}

std::optional<uint32_t> Client::FallShroudSelectedTemplate(uint64_t run)
{
    if (!run || GetSharedTaskId() <= 0 || uint64_t(GetSharedTaskId()) != run) return {};
    try {
        auto selected = Q(database, "SELECT template_id FROM fall_shroud_choices WHERE run_id=" + S(run) +
            " AND character_id=" + S(CharacterID()));
        if (selected.RowCount() != 1) return {};
        const auto id = N(selected.begin()[0]);
        if (!id || id > UINT32_MAX) return {};
        return uint32_t(id);
    } catch (const std::exception &) {
        return {};
    }
}

bool Client::SelectFallShroudRole(uint64_t run, uint32_t template_id)
{
    if (!run || !template_id || GetSharedTaskId() <= 0 || uint64_t(GetSharedTaskId()) != run) return false;
    try {
        auto role = Q(database, "SELECT class_id FROM fall_shroud_roles WHERE template_id=" + S(template_id));
        if (role.RowCount() != 1) return false;
        auto member = Q(database, "SELECT run_id FROM fall_shroud_members WHERE run_id=" + S(run) +
            " AND character_id=" + S(CharacterID()) + " AND exited_at IS NULL");
        if (member.RowCount()) return false;
        Q(database, "INSERT INTO fall_shroud_choices(run_id,character_id,template_id,chosen_at) VALUES(" +
            S(run) + "," + S(CharacterID()) + "," + S(template_id) + "," + S(uint64_t(std::time(nullptr))) +
            ") ON DUPLICATE KEY UPDATE template_id=VALUES(template_id),chosen_at=VALUES(chosen_at)");
        return true;
    } catch (const std::exception &) {
        return false;
    }
}
