
#define SYSTEM_RAM_LOW		1
#define SYSTEM_RAM_HIGH     2
#define MEM_RESERVEI        3
#define PCI_IO              4
#define PCI_MEM             5
#define LOONGSON_CFG_REG    6
#define VIDEO_ROM           7
#define DAPTER_ROM          8
#define ACPI_TABLE          9
#define SMBIOS_TABLE        10
#define MAX_MEMORY_TYPE     11


#define BOOT_MEM_MAP_MAX 128
struct efi_memory_map_loongson{
	u16 vers;                             /*version of efi_memory_map*/
	u32 nr_map;                           /*number of memory_maps*/
	u32 mem_freq;                         /*memory frequence*/
	struct mem_map{
		u32 node_id;                      /*recorde the node_id*/	
		u32 mem_type;                     /*recorde the memory type*/	
		u64 mem_start;                    /*memory map start address*/
		u32 mem_size;                     /*for each memory_map size,not the total size*/
	}map[BOOT_MEM_MAP_MAX];
}__attribute__((packed));

enum loongson_cpu_type
{
	Loongson_2F,Loongson_2E, Loongson_3A, Loongson_3B,Loongson_1A,Loongson_1B,loongson_2H
};

/* Capability and feature descriptor structure for MIPS CPU */
struct efi_cpuinfo_loongson {
	u16 vers;                             /*version of efi_cpuinfo_loongson*/
	u32 processor_id;                     //6505, 6506-3b prid
	enum loongson_cpu_type  cputype;      //3a-3b
	u32 total_node;                       /* physical core number */
	u32 cpu_startup_core_id;              /* Core id: */
	u32 cpu_clock_freq;                   //cpu_clock 
	u32 nr_cpus;
}__attribute__((packed));


struct system_loongson{
	u16 vers;                             /*version of system_loongson*/
	u32 ccnuma_smp;                       // 0:no numa; 1: has numa
	u32 sing_double_channel;              // 1:single; 2:double
}__attribute__((packed));

struct irq_source_routing_table {
	u16 vers;
	u16 size;
	u16 bus,devfn; 
	u32 vendor,device, PIC_type;          //conform use HT or PCI to route to CPU-PIC

	u64 ht_int_bit;                       //3a: 1<<24; 3b:1<<16
	u64 ht_enable;                        //irqs used in this PIC.eg:3a-0x0000d17a
	u32 node_id;                          // node id, 0x0 -0, 0x1-1; 0x10-2；0x11-3；0x100-4

	u64 pci_mem_start_addr;
	u64 pci_mem_end_addr;
	u64 pci_io_start_addr;
	u64 pci_io_end_addr;
	u64 pci_config_addr;

}__attribute__((packed));


struct interface_info{
	u16 vers;                             /*version of the specificition*/
	u16 size;                             /**/
	u8 flag;                              /**/
	char description[64];                 /**/
}__attribute__((packed));


#define MAX_RESOUCR_NUMBER 128
struct resource_loongson {
	u64 start;                            /*resource start address*/
	u64 end;                              /*resource end address*/
	char name[64];
	unsigned int flags;
};

struct archdev_data {};                   /*arch specific additions*/

struct board_devices{
	char name[64];                        /*hold the device name*/
	u32 num_resources;                    /*number of device_resource*/
	struct resource_loongson resource[MAX_RESOUCR_NUMBER];
	                                      /*for each device`s resource*/
	struct archdev_data archdata;         /*arch specific additions*/
};

struct loongson_special_attribute{
	u16 vers;                             /*version of this special*/
	char special_name[64];                /*special_atribute_name*/
	unsigned int loongson_special_type;   /*tyoe of special device*/
    struct resource_loongson resource[MAX_RESOUCR_NUMBER];
	                                      /*special_vlaue resource*/
};

struct loongson_params{
	u64	memory_offset;                    /*efi_memory_map_loongson struct offset*/ 
	u64 cpu_offset;                       /*efi_cpuinfo_loongson struct offset*/
	u64 system_offset;                    /*system_info struct offset*/
	u64 irq_offset;                       /*irq_source_routing_table struct offset*/
	u64 interface_offset;                 /*interface_info struct offset*/
	u64 special_offset;                   /*loongson_special_attribute struct offset*/
	u64 boarddev_table_offset;            /*board_device offset*/
};

struct smbios_tables {
	u16 vers;                             /*version of smbios*/
	unsigned long long vga_bios;          /*vga_bios address*/
	struct loongson_params lp;
};

struct efi {
	unsigned long long  mps;              /* MPS table */
	unsigned long long  acpi;             /* ACPI table  (IA64 ext 0.71) */
	unsigned long long acpi20;            /* ACPI table  (ACPI 2.0) */
	struct smbios_tables smbios;          /* SM BIOS table */
	unsigned long long sal_systab;        /* SAL system table */
	unsigned long long boot_info;         /* boot info table */
};

struct efi_reset_system_t
{
	unsigned long long  ResetCold;
	unsigned long long  ResetWarm;
	unsigned long long  ResetType;
	unsigned long long  Shutdown;
};

struct boot_params{
	struct efi efi;
	struct efi_reset_system_t reset_system;
};

