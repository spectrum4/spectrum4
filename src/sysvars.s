# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.
.global Var1
.global Var2
.global Var3
.global Var4
.global Var5


.section .bss
# ------------------------------------------------------------------------------
# System variables that are initialised with zeros
# ------------------------------------------------------------------------------
Var1:  .space  8
Var2:  .space  8
Var3:  .space  4
Var4:  .space  2


.section .data
# ------------------------------------------------------------------------------
# System variables that are initialised to non-zero values
# ------------------------------------------------------------------------------
Var5:  .long   3
