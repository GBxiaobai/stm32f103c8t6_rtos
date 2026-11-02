#include "test.h"
#include "stm32f10x.h"
#include "stm32f10x_gpio.h"
#include "stm32f10x_rcc.h"

// 简单软件延时
static void Delay_ms(uint32_t ms)
{
    uint32_t i,j;
    for(i = 0; i < ms; i++)
    {
        for(j = 0; j < 7200; j++)
        {
            ;
        }
    }
}

// PC13板载LED闪烁函数
void LED_Blink_Test(void)
{
    GPIO_InitTypeDef GPIO_InitStruct;
    // 开启GPIOC外设时钟
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);

    // PC13 推挽输出，50MHz
    GPIO_InitStruct.GPIO_Pin = GPIO_Pin_13;
    GPIO_InitStruct.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOC, &GPIO_InitStruct);

    while(1)
    {
        GPIO_ResetBits(GPIOC, GPIO_Pin_13);  // PC13拉低，LED点亮
        Delay_ms(500);
        GPIO_SetBits(GPIOC, GPIO_Pin_13);     // PC13拉高，LED熄灭
        Delay_ms(500);
    }
}
