#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/string.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("sharkmoos");
MODULE_DESCRIPTION("A contrived kmod of no obvious use");

static int hello_proc_show(struct seq_file *m, void *v)
{
	return 0;
}

static ssize_t proc_write(struct file* file,const char __user *buffer,size_t count,loff_t *f_pos)
{
	return 0
}

static int proc_open(struct inode *inode, struct  file *file) {
  return single_open(file, hello_proc_show, NULL);
}

static const struct proc_ops hello_proc_fops = {
	.proc_open 		= proc_open,
	.proc_read 		= seq_read,
	.proc_write 	= proc_write,
	.proc_lseek 	= seq_lseek,
	.proc_release 	= single_release,
};

static int __init proc_init(void) 
{
  proc_create("chall", 0777, NULL, &hello_proc_fops);
  return 0;
}

static void __exit proc_exit(void) 
{
  remove_proc_entry("chall", NULL);
}

module_init(proc_init);
module_exit(proc_exit); 