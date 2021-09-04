.text
.align 2
to_co_temp_5:
  // Control char with one operand: between INK (0x10) and OVER (0x15)
  bl      co_temp_5
  b       to_end
