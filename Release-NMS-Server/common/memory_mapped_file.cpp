/*	EQEMu: Everquest Server Emulator
	Copyright (C) 2001-2013 EQEMu Development Team (http://eqemulator.net)

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; version 2 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY except by those people which sell it, which
	are required to give you total support for your newly bought product;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR
	A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#include "memory_mapped_file.h"
#ifdef _WINDOWS
#include <windows.h>
#else
#include <sys/types.h>
#include <sys/mman.h>
#include <err.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#endif
#include "eqemu_exception.h"
#ifdef FREEBSD
#include <sys/stat.h>
#endif

#include <filesystem>
namespace fs = std::filesystem;

namespace EQ {

	struct MemoryMappedFile::Implementation {
#ifdef _WINDOWS
		HANDLE mapped_object_;
#else
		int fd_;
#endif
	};

	MemoryMappedFile::MemoryMappedFile(std::string filename, uint32 size)
		: filename_(filename), size_(size) {
		imp_ = new Implementation;

#ifdef _WINDOWS
		DWORD total_size = size + sizeof(shared_memory_struct);
		HANDLE file = CreateFile(filename.c_str(),
			GENERIC_READ | GENERIC_WRITE,
			FILE_SHARE_READ | FILE_SHARE_WRITE,
			nullptr,
			OPEN_ALWAYS,
			0,
			nullptr);

		if(file == INVALID_HANDLE_VALUE) {
			EQ_EXCEPT("Shared Memory", "Could not open a file for this shared memory segment.");
		}

		imp_->mapped_object_ = CreateFileMapping(file,
			nullptr,
			PAGE_READWRITE,
			0,
			total_size,
			filename.c_str());

		if(!imp_->mapped_object_) {
			EQ_EXCEPT("Shared Memory", "Could not create a file mapping for this shared memory file.");
		}

		memory_ = reinterpret_cast<shared_memory_struct*>(MapViewOfFile(imp_->mapped_object_,
			FILE_MAP_ALL_ACCESS,
			0,
			0,
			total_size));

		if(!memory_) {
			EQ_EXCEPT("Shared Memory", "Could not map a view of the shared memory file.");
		}

#else
		size_t total_size = size + sizeof(shared_memory_struct);
		imp_->fd_ = open(filename.c_str(), O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
		if(imp_->fd_ == -1) {
			EQ_EXCEPT("Shared Memory", "Could not open a file for this shared memory segment.");
		}

		if(ftruncate(imp_->fd_, total_size) == -1) {
			EQ_EXCEPT("Shared Memory", "Could not set file size for this shared memory segment.");
		}

		memory_ = reinterpret_cast<shared_memory_struct*>(
			mmap(nullptr, total_size, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, imp_->fd_, 0));

		if(memory_ == MAP_FAILED) {
			EQ_EXCEPT("Shared Memory", "Could not create a file mapping for this shared memory file.");
		}
#endif
	}

	MemoryMappedFile::MemoryMappedFile(std::string filename)
		: filename_(filename) {
		imp_ = new Implementation;

		//get existing size
		FILE *f = fopen(filename.c_str(), "rb");
		if(!f) {
			EQ_EXCEPT("Shared Memory", "Could not open the file to find the existing file size.");
		}

		// ftell's long is 32-bit on Windows: on a segment larger than 2 GiB it
		// returns -1, and the cast below then yields 0xFFFFFFFF, so the file
		// mapping was created at the 4 GiB ceiling. The item segment is ~3.2 GiB
		// (its size is sizeof(ItemData) * 0xFFFFFFF mod 2^32), which meant the
		// first zone to open it silently padded the file from 3.2 GiB to
		// 4 GiB - the tail was never written, so the valid data length stayed at
		// 3.2 GiB. Read the size with 64-bit positioning and reject anything the
		// uint32 segment arithmetic cannot represent.
#ifdef _WINDOWS
		fseek(f, 0, SEEK_END);
		const long long file_size = _ftelli64(f);
#else
		fseeko(f, 0, SEEK_END);
		const long long file_size = static_cast<long long>(ftello(f));
#endif
		fclose(f);

		if (file_size < static_cast<long long>(sizeof(shared_memory_struct))) {
			EQ_EXCEPT("Shared Memory", "Shared memory file is smaller than its header.");
		}

		if (file_size > 0xFFFFFFFFLL) {
			EQ_EXCEPT("Shared Memory", "Shared memory file is larger than 4 GiB.");
		}

		const uint32 size = static_cast<uint32>(file_size) - sizeof(shared_memory_struct);
		size_ = size;

#ifdef _WINDOWS
		DWORD total_size = size + sizeof(shared_memory_struct);
		HANDLE file = CreateFile(filename.c_str(),
			GENERIC_READ | GENERIC_WRITE,
			FILE_SHARE_READ | FILE_SHARE_WRITE,
			nullptr,
			OPEN_ALWAYS,
			0,
			nullptr);

		if(file == INVALID_HANDLE_VALUE) {
			EQ_EXCEPT("Shared Memory", "Could not open a file for this shared memory segment.");
		}

		imp_->mapped_object_ = CreateFileMapping(file,
			nullptr,
			PAGE_READWRITE,
			0,
			total_size,
			filename.c_str());

		if(!imp_->mapped_object_) {
			EQ_EXCEPT("Shared Memory", "Could not create a file mapping for this shared memory file.");
		}

		memory_ = reinterpret_cast<shared_memory_struct*>(MapViewOfFile(imp_->mapped_object_,
			FILE_MAP_ALL_ACCESS,
			0,
			0,
			total_size));

		if(!memory_) {
			EQ_EXCEPT("Shared Memory", "Could not map a view of the shared memory file.");
		}

#else
		size_t total_size = size + sizeof(shared_memory_struct);
		imp_->fd_ = open(filename.c_str(), O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
		if(imp_->fd_ == -1) {
			EQ_EXCEPT("Shared Memory", "Could not open a file for this shared memory segment.");
		}

		if(ftruncate(imp_->fd_, total_size) == -1) {
			EQ_EXCEPT("Shared Memory", "Could not set file size for this shared memory segment.");
		}

		memory_ = reinterpret_cast<shared_memory_struct*>(
			mmap(nullptr, total_size, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, imp_->fd_, 0));

		if(memory_ == MAP_FAILED) {
			EQ_EXCEPT("Shared Memory", "Could not create a file mapping for this shared memory file.");
		}
#endif
	}

	MemoryMappedFile::~MemoryMappedFile() {
#ifdef _WINDOWS
		if(imp_->mapped_object_) {
			CloseHandle(imp_->mapped_object_);
		}
#else
		if(memory_) {
			size_t total_size = size_ + sizeof(shared_memory_struct);
			munmap(reinterpret_cast<void*>(memory_), total_size);
			close(imp_->fd_);
		}
#endif
		delete imp_;
	}

	void MemoryMappedFile::ZeroFile() {
		memset(reinterpret_cast<void*>(memory_), 0, sizeof(shared_memory_struct));
		memset(memory_->data, 0, size_);
		memory_->size = size_;
	}
} // EQEmu
