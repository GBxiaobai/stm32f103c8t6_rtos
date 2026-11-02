MEMORY
{
  FLASH : ORIGIN = 0x08000000, LENGTH = 64K
  RAM   : ORIGIN = 0x20000000, LENGTH = 20K
}
SECTIONS
{
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } >FLASH
  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH
  _sidata = LOADADDR(.data);
  .data :
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } >RAM AT> FLASH
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    *( .bss )
    *( .bss* )
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } >RAM

  /* 栈空间：由启动文件的 .stack 段提供（_estack 在栈末尾）
     必须显式放到 RAM，否则会成为孤儿段落在地址 0，
     导致 _estack 指向 flash 别名区、复位后 SP 错误、程序崩溃 */
  .stack (NOLOAD) :
  {
    . = ALIGN(8);
    *(.stack)
    . = ALIGN(8);
  } >RAM

  /* 堆空间：由启动文件的 .heap 段提供 */
  .heap (NOLOAD) :
  {
    . = ALIGN(8);
    *(.heap)
    . = ALIGN(8);
  } >RAM
}
