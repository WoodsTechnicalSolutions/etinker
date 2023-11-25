/* Very basic starting point for a loadable module */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

static int __init simple_module_init(void)
{
	pr_info("%s: loading\n", __func__);

	return 0;
}

static void __exit simple_module_exit(void)
{
	pr_info("%s: unloading\n", __func__);
}

module_init(simple_module_init);
module_exit(simple_module_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Derald D. Woods <woods.technical@gmail.com>");
MODULE_DESCRIPTION("Simple example of a Linux kernel module");
