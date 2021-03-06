#ifndef _IIC_SLAVE_GPIO_CONFIG_H
#define _IIC_SLAVE_GPIO_CONFIG_H
typedef struct {
	int chip_addr_offset;
	int ngpios;
	int ngpio[2];
} gpio_chip_info_t;

static gpio_chip_info_t gpio_chip_info[] = {
	{
		.chip_addr_offset = OFFSET_AXI_GPIO_LITE_0,
		.ngpios = 1,
		.ngpio = {2, 0},
	},
};

#define GPIOCHIP_MAX (sizeof(gpio_chip_info) / sizeof(gpio_chip_info_t))

#endif//#ifndef _IIC_SLAVE_GPIO_CONFIG_H
