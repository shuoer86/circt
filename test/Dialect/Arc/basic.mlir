// RUN: circt-opt %s --verify-diagnostics | circt-opt | FileCheck %s

// CHECK-LABEL: arc.define @Foo
arc.define @Foo(%arg0: i42, %arg1: i9) -> (i42, i9) {
  %c-1_i42 = hw.constant -1 : i42

  // CHECK: arc.output %c-1_i42, %arg1 : i42, i9
  arc.output %c-1_i42, %arg1 : i42, i9
}

arc.define @Bar(%arg0: i42) -> i42 {
  arc.output %arg0 : i42
}

// CHECK-LABEL: hw.module @Module
hw.module @Module(%clock: i1, %enable: i1, %a: i42, %b: i9) {
  // CHECK: arc.state @Foo(%a, %b) clock %clock lat 1 : (i42, i9) -> (i42, i9)
  arc.state @Foo(%a, %b) clock %clock lat 1 : (i42, i9) -> (i42, i9)

  // CHECK: arc.state @Foo(%a, %b) clock %clock enable %enable lat 1 : (i42, i9) -> (i42, i9)
  arc.state @Foo(%a, %b) clock %clock enable %enable lat 1 : (i42, i9) -> (i42, i9)
}

// CHECK-LABEL: arc.define @SupportRecurisveMemoryEffects
arc.define @SupportRecurisveMemoryEffects(%arg0: i42, %arg1: i1) {
  %0 = scf.if %arg1 -> i42 {
    %1 = comb.and %arg0, %arg0 : i42
    scf.yield %1 : i42
  } else {
    scf.yield %arg0 : i42
  }
  arc.output
}