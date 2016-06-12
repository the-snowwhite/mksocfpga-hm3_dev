
#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
//#include "hwlib.h"
#include "socal/socal.h"
//#include "socal/hps.h"

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 65536 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

//#define MAX_ADDR 65533 (higher creates no output error)
#define MAX_ADDR 1020
void usage(void);

void usage(void)
{
	printf("adctest: Utility to read or write adc memory locatons by commandline arguments\n Note: the mksocfpga uio0 driver needs to be active\n ");
	printf("To input Hexadecimal Address and / or data values preceed the number with 0x: \n");
	printf("Usage options:\n");
	printf(" -h For this help message.\n");
	printf(" -r For reading an address: [-r <address>] \n");
	printf(" -w For writing an address: [-w <address> <value>] \n");
	exit (8);
}


int main ( int argc, char *argv[] )
{
    void *virtual_base;
    void *h2p_lw_axi_mem_addr=NULL;
    int fd;
	 uint32_t index, inval, value;

//    printf("    mksocfpgamemio: read write hm2 memory locatons by cmmandline arguments  \n");

    // Open /dev/uio0
    if ( ( fd = open ( "/dev/uio0", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
        printf ( "    ERROR: could not open \"/dev/uio0\"...\n" );
        return ( 1 );
    }
//    printf("    /dev/uio0 opened fine OK \n");

    // get virtual addr that maps to physical
    virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, 0);

    if ( virtual_base == MAP_FAILED ) {
        printf ( "    ERROR: mmap() failed...\n" );

        close ( fd );
        return ( 1 );
    }
//    printf("    region mmap'ed  OK \n");

    // Get the base address that maps to the device
    //    assign pointer
    h2p_lw_axi_mem_addr=virtual_base;// + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + HM2REG_IO_0_BASE ) & ( unsigned long)( HW_REGS_MASK ) );

//    printf("    mem pointer created OK\n");

	if(argv[2][0] == '0' && argv[2][1] == 'x') {
		printf("\n\t\tHex address value input found ");
		index = (uint32_t) strtol(argv[2], NULL, 16);
	}
	else {
		printf("\n\t\tDecimal address value input found ");
		index = (uint32_t) strtol(argv[2], NULL, 10);
	}

//    printf("Program name: %s    input option = %c \n", argv[0], argv[1][1]);

	switch (argv[1][1])
	{
		case 'r':
			printf("Read: ");
			value = *((uint32_t *)(h2p_lw_axi_mem_addr + index));
			printf("Address %u \tvalue = 0x%08X \tdecimal = %u \n", index, value, value);
			break;

		case 'w':
			printf("Write: ");
			if(argv[3][0] == '0' && argv[3][1] == 'x') {
				printf("\n\t\tHex data value input found ");
				inval = (uint32_t) strtol(argv[3], NULL, 16);
			}
			else {
				printf("\n\t\tDecimal data value input found ");
				inval = (uint32_t) strtol(argv[3], NULL, 10);
			}
//			uint32_t inval = (uint32_t) atoi(argv[3]);
//			uint32_t oldval = *((uint32_t *)(h2p_lw_axi_mem_addr + index));
			printf("Address %u will be set to \tvalue = 0x%08X \tdecimal = %u \n", index, inval, inval);
			*((uint32_t *)(h2p_lw_axi_mem_addr + index)) = inval;
//			value = *((uint32_t *)(h2p_lw_axi_mem_addr + index));
//			printf("Address %u \tformer val = 0x%08X \t wrote: --> 0x%08X \tdecimal = %u \t read: = 0x%08X \tdecimal = %u \n", index, oldval, inval, inval, value, value);
			break;

		case 'h':
			usage();
			break;

		default:
			printf("Wrong Argument: %s\n", argv[1]);
			usage();
	}
    return (0);
}
