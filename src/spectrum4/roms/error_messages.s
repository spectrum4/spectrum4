.text
.align 2

# -----------------------
# New Error Message Table
# -----------------------

msg_merge_error:                         // L048C
  .asciz "MERGE error"                            // Report 'a'.
msg_wrong_file_type:                     // L0497
  .asciz "Wrong file type"                        // Report 'b'.
msg_code_error:                          // L04A6
  .asciz "CODE error"                             // Report 'c'.
msg_too_many_brackets:                   // L04B0
  .asciz "Too many brackets"                      // Report 'd'.
msg_file_already_exists:                 // L04C1
  .asciz "File already exists"                    // Report 'e'.
msg_invalid_name:                        // L04D4
  .asciz "Invalid name"                           // Report 'f'.
msg_file_does_not_exist:                 // L04E0
  .asciz "File does not exist"                    // Report 'g' & 'h'.
msg_invalid_device:                      // L04F3
  .asciz "Invalid device"                         // Report 'i'.
msg_invalid_baud_rate:                   // L0501
  .asciz "Invalid baud rate"                      // Report 'j'.
msg_invalid_note_name:                   // L0512
  .asciz "Invalid note name"                      // Report 'k'.
msg_number_too_big:                      // L0523
  .asciz "Number too big"                         // Report 'l'.
msg_note_out_of_range:                   // L0531
  .asciz "Note out of range"                      // Report 'm'.
msg_out_of_range:                        // L0542
  .asciz "Out of range"                           // Report 'n'.
msg_too_many_tied_notes:                 // L054E
  .asciz "Too many tied notes"                    // Report 'o'.
msg_bad_parameter:                                // <missing>
  .asciz "Bad parameter"                          // Report 'p'.
msg_copyright:                           // L0561
  .byte 0x7f                                      // '(c)'.
  .asciz " 1986 Sinclair Research Ltd"
