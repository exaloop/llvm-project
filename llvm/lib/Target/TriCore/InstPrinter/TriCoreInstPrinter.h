//===- TriCoreInstPrinter.h - Convert TriCore MCInst to asm syntax *- C++ -*--//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints a TriCore MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_TRICORE_INSTPRINTER_TRICOREINSTPRINTER_H
#define LLVM_LIB_TARGET_TRICORE_INSTPRINTER_TRICOREINSTPRINTER_H

#include "MCTargetDesc/TriCoreMCTargetDesc.h"
#include "llvm/MC/MCInstPrinter.h"

namespace llvm {
class MCOperand;

class TriCoreInstPrinter : public MCInstPrinter {
public:
  TriCoreInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                     const MCRegisterInfo &MRI)
      : MCInstPrinter(MAI, MII, MRI) {}

  void printInst(const MCInst *MI, uint64_t Address, StringRef Annot,
                 const MCSubtargetInfo &STI, raw_ostream &O) override;
  void printRegName(raw_ostream &O, unsigned RegNo) const override;

  void printOperand(const MCInst *MI, unsigned OpNo, const MCSubtargetInfo &STI,
                    raw_ostream &O, const char *Modifier = nullptr);

  // Autogenerated by tblgen.
  void printInstruction(const MCInst *MI, uint64_t Address,
                        const MCSubtargetInfo &STI, raw_ostream &O);

  static const char *getRegisterName(unsigned RegNo);
};
} // namespace llvm

#endif