# fuzzy_extractor
A synthesizable SystemVerilog fuzzy extractor that turns noisy Physical Unclonable Function responses into a stable 128 bit cryptographic key. It combines a repetition code and a BCH(255,139,15) code offset construction for error correction with Ascon-XOF128 (NIST SP 800-232) for key derivation.

## Context
This design was developed as part of the M.Sc. Microelectronics and Chip Design at the Technical University of Munich (TUM), in the Research Laboratory Functional Design of Integrated Digital Circuits Summer Semester 2026. The lab is built around the Didactic-SoC, a RISC-V (Ibex) teaching SoC on which each student group integrates its own subsystem for tape-out.

### My role
I designed and verified the complete fuzzy extractor datapath in this repository:
- the BCH(255,139,15) encoder and decoder (syndrome, Berlekamp-Massey, Chien search, failure detection) and the GF(2⁸) arithmetic package
- the repetition (15,1) encoder and decoder
- the Ascon-XOF128 key-derivation core
- the fuzzy_top integration: enrollment and reconstruction flows, PUF stream interface and helper-data storage interface

## How it works
- Enrollment (once): read the PUF, compute public helper data and store it in non-volatile memory, derive the key.
- Reconstruction (every boot): read the PUF again (now with bit errors), use the helper data to correct the errors, and derive the same key.

Stage 1: repetition code. Each 60-bit PUF word is split into four 15-bit chunks. Each chunk yields one secret bit and 14 helper bits. During reconstruction, a majority vote over the 14 helper differences corrects up to 7 bit errors per chunk. 64 PUF words give 256 bits, of which 255 feed the next stage.

Stage 2: BCH code-offset. The first 139 bits are the secret. During enrollment, the BCH encoder computes 116 parity bits and stores them XORed with the remaining PUF-derived bits. During reconstruction, the decoder corrects up to 15 residual bit errors in the 255-bit word. If the decoder detects an uncorrectable pattern (the number of roots found does not match the error-locator degree), it raises error_o and no key is released.

Stage 3: key derivation. The corrected 139-bit secret is hashed with Ascon-XOF128 into the final 128-bit key.

## Architecture

| Module | Function |
|---|---|
| `fuzzy_top` | Enrollment/reconstruction FSM, PUF and NVM interfaces |
| `repetition_encoder` / `repetition_decoder` | (15,1) repetition code, majority vote |
| `bch_encoder` | Systematic encoder, LFSR division by g(x) |
| `bch_decoder` | Syndrome → Berlekamp-Massey → Chien → bit flip |
| `bch_syndrome` | 30 syndromes via Horner's method, early exit if all zero |
| `bch_bm` | Berlekamp-Massey, two-phase iteration |
| `bch_chien` | Chien search over all 255 positions |
| `ascon_xof128_hardcoded` | Ascon-XOF128, 139-bit input → 128-bit output |
| `ascon_round` | One Ascon permutation round (reused 12×) |
| `gf_math_pkg` | GF(2⁸) multiply/inverse via log/antilog tables |

## Verification

In the original project, the design was verified with:
- **Python reference models** of the BCH encoder/decoder
- **cocotb** and **UVM** testbenches, including Ascon known answer tests
- an **FPGA prototype** (PYNQ-Z1) running the full PUF → fuzzy extractor → AES-GCM → SPI flash chain


