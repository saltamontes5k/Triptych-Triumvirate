use DBI;
# JSON.pm here is the 2.x shim and its JSON::XS path emits
#   Bareword "Types::Serialiser::Error::" refers to nonexistent package
# on every zone boot. JSON::PP ships in the same perl and decodes identically.
use JSON::PP;

sub LoadMysql {
    my $config = load_config("eqemu_config.json");
    
    # Attempt to connect using 'content_database'
    my $connect = try_connect($config, "content_database");
    
    # If connection to 'content_database' fails, try 'database'
    if (!$connect) {
        $connect = try_connect($config, "database");
    }

    return $connect;
}

sub LoadMysqlServer {
    my $config = load_config("eqemu_config.json");
    
    # Attempt to connect using 'content_database'
    my $connect = try_connect($config, "database");

    return $connect;
}

sub load_config {
    my $config_file = shift;
    open(my $fh, '<', $config_file) or die "cannot open file $config_file"; {
        local $/;
        $content = <$fh>;
    }
    close($fh);
    return JSON::PP->new->decode($content);
}

sub try_connect {
    my ($config, $label) = @_;
    return unless exists $config->{"server"}{$label};
    
    my $db_config = $config->{"server"}{$label};
    my @required_keys = qw(db host username password);
    return unless all_keys_exist($db_config, @required_keys);

    # A section with no username (this tree's content_database is db/host only) is not a usable
    # connection: DBI falls through to the client default user, MariaDB rejects it, and every call
    # logs "Access denied for user 'ODBC'@'localhost' (using password: NO)" before falling back to
    # the real section. Skip it quietly instead of attempting and warning.
    return unless length $db_config->{username};
    
    # Use the port if it's specified in the config; otherwise, use the default port 3306
    my $port = $db_config->{port} // 3306;
    
    my $dsn = "dbi:mysql:dbname=$db_config->{db};host=$db_config->{host};port=$port";
    my $connect = DBI->connect($dsn, $db_config->{username}, $db_config->{password}, { RaiseError => 0, PrintError => 0 });
    
    return $connect if $connect;
    warn "Connection attempt failed for $label: $DBI::errstr";
    return;
}

sub all_keys_exist {
    my ($hash_ref, @keys) = @_;
    foreach my $key (@keys) {
        return 0 unless defined $hash_ref->{$key};
    }
    return 1;
}
