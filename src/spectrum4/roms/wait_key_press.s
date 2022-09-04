.text
.align 2

# ------------------------
# ------------------------
#
# On entry:
# On exit:
wait_key_press:                          // L2653


.if       DEMO_AUTORUN
  bl      demo                                    // Demonstrate features for manual inspection.
.endif
  b       sleep
