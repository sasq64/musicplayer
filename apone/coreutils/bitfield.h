#ifndef UTILS_BITFIELD_H
#define UTILS_BITFIELD_H

#include <vector>
#include <cstdint>
#include <cstring>
#include <coreutils/log.h>

class BitField {
	struct BitRef {
		BitRef(BitField &bf, int pos) : bf(bf), pos(pos) {}
		BitRef& operator=(bool b) { bf.set(pos, b); return *this; }
		operator int() { return bf.get(pos) ? 1 : 0; }
		operator bool() { return bf.get(pos); }
		BitField &bf;
		int pos;
	};
public:

		typedef std::vector<uint64_t> storage_type;

		BitField(int size=0) : bitsize(size), bits((size+63)/64) {
			if(size)
				memset(&bits[0], 0, bits.size()*8);
		};

		BitField(const storage_type &bits) : bitsize(bits.size()*64), bits(bits) {
		};

		void grow(int pos) {
			if(pos > bitsize)
				bitsize = pos;
			int sz = (pos+63)/64;
			int size = bits.size();
			if(sz > size) {
				bits.resize(sz);
				memset(&bits[size], 0, sz-size);
			}
		}

		void set(uint8_t *ptr, int size) {
			bits.resize((size+63)/64);
			bitsize = size;
			memcpy(&bits[0], ptr, bits.size()*8);
		};

		std::vector<uint64_t>& get_vector() {
			return bits;
		}

		const void *get() {
			return &bits[0];
		};

		int size() { return bitsize; }

		void set(int pos, bool value) {
			grow(pos+1);
			if(value)
				bits[pos>>6] |= (1<<(pos&0x3f));
			else
				bits[pos>>6] &= ~(1<<(pos&0x3f));
		}
		bool get(int pos) const {
			if(pos >= bitsize)
				return false;
			return (bits[pos>>6] & (1<<(pos&0x3f))) != 0;
		}

		int first_bit_clr(uint64_t x) {
			return __builtin_ctzl(~x);
		}

		int first_bit_set(uint64_t x) {
			return __builtin_ctzl(x);
		}

		int lowest_set() {
			grow(1);
			int j = 0;
			for(uint64_t i : bits) {
				LOGD("%x", i);
				if(i) {
					int o = first_bit_set(i);
					return j/64+o;
				}
				j++;
			}
			return -1;
		}

		int lowest_unset() {
			grow(1);
			int j = 0;
			for(uint64_t i : bits) {
				LOGD("U %x", i);
				if(i != 0xffffffffffffffffL) {
					int o = first_bit_clr(i);
					LOGD("Bit %d", o);
					int rc = j/64+o;
					if(rc >= bitsize)
						return -1;
					return rc;
				}
				j++;
			}
			return -1;
		}

		BitRef operator[](int pos) { return BitRef(*this, pos); }


private:
	int bitsize;
	storage_type bits;
};



#endif // UTILS_BITFIELD_H