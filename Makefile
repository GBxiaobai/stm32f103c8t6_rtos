# -------------------------- 配置区，按需修改 --------------------------
TARGET = stm32f103_demo
CHIP = cortex-m3
# 编译器前缀
CROSS_COMPILE ?= arm-none-eabi-

CC      = $(CROSS_COMPILE)gcc
AS      = $(CROSS_COMPILE)as
LD      = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
SIZE    = $(CROSS_COMPILE)size

# 源文件目录
SRC_DIRS  += user
SRC_DIRS  += lib/src
# 汇编启动文件
ASM_FILES += lib/startup/startup_stm32f10x_md.s
# 头文件搜索路径
INC_DIRS  += inc
INC_DIRS  += lib/inc

# 链接脚本路径
LDSCRIPT = lib/link/link.ld

# 编译参数
CFLAGS  = -mcpu=$(CHIP) -mthumb -Wall -O0 -g -DSTM32F10X_MD
CFLAGS += -ffunction-sections -fdata-sections
# 头文件包含
CFLAGS += $(foreach dir, $(INC_DIRS), -I$(dir))

# 汇编参数
ASFLAGS = -mcpu=$(CHIP) -mthumb

# 链接参数
LDFLAGS = -T$(LDSCRIPT) -mcpu=$(CHIP) -mthumb
LDFLAGS += -Wl,--gc-sections

# 中间文件目录
BUILD_DIR = build
# 最终输出目录
OUTPUT_DIR = output

# 自动搜索所有 .c 文件
C_SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
C_OBJS := $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SRCS))
C_DEPS := $(patsubst %.c,$(BUILD_DIR)/%.d,$(C_SRCS))

ASM_OBJS := $(patsubst %.s,$(BUILD_DIR)/%.o,$(ASM_FILES))

OBJS = $(C_OBJS) $(ASM_OBJS)
DEPS = $(C_DEPS)

ELF = $(OUTPUT_DIR)/$(TARGET).elf
BIN = $(OUTPUT_DIR)/$(TARGET).bin
HEX = $(OUTPUT_DIR)/$(TARGET).hex
# ---------------------------------------------------------------------

# 默认目标
all: $(ELF) $(BIN) $(HEX)
	@echo "==== Build Complete ===="
	@$(SIZE) $(ELF)

# 生成ELF
$(ELF): $(OBJS) $(LDSCRIPT) | $(OUTPUT_DIR)
	$(CC) $(OBJS) $(LDFLAGS) -o $@

# 生成bin
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

# 生成hex
$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

# C文件编译规则
$(BUILD_DIR)/%.o : %.c | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

# 汇编文件编译规则
$(BUILD_DIR)/%.o : %.s | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) $< -o $@

# 自动创建目录
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# 清理
clean:
	rm -rf $(BUILD_DIR) $(OUTPUT_DIR)


# ======================== flash烧录目标 ========================
# 注意：本机 OpenOCD 0.12.0 (MacPorts) 的 ST-Link 是 HLA 类驱动，
# 驱动名必须用官方 interface/stlink.cfg，transport 只能是 hla_swd，
# 不能写 "adapter driver stlink; transport select swd"（会报不支持的错误）
OPENOCD ?= openocd
flash:
	$(OPENOCD) -f interface/stlink.cfg -c "transport select hla_swd; adapter speed 1000" \
	-f target/stm32f1x.cfg \
	-c "init; reset halt; flash write_image erase $(ELF); reset run; exit"

# ======================== 新增erase擦除目标 ========================
# 全片擦除：mass_erase 会把整片 64K flash 擦成 0xFF（程序被清空）
# 擦除后芯片为空白状态，上电无任何现象，需要重新 make flash 烧写
erase:
	$(OPENOCD) -f interface/stlink.cfg -c "transport select hla_swd; adapter speed 1000" \
	-f target/stm32f1x.cfg \
	-c "init; reset halt; stm32f1x mass_erase 0; reset run; exit"


# 引入依赖
-include $(DEPS)

.PHONY: all clean flash erase
