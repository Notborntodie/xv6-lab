
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	17010113          	addi	sp,sp,368 # 80009170 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	fe070713          	addi	a4,a4,-32 # 80009030 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	b4e78793          	addi	a5,a5,-1202 # 80005bb0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	ee278793          	addi	a5,a5,-286 # 80000f8e <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  timerinit();
    800000d6:	00000097          	auipc	ra,0x0
    800000da:	f46080e7          	jalr	-186(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000de:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e6:	30200073          	mret
}
    800000ea:	60a2                	ld	ra,8(sp)
    800000ec:	6402                	ld	s0,0(sp)
    800000ee:	0141                	addi	sp,sp,16
    800000f0:	8082                	ret

00000000800000f2 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f2:	715d                	addi	sp,sp,-80
    800000f4:	e486                	sd	ra,72(sp)
    800000f6:	e0a2                	sd	s0,64(sp)
    800000f8:	fc26                	sd	s1,56(sp)
    800000fa:	f84a                	sd	s2,48(sp)
    800000fc:	f44e                	sd	s3,40(sp)
    800000fe:	f052                	sd	s4,32(sp)
    80000100:	ec56                	sd	s5,24(sp)
    80000102:	0880                	addi	s0,sp,80
    80000104:	8a2a                	mv	s4,a0
    80000106:	84ae                	mv	s1,a1
    80000108:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    8000010a:	00011517          	auipc	a0,0x11
    8000010e:	06650513          	addi	a0,a0,102 # 80011170 <cons>
    80000112:	00001097          	auipc	ra,0x1
    80000116:	bd4080e7          	jalr	-1068(ra) # 80000ce6 <acquire>
  for(i = 0; i < n; i++){
    8000011a:	05305c63          	blez	s3,80000172 <consolewrite+0x80>
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	3d8080e7          	jalr	984(ra) # 80002504 <either_copyin>
    80000134:	01550d63          	beq	a0,s5,8000014e <consolewrite+0x5c>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	796080e7          	jalr	1942(ra) # 800008d2 <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x30>
    8000014c:	894e                	mv	s2,s3
  }
  release(&cons.lock);
    8000014e:	00011517          	auipc	a0,0x11
    80000152:	02250513          	addi	a0,a0,34 # 80011170 <cons>
    80000156:	00001097          	auipc	ra,0x1
    8000015a:	c44080e7          	jalr	-956(ra) # 80000d9a <release>

  return i;
}
    8000015e:	854a                	mv	a0,s2
    80000160:	60a6                	ld	ra,72(sp)
    80000162:	6406                	ld	s0,64(sp)
    80000164:	74e2                	ld	s1,56(sp)
    80000166:	7942                	ld	s2,48(sp)
    80000168:	79a2                	ld	s3,40(sp)
    8000016a:	7a02                	ld	s4,32(sp)
    8000016c:	6ae2                	ld	s5,24(sp)
    8000016e:	6161                	addi	sp,sp,80
    80000170:	8082                	ret
  for(i = 0; i < n; i++){
    80000172:	4901                	li	s2,0
    80000174:	bfe9                	j	8000014e <consolewrite+0x5c>

0000000080000176 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f456                	sd	s5,40(sp)
    80000186:	f05a                	sd	s6,32(sp)
    80000188:	ec5e                	sd	s7,24(sp)
    8000018a:	1080                	addi	s0,sp,96
    8000018c:	8aaa                	mv	s5,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	fda50513          	addi	a0,a0,-38 # 80011170 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	b48080e7          	jalr	-1208(ra) # 80000ce6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	fca48493          	addi	s1,s1,-54 # 80011170 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	00011917          	auipc	s2,0x11
    800001b2:	05a90913          	addi	s2,s2,90 # 80011208 <cons+0x98>
  while(n > 0){
    800001b6:	07305f63          	blez	s3,80000234 <consoleread+0xbe>
    while(cons.r == cons.w){
    800001ba:	0984a783          	lw	a5,152(s1)
    800001be:	09c4a703          	lw	a4,156(s1)
    800001c2:	02f71463          	bne	a4,a5,800001ea <consoleread+0x74>
      if(myproc()->killed){
    800001c6:	00002097          	auipc	ra,0x2
    800001ca:	878080e7          	jalr	-1928(ra) # 80001a3e <myproc>
    800001ce:	591c                	lw	a5,48(a0)
    800001d0:	efad                	bnez	a5,8000024a <consoleread+0xd4>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	07e080e7          	jalr	126(ra) # 80002254 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fef700e3          	beq	a4,a5,800001c6 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];
    800001ea:	00011717          	auipc	a4,0x11
    800001ee:	f8670713          	addi	a4,a4,-122 # 80011170 <cons>
    800001f2:	0017869b          	addiw	a3,a5,1
    800001f6:	08d72c23          	sw	a3,152(a4)
    800001fa:	07f7f693          	andi	a3,a5,127
    800001fe:	9736                	add	a4,a4,a3
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000208:	4691                	li	a3,4
    8000020a:	06db8463          	beq	s7,a3,80000272 <consoleread+0xfc>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020e:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000212:	4685                	li	a3,1
    80000214:	faf40613          	addi	a2,s0,-81
    80000218:	85d2                	mv	a1,s4
    8000021a:	8556                	mv	a0,s5
    8000021c:	00002097          	auipc	ra,0x2
    80000220:	292080e7          	jalr	658(ra) # 800024ae <either_copyout>
    80000224:	57fd                	li	a5,-1
    80000226:	00f50763          	beq	a0,a5,80000234 <consoleread+0xbe>
      break;

    dst++;
    8000022a:	0a05                	addi	s4,s4,1
    --n;
    8000022c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000022e:	47a9                	li	a5,10
    80000230:	f8fb93e3          	bne	s7,a5,800001b6 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000234:	00011517          	auipc	a0,0x11
    80000238:	f3c50513          	addi	a0,a0,-196 # 80011170 <cons>
    8000023c:	00001097          	auipc	ra,0x1
    80000240:	b5e080e7          	jalr	-1186(ra) # 80000d9a <release>

  return target - n;
    80000244:	413b053b          	subw	a0,s6,s3
    80000248:	a811                	j	8000025c <consoleread+0xe6>
        release(&cons.lock);
    8000024a:	00011517          	auipc	a0,0x11
    8000024e:	f2650513          	addi	a0,a0,-218 # 80011170 <cons>
    80000252:	00001097          	auipc	ra,0x1
    80000256:	b48080e7          	jalr	-1208(ra) # 80000d9a <release>
        return -1;
    8000025a:	557d                	li	a0,-1
}
    8000025c:	60e6                	ld	ra,88(sp)
    8000025e:	6446                	ld	s0,80(sp)
    80000260:	64a6                	ld	s1,72(sp)
    80000262:	6906                	ld	s2,64(sp)
    80000264:	79e2                	ld	s3,56(sp)
    80000266:	7a42                	ld	s4,48(sp)
    80000268:	7aa2                	ld	s5,40(sp)
    8000026a:	7b02                	ld	s6,32(sp)
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	6125                	addi	sp,sp,96
    80000270:	8082                	ret
      if(n < target){
    80000272:	0009871b          	sext.w	a4,s3
    80000276:	fb677fe3          	bgeu	a4,s6,80000234 <consoleread+0xbe>
        cons.r--;
    8000027a:	00011717          	auipc	a4,0x11
    8000027e:	f8f72723          	sw	a5,-114(a4) # 80011208 <cons+0x98>
    80000282:	bf4d                	j	80000234 <consoleread+0xbe>

0000000080000284 <consputc>:
{
    80000284:	1141                	addi	sp,sp,-16
    80000286:	e406                	sd	ra,8(sp)
    80000288:	e022                	sd	s0,0(sp)
    8000028a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028c:	10000793          	li	a5,256
    80000290:	00f50a63          	beq	a0,a5,800002a4 <consputc+0x20>
    uartputc_sync(c);
    80000294:	00000097          	auipc	ra,0x0
    80000298:	560080e7          	jalr	1376(ra) # 800007f4 <uartputc_sync>
}
    8000029c:	60a2                	ld	ra,8(sp)
    8000029e:	6402                	ld	s0,0(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a4:	4521                	li	a0,8
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	54e080e7          	jalr	1358(ra) # 800007f4 <uartputc_sync>
    800002ae:	02000513          	li	a0,32
    800002b2:	00000097          	auipc	ra,0x0
    800002b6:	542080e7          	jalr	1346(ra) # 800007f4 <uartputc_sync>
    800002ba:	4521                	li	a0,8
    800002bc:	00000097          	auipc	ra,0x0
    800002c0:	538080e7          	jalr	1336(ra) # 800007f4 <uartputc_sync>
    800002c4:	bfe1                	j	8000029c <consputc+0x18>

00000000800002c6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c6:	1101                	addi	sp,sp,-32
    800002c8:	ec06                	sd	ra,24(sp)
    800002ca:	e822                	sd	s0,16(sp)
    800002cc:	e426                	sd	s1,8(sp)
    800002ce:	e04a                	sd	s2,0(sp)
    800002d0:	1000                	addi	s0,sp,32
    800002d2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d4:	00011517          	auipc	a0,0x11
    800002d8:	e9c50513          	addi	a0,a0,-356 # 80011170 <cons>
    800002dc:	00001097          	auipc	ra,0x1
    800002e0:	a0a080e7          	jalr	-1526(ra) # 80000ce6 <acquire>

  switch(c){
    800002e4:	47d5                	li	a5,21
    800002e6:	0af48663          	beq	s1,a5,80000392 <consoleintr+0xcc>
    800002ea:	0297ca63          	blt	a5,s1,8000031e <consoleintr+0x58>
    800002ee:	47a1                	li	a5,8
    800002f0:	0ef48763          	beq	s1,a5,800003de <consoleintr+0x118>
    800002f4:	47c1                	li	a5,16
    800002f6:	10f49a63          	bne	s1,a5,8000040a <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fa:	00002097          	auipc	ra,0x2
    800002fe:	260080e7          	jalr	608(ra) # 8000255a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000302:	00011517          	auipc	a0,0x11
    80000306:	e6e50513          	addi	a0,a0,-402 # 80011170 <cons>
    8000030a:	00001097          	auipc	ra,0x1
    8000030e:	a90080e7          	jalr	-1392(ra) # 80000d9a <release>
}
    80000312:	60e2                	ld	ra,24(sp)
    80000314:	6442                	ld	s0,16(sp)
    80000316:	64a2                	ld	s1,8(sp)
    80000318:	6902                	ld	s2,0(sp)
    8000031a:	6105                	addi	sp,sp,32
    8000031c:	8082                	ret
  switch(c){
    8000031e:	07f00793          	li	a5,127
    80000322:	0af48e63          	beq	s1,a5,800003de <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000326:	00011717          	auipc	a4,0x11
    8000032a:	e4a70713          	addi	a4,a4,-438 # 80011170 <cons>
    8000032e:	0a072783          	lw	a5,160(a4)
    80000332:	09872703          	lw	a4,152(a4)
    80000336:	9f99                	subw	a5,a5,a4
    80000338:	07f00713          	li	a4,127
    8000033c:	fcf763e3          	bltu	a4,a5,80000302 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000340:	47b5                	li	a5,13
    80000342:	0cf48763          	beq	s1,a5,80000410 <consoleintr+0x14a>
      consputc(c);
    80000346:	8526                	mv	a0,s1
    80000348:	00000097          	auipc	ra,0x0
    8000034c:	f3c080e7          	jalr	-196(ra) # 80000284 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000350:	00011797          	auipc	a5,0x11
    80000354:	e2078793          	addi	a5,a5,-480 # 80011170 <cons>
    80000358:	0a07a703          	lw	a4,160(a5)
    8000035c:	0017069b          	addiw	a3,a4,1
    80000360:	0006861b          	sext.w	a2,a3
    80000364:	0ad7a023          	sw	a3,160(a5)
    80000368:	07f77713          	andi	a4,a4,127
    8000036c:	97ba                	add	a5,a5,a4
    8000036e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000372:	47a9                	li	a5,10
    80000374:	0cf48563          	beq	s1,a5,8000043e <consoleintr+0x178>
    80000378:	4791                	li	a5,4
    8000037a:	0cf48263          	beq	s1,a5,8000043e <consoleintr+0x178>
    8000037e:	00011797          	auipc	a5,0x11
    80000382:	e8a7a783          	lw	a5,-374(a5) # 80011208 <cons+0x98>
    80000386:	0807879b          	addiw	a5,a5,128
    8000038a:	f6f61ce3          	bne	a2,a5,80000302 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000038e:	863e                	mv	a2,a5
    80000390:	a07d                	j	8000043e <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000392:	00011717          	auipc	a4,0x11
    80000396:	dde70713          	addi	a4,a4,-546 # 80011170 <cons>
    8000039a:	0a072783          	lw	a5,160(a4)
    8000039e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	00011497          	auipc	s1,0x11
    800003a6:	dce48493          	addi	s1,s1,-562 # 80011170 <cons>
    while(cons.e != cons.w &&
    800003aa:	4929                	li	s2,10
    800003ac:	f4f70be3          	beq	a4,a5,80000302 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b0:	37fd                	addiw	a5,a5,-1
    800003b2:	07f7f713          	andi	a4,a5,127
    800003b6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b8:	01874703          	lbu	a4,24(a4)
    800003bc:	f52703e3          	beq	a4,s2,80000302 <consoleintr+0x3c>
      cons.e--;
    800003c0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c4:	10000513          	li	a0,256
    800003c8:	00000097          	auipc	ra,0x0
    800003cc:	ebc080e7          	jalr	-324(ra) # 80000284 <consputc>
    while(cons.e != cons.w &&
    800003d0:	0a04a783          	lw	a5,160(s1)
    800003d4:	09c4a703          	lw	a4,156(s1)
    800003d8:	fcf71ce3          	bne	a4,a5,800003b0 <consoleintr+0xea>
    800003dc:	b71d                	j	80000302 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003de:	00011717          	auipc	a4,0x11
    800003e2:	d9270713          	addi	a4,a4,-622 # 80011170 <cons>
    800003e6:	0a072783          	lw	a5,160(a4)
    800003ea:	09c72703          	lw	a4,156(a4)
    800003ee:	f0f70ae3          	beq	a4,a5,80000302 <consoleintr+0x3c>
      cons.e--;
    800003f2:	37fd                	addiw	a5,a5,-1
    800003f4:	00011717          	auipc	a4,0x11
    800003f8:	e0f72e23          	sw	a5,-484(a4) # 80011210 <cons+0xa0>
      consputc(BACKSPACE);
    800003fc:	10000513          	li	a0,256
    80000400:	00000097          	auipc	ra,0x0
    80000404:	e84080e7          	jalr	-380(ra) # 80000284 <consputc>
    80000408:	bded                	j	80000302 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040a:	ee048ce3          	beqz	s1,80000302 <consoleintr+0x3c>
    8000040e:	bf21                	j	80000326 <consoleintr+0x60>
      consputc(c);
    80000410:	4529                	li	a0,10
    80000412:	00000097          	auipc	ra,0x0
    80000416:	e72080e7          	jalr	-398(ra) # 80000284 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041a:	00011797          	auipc	a5,0x11
    8000041e:	d5678793          	addi	a5,a5,-682 # 80011170 <cons>
    80000422:	0a07a703          	lw	a4,160(a5)
    80000426:	0017069b          	addiw	a3,a4,1
    8000042a:	0006861b          	sext.w	a2,a3
    8000042e:	0ad7a023          	sw	a3,160(a5)
    80000432:	07f77713          	andi	a4,a4,127
    80000436:	97ba                	add	a5,a5,a4
    80000438:	4729                	li	a4,10
    8000043a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043e:	00011797          	auipc	a5,0x11
    80000442:	dcc7a723          	sw	a2,-562(a5) # 8001120c <cons+0x9c>
        wakeup(&cons.r);
    80000446:	00011517          	auipc	a0,0x11
    8000044a:	dc250513          	addi	a0,a0,-574 # 80011208 <cons+0x98>
    8000044e:	00002097          	auipc	ra,0x2
    80000452:	f86080e7          	jalr	-122(ra) # 800023d4 <wakeup>
    80000456:	b575                	j	80000302 <consoleintr+0x3c>

0000000080000458 <consoleinit>:

void
consoleinit(void)
{
    80000458:	1141                	addi	sp,sp,-16
    8000045a:	e406                	sd	ra,8(sp)
    8000045c:	e022                	sd	s0,0(sp)
    8000045e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000460:	00008597          	auipc	a1,0x8
    80000464:	bb058593          	addi	a1,a1,-1104 # 80008010 <etext+0x10>
    80000468:	00011517          	auipc	a0,0x11
    8000046c:	d0850513          	addi	a0,a0,-760 # 80011170 <cons>
    80000470:	00000097          	auipc	ra,0x0
    80000474:	7e6080e7          	jalr	2022(ra) # 80000c56 <initlock>

  uartinit();
    80000478:	00000097          	auipc	ra,0x0
    8000047c:	32c080e7          	jalr	812(ra) # 800007a4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000480:	00021797          	auipc	a5,0x21
    80000484:	e7078793          	addi	a5,a5,-400 # 800212f0 <devsw>
    80000488:	00000717          	auipc	a4,0x0
    8000048c:	cee70713          	addi	a4,a4,-786 # 80000176 <consoleread>
    80000490:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000492:	00000717          	auipc	a4,0x0
    80000496:	c6070713          	addi	a4,a4,-928 # 800000f2 <consolewrite>
    8000049a:	ef98                	sd	a4,24(a5)
}
    8000049c:	60a2                	ld	ra,8(sp)
    8000049e:	6402                	ld	s0,0(sp)
    800004a0:	0141                	addi	sp,sp,16
    800004a2:	8082                	ret

00000000800004a4 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a4:	7179                	addi	sp,sp,-48
    800004a6:	f406                	sd	ra,40(sp)
    800004a8:	f022                	sd	s0,32(sp)
    800004aa:	ec26                	sd	s1,24(sp)
    800004ac:	e84a                	sd	s2,16(sp)
    800004ae:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b0:	c219                	beqz	a2,800004b6 <printint+0x12>
    800004b2:	08054763          	bltz	a0,80000540 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004b6:	2501                	sext.w	a0,a0
    800004b8:	4881                	li	a7,0
    800004ba:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004be:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c0:	2581                	sext.w	a1,a1
    800004c2:	00008617          	auipc	a2,0x8
    800004c6:	b7e60613          	addi	a2,a2,-1154 # 80008040 <digits>
    800004ca:	883a                	mv	a6,a4
    800004cc:	2705                	addiw	a4,a4,1
    800004ce:	02b577bb          	remuw	a5,a0,a1
    800004d2:	1782                	slli	a5,a5,0x20
    800004d4:	9381                	srli	a5,a5,0x20
    800004d6:	97b2                	add	a5,a5,a2
    800004d8:	0007c783          	lbu	a5,0(a5)
    800004dc:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e0:	0005079b          	sext.w	a5,a0
    800004e4:	02b5553b          	divuw	a0,a0,a1
    800004e8:	0685                	addi	a3,a3,1
    800004ea:	feb7f0e3          	bgeu	a5,a1,800004ca <printint+0x26>

  if(sign)
    800004ee:	00088c63          	beqz	a7,80000506 <printint+0x62>
    buf[i++] = '-';
    800004f2:	fe070793          	addi	a5,a4,-32
    800004f6:	00878733          	add	a4,a5,s0
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x90>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d5e080e7          	jalr	-674(ra) # 80000284 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7e>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf95                	j	800004ba <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	cc07ae23          	sw	zero,-804(a5) # 80011230 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	abc50513          	addi	a0,a0,-1348 # 80008018 <etext+0x18>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5250513          	addi	a0,a0,-1198 # 800080c8 <digits+0x88>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	c6cdad83          	lw	s11,-916(s11) # 80011230 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	14050f63          	beqz	a0,8000073e <printf+0x1ac>
    800005e4:	4981                	li	s3,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b93          	li	s7,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00008b17          	auipc	s6,0x8
    800005f4:	a50b0b13          	addi	s6,s6,-1456 # 80008040 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	c1650513          	addi	a0,a0,-1002 # 80011218 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	6dc080e7          	jalr	1756(ra) # 80000ce6 <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	a1450513          	addi	a0,a0,-1516 # 80008028 <etext+0x28>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	c60080e7          	jalr	-928(ra) # 80000284 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2985                	addiw	s3,s3,1
    8000062e:	013a07b3          	add	a5,s4,s3
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050463          	beqz	a0,8000073e <printf+0x1ac>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2985                	addiw	s3,s3,1
    80000640:	013a07b3          	add	a5,s4,s3
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000064c:	cbed                	beqz	a5,8000073e <printf+0x1ac>
    switch(c){
    8000064e:	05778a63          	beq	a5,s7,800006a2 <printf+0x110>
    80000652:	02fbf663          	bgeu	s7,a5,8000067e <printf+0xec>
    80000656:	09978863          	beq	a5,s9,800006e6 <printf+0x154>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79563          	bne	a5,a4,80000728 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e30080e7          	jalr	-464(ra) # 800004a4 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	09578f63          	beq	a5,s5,8000071c <printf+0x18a>
    80000682:	0b879363          	bne	a5,s8,80000728 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0c080e7          	jalr	-500(ra) # 800004a4 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bce080e7          	jalr	-1074(ra) # 80000284 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	bc2080e7          	jalr	-1086(ra) # 80000284 <consputc>
    800006ca:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c95793          	srli	a5,s2,0x3c
    800006d0:	97da                	add	a5,a5,s6
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	bae080e7          	jalr	-1106(ra) # 80000284 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0912                	slli	s2,s2,0x4
    800006e0:	34fd                	addiw	s1,s1,-1
    800006e2:	f4ed                	bnez	s1,800006cc <printf+0x13a>
    800006e4:	b7a1                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e6:	f8843783          	ld	a5,-120(s0)
    800006ea:	00878713          	addi	a4,a5,8
    800006ee:	f8e43423          	sd	a4,-120(s0)
    800006f2:	6384                	ld	s1,0(a5)
    800006f4:	cc89                	beqz	s1,8000070e <printf+0x17c>
      for(; *s; s++)
    800006f6:	0004c503          	lbu	a0,0(s1)
    800006fa:	d90d                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    800006fc:	00000097          	auipc	ra,0x0
    80000700:	b88080e7          	jalr	-1144(ra) # 80000284 <consputc>
      for(; *s; s++)
    80000704:	0485                	addi	s1,s1,1
    80000706:	0004c503          	lbu	a0,0(s1)
    8000070a:	f96d                	bnez	a0,800006fc <printf+0x16a>
    8000070c:	b705                	j	8000062c <printf+0x9a>
        s = "(null)";
    8000070e:	00008497          	auipc	s1,0x8
    80000712:	91248493          	addi	s1,s1,-1774 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000716:	02800513          	li	a0,40
    8000071a:	b7cd                	j	800006fc <printf+0x16a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b66080e7          	jalr	-1178(ra) # 80000284 <consputc>
      break;
    80000726:	b719                	j	8000062c <printf+0x9a>
      consputc('%');
    80000728:	8556                	mv	a0,s5
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b5a080e7          	jalr	-1190(ra) # 80000284 <consputc>
      consputc(c);
    80000732:	8526                	mv	a0,s1
    80000734:	00000097          	auipc	ra,0x0
    80000738:	b50080e7          	jalr	-1200(ra) # 80000284 <consputc>
      break;
    8000073c:	bdc5                	j	8000062c <printf+0x9a>
  if(locking)
    8000073e:	020d9163          	bnez	s11,80000760 <printf+0x1ce>
}
    80000742:	70e6                	ld	ra,120(sp)
    80000744:	7446                	ld	s0,112(sp)
    80000746:	74a6                	ld	s1,104(sp)
    80000748:	7906                	ld	s2,96(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7ca2                	ld	s9,40(sp)
    80000758:	7d02                	ld	s10,32(sp)
    8000075a:	6de2                	ld	s11,24(sp)
    8000075c:	6129                	addi	sp,sp,192
    8000075e:	8082                	ret
    release(&pr.lock);
    80000760:	00011517          	auipc	a0,0x11
    80000764:	ab850513          	addi	a0,a0,-1352 # 80011218 <pr>
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	632080e7          	jalr	1586(ra) # 80000d9a <release>
}
    80000770:	bfc9                	j	80000742 <printf+0x1b0>

0000000080000772 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000772:	1101                	addi	sp,sp,-32
    80000774:	ec06                	sd	ra,24(sp)
    80000776:	e822                	sd	s0,16(sp)
    80000778:	e426                	sd	s1,8(sp)
    8000077a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077c:	00011497          	auipc	s1,0x11
    80000780:	a9c48493          	addi	s1,s1,-1380 # 80011218 <pr>
    80000784:	00008597          	auipc	a1,0x8
    80000788:	8b458593          	addi	a1,a1,-1868 # 80008038 <etext+0x38>
    8000078c:	8526                	mv	a0,s1
    8000078e:	00000097          	auipc	ra,0x0
    80000792:	4c8080e7          	jalr	1224(ra) # 80000c56 <initlock>
  pr.locking = 1;
    80000796:	4785                	li	a5,1
    80000798:	cc9c                	sw	a5,24(s1)
}
    8000079a:	60e2                	ld	ra,24(sp)
    8000079c:	6442                	ld	s0,16(sp)
    8000079e:	64a2                	ld	s1,8(sp)
    800007a0:	6105                	addi	sp,sp,32
    800007a2:	8082                	ret

00000000800007a4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a4:	1141                	addi	sp,sp,-16
    800007a6:	e406                	sd	ra,8(sp)
    800007a8:	e022                	sd	s0,0(sp)
    800007aa:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ac:	100007b7          	lui	a5,0x10000
    800007b0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b4:	f8000713          	li	a4,-128
    800007b8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007bc:	470d                	li	a4,3
    800007be:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c2:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c6:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ca:	469d                	li	a3,7
    800007cc:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d0:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d4:	00008597          	auipc	a1,0x8
    800007d8:	88458593          	addi	a1,a1,-1916 # 80008058 <digits+0x18>
    800007dc:	00011517          	auipc	a0,0x11
    800007e0:	a5c50513          	addi	a0,a0,-1444 # 80011238 <uart_tx_lock>
    800007e4:	00000097          	auipc	ra,0x0
    800007e8:	472080e7          	jalr	1138(ra) # 80000c56 <initlock>
}
    800007ec:	60a2                	ld	ra,8(sp)
    800007ee:	6402                	ld	s0,0(sp)
    800007f0:	0141                	addi	sp,sp,16
    800007f2:	8082                	ret

00000000800007f4 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f4:	1101                	addi	sp,sp,-32
    800007f6:	ec06                	sd	ra,24(sp)
    800007f8:	e822                	sd	s0,16(sp)
    800007fa:	e426                	sd	s1,8(sp)
    800007fc:	1000                	addi	s0,sp,32
    800007fe:	84aa                	mv	s1,a0
  push_off();
    80000800:	00000097          	auipc	ra,0x0
    80000804:	49a080e7          	jalr	1178(ra) # 80000c9a <push_off>

  if(panicked){
    80000808:	00008797          	auipc	a5,0x8
    8000080c:	7f87a783          	lw	a5,2040(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	10000737          	lui	a4,0x10000
  if(panicked){
    80000814:	c391                	beqz	a5,80000818 <uartputc_sync+0x24>
    for(;;)
    80000816:	a001                	j	80000816 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000818:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081c:	0207f793          	andi	a5,a5,32
    80000820:	dfe5                	beqz	a5,80000818 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000822:	0ff4f513          	zext.b	a0,s1
    80000826:	100007b7          	lui	a5,0x10000
    8000082a:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	50c080e7          	jalr	1292(ra) # 80000d3a <pop_off>
}
    80000836:	60e2                	ld	ra,24(sp)
    80000838:	6442                	ld	s0,16(sp)
    8000083a:	64a2                	ld	s1,8(sp)
    8000083c:	6105                	addi	sp,sp,32
    8000083e:	8082                	ret

0000000080000840 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000840:	00008797          	auipc	a5,0x8
    80000844:	7cc7a783          	lw	a5,1996(a5) # 8000900c <uart_tx_r>
    80000848:	00008717          	auipc	a4,0x8
    8000084c:	7c872703          	lw	a4,1992(a4) # 80009010 <uart_tx_w>
    80000850:	08f70063          	beq	a4,a5,800008d0 <uartstart+0x90>
{
    80000854:	7139                	addi	sp,sp,-64
    80000856:	fc06                	sd	ra,56(sp)
    80000858:	f822                	sd	s0,48(sp)
    8000085a:	f426                	sd	s1,40(sp)
    8000085c:	f04a                	sd	s2,32(sp)
    8000085e:	ec4e                	sd	s3,24(sp)
    80000860:	e852                	sd	s4,16(sp)
    80000862:	e456                	sd	s5,8(sp)
    80000864:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000866:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    8000086a:	00011a97          	auipc	s5,0x11
    8000086e:	9cea8a93          	addi	s5,s5,-1586 # 80011238 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000872:	00008497          	auipc	s1,0x8
    80000876:	79a48493          	addi	s1,s1,1946 # 8000900c <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008a17          	auipc	s4,0x8
    8000087e:	796a0a13          	addi	s4,s4,1942 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000882:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000886:	02077713          	andi	a4,a4,32
    8000088a:	cb15                	beqz	a4,800008be <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    8000088c:	00fa8733          	add	a4,s5,a5
    80000890:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000894:	2785                	addiw	a5,a5,1
    80000896:	41f7d71b          	sraiw	a4,a5,0x1f
    8000089a:	01b7571b          	srliw	a4,a4,0x1b
    8000089e:	9fb9                	addw	a5,a5,a4
    800008a0:	8bfd                	andi	a5,a5,31
    800008a2:	9f99                	subw	a5,a5,a4
    800008a4:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a6:	8526                	mv	a0,s1
    800008a8:	00002097          	auipc	ra,0x2
    800008ac:	b2c080e7          	jalr	-1236(ra) # 800023d4 <wakeup>
    
    WriteReg(THR, c);
    800008b0:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b4:	409c                	lw	a5,0(s1)
    800008b6:	000a2703          	lw	a4,0(s4)
    800008ba:	fcf714e3          	bne	a4,a5,80000882 <uartstart+0x42>
  }
}
    800008be:	70e2                	ld	ra,56(sp)
    800008c0:	7442                	ld	s0,48(sp)
    800008c2:	74a2                	ld	s1,40(sp)
    800008c4:	7902                	ld	s2,32(sp)
    800008c6:	69e2                	ld	s3,24(sp)
    800008c8:	6a42                	ld	s4,16(sp)
    800008ca:	6aa2                	ld	s5,8(sp)
    800008cc:	6121                	addi	sp,sp,64
    800008ce:	8082                	ret
    800008d0:	8082                	ret

00000000800008d2 <uartputc>:
{
    800008d2:	7179                	addi	sp,sp,-48
    800008d4:	f406                	sd	ra,40(sp)
    800008d6:	f022                	sd	s0,32(sp)
    800008d8:	ec26                	sd	s1,24(sp)
    800008da:	e84a                	sd	s2,16(sp)
    800008dc:	e44e                	sd	s3,8(sp)
    800008de:	e052                	sd	s4,0(sp)
    800008e0:	1800                	addi	s0,sp,48
    800008e2:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    800008e4:	00011517          	auipc	a0,0x11
    800008e8:	95450513          	addi	a0,a0,-1708 # 80011238 <uart_tx_lock>
    800008ec:	00000097          	auipc	ra,0x0
    800008f0:	3fa080e7          	jalr	1018(ra) # 80000ce6 <acquire>
  if(panicked){
    800008f4:	00008797          	auipc	a5,0x8
    800008f8:	70c7a783          	lw	a5,1804(a5) # 80009000 <panicked>
    800008fc:	c391                	beqz	a5,80000900 <uartputc+0x2e>
    for(;;)
    800008fe:	a001                	j	800008fe <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000900:	00008697          	auipc	a3,0x8
    80000904:	7106a683          	lw	a3,1808(a3) # 80009010 <uart_tx_w>
    80000908:	0016879b          	addiw	a5,a3,1
    8000090c:	41f7d71b          	sraiw	a4,a5,0x1f
    80000910:	01b7571b          	srliw	a4,a4,0x1b
    80000914:	9fb9                	addw	a5,a5,a4
    80000916:	8bfd                	andi	a5,a5,31
    80000918:	9f99                	subw	a5,a5,a4
    8000091a:	00008717          	auipc	a4,0x8
    8000091e:	6f272703          	lw	a4,1778(a4) # 8000900c <uart_tx_r>
    80000922:	04f71363          	bne	a4,a5,80000968 <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000926:	00011a17          	auipc	s4,0x11
    8000092a:	912a0a13          	addi	s4,s4,-1774 # 80011238 <uart_tx_lock>
    8000092e:	00008917          	auipc	s2,0x8
    80000932:	6de90913          	addi	s2,s2,1758 # 8000900c <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000936:	00008997          	auipc	s3,0x8
    8000093a:	6da98993          	addi	s3,s3,1754 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000093e:	85d2                	mv	a1,s4
    80000940:	854a                	mv	a0,s2
    80000942:	00002097          	auipc	ra,0x2
    80000946:	912080e7          	jalr	-1774(ra) # 80002254 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000094a:	0009a683          	lw	a3,0(s3)
    8000094e:	0016879b          	addiw	a5,a3,1
    80000952:	41f7d71b          	sraiw	a4,a5,0x1f
    80000956:	01b7571b          	srliw	a4,a4,0x1b
    8000095a:	9fb9                	addw	a5,a5,a4
    8000095c:	8bfd                	andi	a5,a5,31
    8000095e:	9f99                	subw	a5,a5,a4
    80000960:	00092703          	lw	a4,0(s2)
    80000964:	fcf70de3          	beq	a4,a5,8000093e <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000968:	00011917          	auipc	s2,0x11
    8000096c:	8d090913          	addi	s2,s2,-1840 # 80011238 <uart_tx_lock>
    80000970:	96ca                	add	a3,a3,s2
    80000972:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000976:	00008717          	auipc	a4,0x8
    8000097a:	68f72d23          	sw	a5,1690(a4) # 80009010 <uart_tx_w>
      uartstart();
    8000097e:	00000097          	auipc	ra,0x0
    80000982:	ec2080e7          	jalr	-318(ra) # 80000840 <uartstart>
      release(&uart_tx_lock);
    80000986:	854a                	mv	a0,s2
    80000988:	00000097          	auipc	ra,0x0
    8000098c:	412080e7          	jalr	1042(ra) # 80000d9a <release>
}
    80000990:	70a2                	ld	ra,40(sp)
    80000992:	7402                	ld	s0,32(sp)
    80000994:	64e2                	ld	s1,24(sp)
    80000996:	6942                	ld	s2,16(sp)
    80000998:	69a2                	ld	s3,8(sp)
    8000099a:	6a02                	ld	s4,0(sp)
    8000099c:	6145                	addi	sp,sp,48
    8000099e:	8082                	ret

00000000800009a0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009a0:	1141                	addi	sp,sp,-16
    800009a2:	e422                	sd	s0,8(sp)
    800009a4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009a6:	100007b7          	lui	a5,0x10000
    800009aa:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ae:	8b85                	andi	a5,a5,1
    800009b0:	cb81                	beqz	a5,800009c0 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    800009b2:	100007b7          	lui	a5,0x10000
    800009b6:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009ba:	6422                	ld	s0,8(sp)
    800009bc:	0141                	addi	sp,sp,16
    800009be:	8082                	ret
    return -1;
    800009c0:	557d                	li	a0,-1
    800009c2:	bfe5                	j	800009ba <uartgetc+0x1a>

00000000800009c4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009c4:	1101                	addi	sp,sp,-32
    800009c6:	ec06                	sd	ra,24(sp)
    800009c8:	e822                	sd	s0,16(sp)
    800009ca:	e426                	sd	s1,8(sp)
    800009cc:	1000                	addi	s0,sp,32
  acquire(&uart_tx_lock);
    800009ce:	00011517          	auipc	a0,0x11
    800009d2:	86a50513          	addi	a0,a0,-1942 # 80011238 <uart_tx_lock>
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	310080e7          	jalr	784(ra) # 80000ce6 <acquire>
  if (ReadReg(LSR)&LSR_TX_IDLE){
    800009de:	100007b7          	lui	a5,0x10000
    800009e2:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e6:	0207f793          	andi	a5,a5,32
    800009ea:	eb99                	bnez	a5,80000a00 <uartintr+0x3c>
    tx_done=1;
    wakeup(&tx_chan);//wakeup the sending thread
  }
  release(&uart_tx_lock);
    800009ec:	00011517          	auipc	a0,0x11
    800009f0:	84c50513          	addi	a0,a0,-1972 # 80011238 <uart_tx_lock>
    800009f4:	00000097          	auipc	ra,0x0
    800009f8:	3a6080e7          	jalr	934(ra) # 80000d9a <release>
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009fc:	54fd                	li	s1,-1
    800009fe:	a01d                	j	80000a24 <uartintr+0x60>
    tx_done=1;
    80000a00:	4785                	li	a5,1
    80000a02:	00008717          	auipc	a4,0x8
    80000a06:	60f72323          	sw	a5,1542(a4) # 80009008 <tx_done>
    wakeup(&tx_chan);//wakeup the sending thread
    80000a0a:	00008517          	auipc	a0,0x8
    80000a0e:	5fa50513          	addi	a0,a0,1530 # 80009004 <tx_chan>
    80000a12:	00002097          	auipc	ra,0x2
    80000a16:	9c2080e7          	jalr	-1598(ra) # 800023d4 <wakeup>
    80000a1a:	bfc9                	j	800009ec <uartintr+0x28>
      break;
    consoleintr(c);
    80000a1c:	00000097          	auipc	ra,0x0
    80000a20:	8aa080e7          	jalr	-1878(ra) # 800002c6 <consoleintr>
    int c = uartgetc();
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	f7c080e7          	jalr	-132(ra) # 800009a0 <uartgetc>
    if(c == -1)
    80000a2c:	fe9518e3          	bne	a0,s1,80000a1c <uartintr+0x58>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a30:	00011497          	auipc	s1,0x11
    80000a34:	80848493          	addi	s1,s1,-2040 # 80011238 <uart_tx_lock>
    80000a38:	8526                	mv	a0,s1
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	2ac080e7          	jalr	684(ra) # 80000ce6 <acquire>
  uartstart();
    80000a42:	00000097          	auipc	ra,0x0
    80000a46:	dfe080e7          	jalr	-514(ra) # 80000840 <uartstart>
  release(&uart_tx_lock);
    80000a4a:	8526                	mv	a0,s1
    80000a4c:	00000097          	auipc	ra,0x0
    80000a50:	34e080e7          	jalr	846(ra) # 80000d9a <release>
}
    80000a54:	60e2                	ld	ra,24(sp)
    80000a56:	6442                	ld	s0,16(sp)
    80000a58:	64a2                	ld	s1,8(sp)
    80000a5a:	6105                	addi	sp,sp,32
    80000a5c:	8082                	ret

0000000080000a5e <uartwrite>:





void uartwrite(char buf[],int n){
    80000a5e:	7139                	addi	sp,sp,-64
    80000a60:	fc06                	sd	ra,56(sp)
    80000a62:	f822                	sd	s0,48(sp)
    80000a64:	f426                	sd	s1,40(sp)
    80000a66:	f04a                	sd	s2,32(sp)
    80000a68:	ec4e                	sd	s3,24(sp)
    80000a6a:	e852                	sd	s4,16(sp)
    80000a6c:	e456                	sd	s5,8(sp)
    80000a6e:	e05a                	sd	s6,0(sp)
    80000a70:	0080                	addi	s0,sp,64
    80000a72:	8aaa                	mv	s5,a0
    80000a74:	84ae                	mv	s1,a1
  acquire(&uart_tx_lock);
    80000a76:	00010517          	auipc	a0,0x10
    80000a7a:	7c250513          	addi	a0,a0,1986 # 80011238 <uart_tx_lock>
    80000a7e:	00000097          	auipc	ra,0x0
    80000a82:	268080e7          	jalr	616(ra) # 80000ce6 <acquire>
  int i=0;
  while (i<n)
    80000a86:	04905763          	blez	s1,80000ad4 <uartwrite+0x76>
    80000a8a:	8a56                	mv	s4,s5
    80000a8c:	9aa6                	add	s5,s5,s1
  {
    while (tx_done==0)
    80000a8e:	00008497          	auipc	s1,0x8
    80000a92:	57a48493          	addi	s1,s1,1402 # 80009008 <tx_done>
    {
      sleep(&tx_chan,&uart_tx_lock);
    80000a96:	00010997          	auipc	s3,0x10
    80000a9a:	7a298993          	addi	s3,s3,1954 # 80011238 <uart_tx_lock>
    80000a9e:	00008917          	auipc	s2,0x8
    80000aa2:	56690913          	addi	s2,s2,1382 # 80009004 <tx_chan>
    }
    WriteReg(THR,buf[i]);
    80000aa6:	10000b37          	lui	s6,0x10000
    80000aaa:	a015                	j	80000ace <uartwrite+0x70>
      sleep(&tx_chan,&uart_tx_lock);
    80000aac:	85ce                	mv	a1,s3
    80000aae:	854a                	mv	a0,s2
    80000ab0:	00001097          	auipc	ra,0x1
    80000ab4:	7a4080e7          	jalr	1956(ra) # 80002254 <sleep>
    while (tx_done==0)
    80000ab8:	409c                	lw	a5,0(s1)
    80000aba:	dbed                	beqz	a5,80000aac <uartwrite+0x4e>
    WriteReg(THR,buf[i]);
    80000abc:	000a4783          	lbu	a5,0(s4)
    80000ac0:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
    i+=1;
    tx_done=0;
    80000ac4:	0004a023          	sw	zero,0(s1)
  while (i<n)
    80000ac8:	0a05                	addi	s4,s4,1
    80000aca:	015a0563          	beq	s4,s5,80000ad4 <uartwrite+0x76>
    while (tx_done==0)
    80000ace:	409c                	lw	a5,0(s1)
    80000ad0:	dff1                	beqz	a5,80000aac <uartwrite+0x4e>
    80000ad2:	b7ed                	j	80000abc <uartwrite+0x5e>
  }
  release(&uart_tx_lock);
    80000ad4:	00010517          	auipc	a0,0x10
    80000ad8:	76450513          	addi	a0,a0,1892 # 80011238 <uart_tx_lock>
    80000adc:	00000097          	auipc	ra,0x0
    80000ae0:	2be080e7          	jalr	702(ra) # 80000d9a <release>
}
    80000ae4:	70e2                	ld	ra,56(sp)
    80000ae6:	7442                	ld	s0,48(sp)
    80000ae8:	74a2                	ld	s1,40(sp)
    80000aea:	7902                	ld	s2,32(sp)
    80000aec:	69e2                	ld	s3,24(sp)
    80000aee:	6a42                	ld	s4,16(sp)
    80000af0:	6aa2                	ld	s5,8(sp)
    80000af2:	6b02                	ld	s6,0(sp)
    80000af4:	6121                	addi	sp,sp,64
    80000af6:	8082                	ret

0000000080000af8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000af8:	1101                	addi	sp,sp,-32
    80000afa:	ec06                	sd	ra,24(sp)
    80000afc:	e822                	sd	s0,16(sp)
    80000afe:	e426                	sd	s1,8(sp)
    80000b00:	e04a                	sd	s2,0(sp)
    80000b02:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000b04:	03451793          	slli	a5,a0,0x34
    80000b08:	ebb9                	bnez	a5,80000b5e <kfree+0x66>
    80000b0a:	84aa                	mv	s1,a0
    80000b0c:	00025797          	auipc	a5,0x25
    80000b10:	4f478793          	addi	a5,a5,1268 # 80026000 <end>
    80000b14:	04f56563          	bltu	a0,a5,80000b5e <kfree+0x66>
    80000b18:	47c5                	li	a5,17
    80000b1a:	07ee                	slli	a5,a5,0x1b
    80000b1c:	04f57163          	bgeu	a0,a5,80000b5e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000b20:	6605                	lui	a2,0x1
    80000b22:	4585                	li	a1,1
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	2be080e7          	jalr	702(ra) # 80000de2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000b2c:	00010917          	auipc	s2,0x10
    80000b30:	74490913          	addi	s2,s2,1860 # 80011270 <kmem>
    80000b34:	854a                	mv	a0,s2
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	1b0080e7          	jalr	432(ra) # 80000ce6 <acquire>
  r->next = kmem.freelist;
    80000b3e:	01893783          	ld	a5,24(s2)
    80000b42:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000b44:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000b48:	854a                	mv	a0,s2
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	250080e7          	jalr	592(ra) # 80000d9a <release>
}
    80000b52:	60e2                	ld	ra,24(sp)
    80000b54:	6442                	ld	s0,16(sp)
    80000b56:	64a2                	ld	s1,8(sp)
    80000b58:	6902                	ld	s2,0(sp)
    80000b5a:	6105                	addi	sp,sp,32
    80000b5c:	8082                	ret
    panic("kfree");
    80000b5e:	00007517          	auipc	a0,0x7
    80000b62:	50250513          	addi	a0,a0,1282 # 80008060 <digits+0x20>
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	9e2080e7          	jalr	-1566(ra) # 80000548 <panic>

0000000080000b6e <freerange>:
{
    80000b6e:	7179                	addi	sp,sp,-48
    80000b70:	f406                	sd	ra,40(sp)
    80000b72:	f022                	sd	s0,32(sp)
    80000b74:	ec26                	sd	s1,24(sp)
    80000b76:	e84a                	sd	s2,16(sp)
    80000b78:	e44e                	sd	s3,8(sp)
    80000b7a:	e052                	sd	s4,0(sp)
    80000b7c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b7e:	6785                	lui	a5,0x1
    80000b80:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b84:	00e504b3          	add	s1,a0,a4
    80000b88:	777d                	lui	a4,0xfffff
    80000b8a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b8c:	94be                	add	s1,s1,a5
    80000b8e:	0095ee63          	bltu	a1,s1,80000baa <freerange+0x3c>
    80000b92:	892e                	mv	s2,a1
    kfree(p);
    80000b94:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b96:	6985                	lui	s3,0x1
    kfree(p);
    80000b98:	01448533          	add	a0,s1,s4
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	f5c080e7          	jalr	-164(ra) # 80000af8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ba4:	94ce                	add	s1,s1,s3
    80000ba6:	fe9979e3          	bgeu	s2,s1,80000b98 <freerange+0x2a>
}
    80000baa:	70a2                	ld	ra,40(sp)
    80000bac:	7402                	ld	s0,32(sp)
    80000bae:	64e2                	ld	s1,24(sp)
    80000bb0:	6942                	ld	s2,16(sp)
    80000bb2:	69a2                	ld	s3,8(sp)
    80000bb4:	6a02                	ld	s4,0(sp)
    80000bb6:	6145                	addi	sp,sp,48
    80000bb8:	8082                	ret

0000000080000bba <kinit>:
{
    80000bba:	1141                	addi	sp,sp,-16
    80000bbc:	e406                	sd	ra,8(sp)
    80000bbe:	e022                	sd	s0,0(sp)
    80000bc0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000bc2:	00007597          	auipc	a1,0x7
    80000bc6:	4a658593          	addi	a1,a1,1190 # 80008068 <digits+0x28>
    80000bca:	00010517          	auipc	a0,0x10
    80000bce:	6a650513          	addi	a0,a0,1702 # 80011270 <kmem>
    80000bd2:	00000097          	auipc	ra,0x0
    80000bd6:	084080e7          	jalr	132(ra) # 80000c56 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bda:	45c5                	li	a1,17
    80000bdc:	05ee                	slli	a1,a1,0x1b
    80000bde:	00025517          	auipc	a0,0x25
    80000be2:	42250513          	addi	a0,a0,1058 # 80026000 <end>
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	f88080e7          	jalr	-120(ra) # 80000b6e <freerange>
}
    80000bee:	60a2                	ld	ra,8(sp)
    80000bf0:	6402                	ld	s0,0(sp)
    80000bf2:	0141                	addi	sp,sp,16
    80000bf4:	8082                	ret

0000000080000bf6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000bf6:	1101                	addi	sp,sp,-32
    80000bf8:	ec06                	sd	ra,24(sp)
    80000bfa:	e822                	sd	s0,16(sp)
    80000bfc:	e426                	sd	s1,8(sp)
    80000bfe:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000c00:	00010497          	auipc	s1,0x10
    80000c04:	67048493          	addi	s1,s1,1648 # 80011270 <kmem>
    80000c08:	8526                	mv	a0,s1
    80000c0a:	00000097          	auipc	ra,0x0
    80000c0e:	0dc080e7          	jalr	220(ra) # 80000ce6 <acquire>
  r = kmem.freelist;
    80000c12:	6c84                	ld	s1,24(s1)
  if(r)
    80000c14:	c885                	beqz	s1,80000c44 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000c16:	609c                	ld	a5,0(s1)
    80000c18:	00010517          	auipc	a0,0x10
    80000c1c:	65850513          	addi	a0,a0,1624 # 80011270 <kmem>
    80000c20:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	178080e7          	jalr	376(ra) # 80000d9a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c2a:	6605                	lui	a2,0x1
    80000c2c:	4595                	li	a1,5
    80000c2e:	8526                	mv	a0,s1
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	1b2080e7          	jalr	434(ra) # 80000de2 <memset>
  return (void*)r;
}
    80000c38:	8526                	mv	a0,s1
    80000c3a:	60e2                	ld	ra,24(sp)
    80000c3c:	6442                	ld	s0,16(sp)
    80000c3e:	64a2                	ld	s1,8(sp)
    80000c40:	6105                	addi	sp,sp,32
    80000c42:	8082                	ret
  release(&kmem.lock);
    80000c44:	00010517          	auipc	a0,0x10
    80000c48:	62c50513          	addi	a0,a0,1580 # 80011270 <kmem>
    80000c4c:	00000097          	auipc	ra,0x0
    80000c50:	14e080e7          	jalr	334(ra) # 80000d9a <release>
  if(r)
    80000c54:	b7d5                	j	80000c38 <kalloc+0x42>

0000000080000c56 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c56:	1141                	addi	sp,sp,-16
    80000c58:	e422                	sd	s0,8(sp)
    80000c5a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c5c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c5e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c62:	00053823          	sd	zero,16(a0)
}
    80000c66:	6422                	ld	s0,8(sp)
    80000c68:	0141                	addi	sp,sp,16
    80000c6a:	8082                	ret

0000000080000c6c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c6c:	411c                	lw	a5,0(a0)
    80000c6e:	e399                	bnez	a5,80000c74 <holding+0x8>
    80000c70:	4501                	li	a0,0
  return r;
}
    80000c72:	8082                	ret
{
    80000c74:	1101                	addi	sp,sp,-32
    80000c76:	ec06                	sd	ra,24(sp)
    80000c78:	e822                	sd	s0,16(sp)
    80000c7a:	e426                	sd	s1,8(sp)
    80000c7c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c7e:	6904                	ld	s1,16(a0)
    80000c80:	00001097          	auipc	ra,0x1
    80000c84:	da2080e7          	jalr	-606(ra) # 80001a22 <mycpu>
    80000c88:	40a48533          	sub	a0,s1,a0
    80000c8c:	00153513          	seqz	a0,a0
}
    80000c90:	60e2                	ld	ra,24(sp)
    80000c92:	6442                	ld	s0,16(sp)
    80000c94:	64a2                	ld	s1,8(sp)
    80000c96:	6105                	addi	sp,sp,32
    80000c98:	8082                	ret

0000000080000c9a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c9a:	1101                	addi	sp,sp,-32
    80000c9c:	ec06                	sd	ra,24(sp)
    80000c9e:	e822                	sd	s0,16(sp)
    80000ca0:	e426                	sd	s1,8(sp)
    80000ca2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ca4:	100024f3          	csrr	s1,sstatus
    80000ca8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cac:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cae:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000cb2:	00001097          	auipc	ra,0x1
    80000cb6:	d70080e7          	jalr	-656(ra) # 80001a22 <mycpu>
    80000cba:	5d3c                	lw	a5,120(a0)
    80000cbc:	cf89                	beqz	a5,80000cd6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cbe:	00001097          	auipc	ra,0x1
    80000cc2:	d64080e7          	jalr	-668(ra) # 80001a22 <mycpu>
    80000cc6:	5d3c                	lw	a5,120(a0)
    80000cc8:	2785                	addiw	a5,a5,1
    80000cca:	dd3c                	sw	a5,120(a0)
}
    80000ccc:	60e2                	ld	ra,24(sp)
    80000cce:	6442                	ld	s0,16(sp)
    80000cd0:	64a2                	ld	s1,8(sp)
    80000cd2:	6105                	addi	sp,sp,32
    80000cd4:	8082                	ret
    mycpu()->intena = old;
    80000cd6:	00001097          	auipc	ra,0x1
    80000cda:	d4c080e7          	jalr	-692(ra) # 80001a22 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cde:	8085                	srli	s1,s1,0x1
    80000ce0:	8885                	andi	s1,s1,1
    80000ce2:	dd64                	sw	s1,124(a0)
    80000ce4:	bfe9                	j	80000cbe <push_off+0x24>

0000000080000ce6 <acquire>:
{
    80000ce6:	1101                	addi	sp,sp,-32
    80000ce8:	ec06                	sd	ra,24(sp)
    80000cea:	e822                	sd	s0,16(sp)
    80000cec:	e426                	sd	s1,8(sp)
    80000cee:	1000                	addi	s0,sp,32
    80000cf0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	fa8080e7          	jalr	-88(ra) # 80000c9a <push_off>
  if(holding(lk))
    80000cfa:	8526                	mv	a0,s1
    80000cfc:	00000097          	auipc	ra,0x0
    80000d00:	f70080e7          	jalr	-144(ra) # 80000c6c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d04:	4705                	li	a4,1
  if(holding(lk))
    80000d06:	e115                	bnez	a0,80000d2a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d08:	87ba                	mv	a5,a4
    80000d0a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d0e:	2781                	sext.w	a5,a5
    80000d10:	ffe5                	bnez	a5,80000d08 <acquire+0x22>
  __sync_synchronize();
    80000d12:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d16:	00001097          	auipc	ra,0x1
    80000d1a:	d0c080e7          	jalr	-756(ra) # 80001a22 <mycpu>
    80000d1e:	e888                	sd	a0,16(s1)
}
    80000d20:	60e2                	ld	ra,24(sp)
    80000d22:	6442                	ld	s0,16(sp)
    80000d24:	64a2                	ld	s1,8(sp)
    80000d26:	6105                	addi	sp,sp,32
    80000d28:	8082                	ret
    panic("acquire");
    80000d2a:	00007517          	auipc	a0,0x7
    80000d2e:	34650513          	addi	a0,a0,838 # 80008070 <digits+0x30>
    80000d32:	00000097          	auipc	ra,0x0
    80000d36:	816080e7          	jalr	-2026(ra) # 80000548 <panic>

0000000080000d3a <pop_off>:

void
pop_off(void)
{
    80000d3a:	1141                	addi	sp,sp,-16
    80000d3c:	e406                	sd	ra,8(sp)
    80000d3e:	e022                	sd	s0,0(sp)
    80000d40:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d42:	00001097          	auipc	ra,0x1
    80000d46:	ce0080e7          	jalr	-800(ra) # 80001a22 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d4a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d4e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d50:	e78d                	bnez	a5,80000d7a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d52:	5d3c                	lw	a5,120(a0)
    80000d54:	02f05b63          	blez	a5,80000d8a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d58:	37fd                	addiw	a5,a5,-1
    80000d5a:	0007871b          	sext.w	a4,a5
    80000d5e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d60:	eb09                	bnez	a4,80000d72 <pop_off+0x38>
    80000d62:	5d7c                	lw	a5,124(a0)
    80000d64:	c799                	beqz	a5,80000d72 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d6e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d72:	60a2                	ld	ra,8(sp)
    80000d74:	6402                	ld	s0,0(sp)
    80000d76:	0141                	addi	sp,sp,16
    80000d78:	8082                	ret
    panic("pop_off - interruptible");
    80000d7a:	00007517          	auipc	a0,0x7
    80000d7e:	2fe50513          	addi	a0,a0,766 # 80008078 <digits+0x38>
    80000d82:	fffff097          	auipc	ra,0xfffff
    80000d86:	7c6080e7          	jalr	1990(ra) # 80000548 <panic>
    panic("pop_off");
    80000d8a:	00007517          	auipc	a0,0x7
    80000d8e:	30650513          	addi	a0,a0,774 # 80008090 <digits+0x50>
    80000d92:	fffff097          	auipc	ra,0xfffff
    80000d96:	7b6080e7          	jalr	1974(ra) # 80000548 <panic>

0000000080000d9a <release>:
{
    80000d9a:	1101                	addi	sp,sp,-32
    80000d9c:	ec06                	sd	ra,24(sp)
    80000d9e:	e822                	sd	s0,16(sp)
    80000da0:	e426                	sd	s1,8(sp)
    80000da2:	1000                	addi	s0,sp,32
    80000da4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000da6:	00000097          	auipc	ra,0x0
    80000daa:	ec6080e7          	jalr	-314(ra) # 80000c6c <holding>
    80000dae:	c115                	beqz	a0,80000dd2 <release+0x38>
  lk->cpu = 0;
    80000db0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000db4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000db8:	0f50000f          	fence	iorw,ow
    80000dbc:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000dc0:	00000097          	auipc	ra,0x0
    80000dc4:	f7a080e7          	jalr	-134(ra) # 80000d3a <pop_off>
}
    80000dc8:	60e2                	ld	ra,24(sp)
    80000dca:	6442                	ld	s0,16(sp)
    80000dcc:	64a2                	ld	s1,8(sp)
    80000dce:	6105                	addi	sp,sp,32
    80000dd0:	8082                	ret
    panic("release");
    80000dd2:	00007517          	auipc	a0,0x7
    80000dd6:	2c650513          	addi	a0,a0,710 # 80008098 <digits+0x58>
    80000dda:	fffff097          	auipc	ra,0xfffff
    80000dde:	76e080e7          	jalr	1902(ra) # 80000548 <panic>

0000000080000de2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000de2:	1141                	addi	sp,sp,-16
    80000de4:	e422                	sd	s0,8(sp)
    80000de6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000de8:	ca19                	beqz	a2,80000dfe <memset+0x1c>
    80000dea:	87aa                	mv	a5,a0
    80000dec:	1602                	slli	a2,a2,0x20
    80000dee:	9201                	srli	a2,a2,0x20
    80000df0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000df4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000df8:	0785                	addi	a5,a5,1
    80000dfa:	fee79de3          	bne	a5,a4,80000df4 <memset+0x12>
  }
  return dst;
}
    80000dfe:	6422                	ld	s0,8(sp)
    80000e00:	0141                	addi	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e04:	1141                	addi	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e0a:	ca05                	beqz	a2,80000e3a <memcmp+0x36>
    80000e0c:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000e10:	1682                	slli	a3,a3,0x20
    80000e12:	9281                	srli	a3,a3,0x20
    80000e14:	0685                	addi	a3,a3,1
    80000e16:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	0005c703          	lbu	a4,0(a1)
    80000e20:	00e79863          	bne	a5,a4,80000e30 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e24:	0505                	addi	a0,a0,1
    80000e26:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e28:	fed518e3          	bne	a0,a3,80000e18 <memcmp+0x14>
  }

  return 0;
    80000e2c:	4501                	li	a0,0
    80000e2e:	a019                	j	80000e34 <memcmp+0x30>
      return *s1 - *s2;
    80000e30:	40e7853b          	subw	a0,a5,a4
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret
  return 0;
    80000e3a:	4501                	li	a0,0
    80000e3c:	bfe5                	j	80000e34 <memcmp+0x30>

0000000080000e3e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e3e:	1141                	addi	sp,sp,-16
    80000e40:	e422                	sd	s0,8(sp)
    80000e42:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e44:	02a5e563          	bltu	a1,a0,80000e6e <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e48:	fff6069b          	addiw	a3,a2,-1
    80000e4c:	ce11                	beqz	a2,80000e68 <memmove+0x2a>
    80000e4e:	1682                	slli	a3,a3,0x20
    80000e50:	9281                	srli	a3,a3,0x20
    80000e52:	0685                	addi	a3,a3,1
    80000e54:	96ae                	add	a3,a3,a1
    80000e56:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000e58:	0585                	addi	a1,a1,1
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff5c703          	lbu	a4,-1(a1)
    80000e60:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e64:	fed59ae3          	bne	a1,a3,80000e58 <memmove+0x1a>

  return dst;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  if(s < d && s + n > d){
    80000e6e:	02061713          	slli	a4,a2,0x20
    80000e72:	9301                	srli	a4,a4,0x20
    80000e74:	00e587b3          	add	a5,a1,a4
    80000e78:	fcf578e3          	bgeu	a0,a5,80000e48 <memmove+0xa>
    d += n;
    80000e7c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e7e:	fff6069b          	addiw	a3,a2,-1
    80000e82:	d27d                	beqz	a2,80000e68 <memmove+0x2a>
    80000e84:	02069613          	slli	a2,a3,0x20
    80000e88:	9201                	srli	a2,a2,0x20
    80000e8a:	fff64613          	not	a2,a2
    80000e8e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e90:	17fd                	addi	a5,a5,-1
    80000e92:	177d                	addi	a4,a4,-1 # ffffffffffffefff <end+0xffffffff7ffd8fff>
    80000e94:	0007c683          	lbu	a3,0(a5)
    80000e98:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e9c:	fef61ae3          	bne	a2,a5,80000e90 <memmove+0x52>
    80000ea0:	b7e1                	j	80000e68 <memmove+0x2a>

0000000080000ea2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000ea2:	1141                	addi	sp,sp,-16
    80000ea4:	e406                	sd	ra,8(sp)
    80000ea6:	e022                	sd	s0,0(sp)
    80000ea8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	f94080e7          	jalr	-108(ra) # 80000e3e <memmove>
}
    80000eb2:	60a2                	ld	ra,8(sp)
    80000eb4:	6402                	ld	s0,0(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret

0000000080000eba <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000eba:	1141                	addi	sp,sp,-16
    80000ebc:	e422                	sd	s0,8(sp)
    80000ebe:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ec0:	ce11                	beqz	a2,80000edc <strncmp+0x22>
    80000ec2:	00054783          	lbu	a5,0(a0)
    80000ec6:	cf89                	beqz	a5,80000ee0 <strncmp+0x26>
    80000ec8:	0005c703          	lbu	a4,0(a1)
    80000ecc:	00f71a63          	bne	a4,a5,80000ee0 <strncmp+0x26>
    n--, p++, q++;
    80000ed0:	367d                	addiw	a2,a2,-1
    80000ed2:	0505                	addi	a0,a0,1
    80000ed4:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ed6:	f675                	bnez	a2,80000ec2 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ed8:	4501                	li	a0,0
    80000eda:	a809                	j	80000eec <strncmp+0x32>
    80000edc:	4501                	li	a0,0
    80000ede:	a039                	j	80000eec <strncmp+0x32>
  if(n == 0)
    80000ee0:	ca09                	beqz	a2,80000ef2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000ee2:	00054503          	lbu	a0,0(a0)
    80000ee6:	0005c783          	lbu	a5,0(a1)
    80000eea:	9d1d                	subw	a0,a0,a5
}
    80000eec:	6422                	ld	s0,8(sp)
    80000eee:	0141                	addi	sp,sp,16
    80000ef0:	8082                	ret
    return 0;
    80000ef2:	4501                	li	a0,0
    80000ef4:	bfe5                	j	80000eec <strncmp+0x32>

0000000080000ef6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ef6:	1141                	addi	sp,sp,-16
    80000ef8:	e422                	sd	s0,8(sp)
    80000efa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000efc:	87aa                	mv	a5,a0
    80000efe:	86b2                	mv	a3,a2
    80000f00:	367d                	addiw	a2,a2,-1
    80000f02:	00d05963          	blez	a3,80000f14 <strncpy+0x1e>
    80000f06:	0785                	addi	a5,a5,1
    80000f08:	0005c703          	lbu	a4,0(a1)
    80000f0c:	fee78fa3          	sb	a4,-1(a5)
    80000f10:	0585                	addi	a1,a1,1
    80000f12:	f775                	bnez	a4,80000efe <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f14:	873e                	mv	a4,a5
    80000f16:	9fb5                	addw	a5,a5,a3
    80000f18:	37fd                	addiw	a5,a5,-1
    80000f1a:	00c05963          	blez	a2,80000f2c <strncpy+0x36>
    *s++ = 0;
    80000f1e:	0705                	addi	a4,a4,1
    80000f20:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000f24:	40e786bb          	subw	a3,a5,a4
    80000f28:	fed04be3          	bgtz	a3,80000f1e <strncpy+0x28>
  return os;
}
    80000f2c:	6422                	ld	s0,8(sp)
    80000f2e:	0141                	addi	sp,sp,16
    80000f30:	8082                	ret

0000000080000f32 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f32:	1141                	addi	sp,sp,-16
    80000f34:	e422                	sd	s0,8(sp)
    80000f36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f38:	02c05363          	blez	a2,80000f5e <safestrcpy+0x2c>
    80000f3c:	fff6069b          	addiw	a3,a2,-1
    80000f40:	1682                	slli	a3,a3,0x20
    80000f42:	9281                	srli	a3,a3,0x20
    80000f44:	96ae                	add	a3,a3,a1
    80000f46:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f48:	00d58963          	beq	a1,a3,80000f5a <safestrcpy+0x28>
    80000f4c:	0585                	addi	a1,a1,1
    80000f4e:	0785                	addi	a5,a5,1
    80000f50:	fff5c703          	lbu	a4,-1(a1)
    80000f54:	fee78fa3          	sb	a4,-1(a5)
    80000f58:	fb65                	bnez	a4,80000f48 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f5a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f5e:	6422                	ld	s0,8(sp)
    80000f60:	0141                	addi	sp,sp,16
    80000f62:	8082                	ret

0000000080000f64 <strlen>:

int
strlen(const char *s)
{
    80000f64:	1141                	addi	sp,sp,-16
    80000f66:	e422                	sd	s0,8(sp)
    80000f68:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f6a:	00054783          	lbu	a5,0(a0)
    80000f6e:	cf91                	beqz	a5,80000f8a <strlen+0x26>
    80000f70:	0505                	addi	a0,a0,1
    80000f72:	87aa                	mv	a5,a0
    80000f74:	86be                	mv	a3,a5
    80000f76:	0785                	addi	a5,a5,1
    80000f78:	fff7c703          	lbu	a4,-1(a5)
    80000f7c:	ff65                	bnez	a4,80000f74 <strlen+0x10>
    80000f7e:	40a6853b          	subw	a0,a3,a0
    80000f82:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000f84:	6422                	ld	s0,8(sp)
    80000f86:	0141                	addi	sp,sp,16
    80000f88:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f8a:	4501                	li	a0,0
    80000f8c:	bfe5                	j	80000f84 <strlen+0x20>

0000000080000f8e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e406                	sd	ra,8(sp)
    80000f92:	e022                	sd	s0,0(sp)
    80000f94:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	a7c080e7          	jalr	-1412(ra) # 80001a12 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f9e:	00008717          	auipc	a4,0x8
    80000fa2:	07670713          	addi	a4,a4,118 # 80009014 <started>
  if(cpuid() == 0){
    80000fa6:	c139                	beqz	a0,80000fec <main+0x5e>
    while(started == 0)
    80000fa8:	431c                	lw	a5,0(a4)
    80000faa:	2781                	sext.w	a5,a5
    80000fac:	dff5                	beqz	a5,80000fa8 <main+0x1a>
      ;
    __sync_synchronize();
    80000fae:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fb2:	00001097          	auipc	ra,0x1
    80000fb6:	a60080e7          	jalr	-1440(ra) # 80001a12 <cpuid>
    80000fba:	85aa                	mv	a1,a0
    80000fbc:	00007517          	auipc	a0,0x7
    80000fc0:	0fc50513          	addi	a0,a0,252 # 800080b8 <digits+0x78>
    80000fc4:	fffff097          	auipc	ra,0xfffff
    80000fc8:	5ce080e7          	jalr	1486(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000fcc:	00000097          	auipc	ra,0x0
    80000fd0:	17e080e7          	jalr	382(ra) # 8000114a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fd4:	00001097          	auipc	ra,0x1
    80000fd8:	6c8080e7          	jalr	1736(ra) # 8000269c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	c14080e7          	jalr	-1004(ra) # 80005bf0 <plicinithart>
  }

  scheduler();        
    80000fe4:	00001097          	auipc	ra,0x1
    80000fe8:	f92080e7          	jalr	-110(ra) # 80001f76 <scheduler>
    consoleinit();
    80000fec:	fffff097          	auipc	ra,0xfffff
    80000ff0:	46c080e7          	jalr	1132(ra) # 80000458 <consoleinit>
    printfinit();
    80000ff4:	fffff097          	auipc	ra,0xfffff
    80000ff8:	77e080e7          	jalr	1918(ra) # 80000772 <printfinit>
    printf("\n");
    80000ffc:	00007517          	auipc	a0,0x7
    80001000:	0cc50513          	addi	a0,a0,204 # 800080c8 <digits+0x88>
    80001004:	fffff097          	auipc	ra,0xfffff
    80001008:	58e080e7          	jalr	1422(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    8000100c:	00007517          	auipc	a0,0x7
    80001010:	09450513          	addi	a0,a0,148 # 800080a0 <digits+0x60>
    80001014:	fffff097          	auipc	ra,0xfffff
    80001018:	57e080e7          	jalr	1406(ra) # 80000592 <printf>
    printf("\n");
    8000101c:	00007517          	auipc	a0,0x7
    80001020:	0ac50513          	addi	a0,a0,172 # 800080c8 <digits+0x88>
    80001024:	fffff097          	auipc	ra,0xfffff
    80001028:	56e080e7          	jalr	1390(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    8000102c:	00000097          	auipc	ra,0x0
    80001030:	b8e080e7          	jalr	-1138(ra) # 80000bba <kinit>
    kvminit();       // create kernel page table
    80001034:	00000097          	auipc	ra,0x0
    80001038:	242080e7          	jalr	578(ra) # 80001276 <kvminit>
    kvminithart();   // turn on paging
    8000103c:	00000097          	auipc	ra,0x0
    80001040:	10e080e7          	jalr	270(ra) # 8000114a <kvminithart>
    procinit();      // process table
    80001044:	00001097          	auipc	ra,0x1
    80001048:	8fe080e7          	jalr	-1794(ra) # 80001942 <procinit>
    trapinit();      // trap vectors
    8000104c:	00001097          	auipc	ra,0x1
    80001050:	628080e7          	jalr	1576(ra) # 80002674 <trapinit>
    trapinithart();  // install kernel trap vector
    80001054:	00001097          	auipc	ra,0x1
    80001058:	648080e7          	jalr	1608(ra) # 8000269c <trapinithart>
    plicinit();      // set up interrupt controller
    8000105c:	00005097          	auipc	ra,0x5
    80001060:	b7e080e7          	jalr	-1154(ra) # 80005bda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001064:	00005097          	auipc	ra,0x5
    80001068:	b8c080e7          	jalr	-1140(ra) # 80005bf0 <plicinithart>
    binit();         // buffer cache
    8000106c:	00002097          	auipc	ra,0x2
    80001070:	d76080e7          	jalr	-650(ra) # 80002de2 <binit>
    iinit();         // inode cache
    80001074:	00002097          	auipc	ra,0x2
    80001078:	402080e7          	jalr	1026(ra) # 80003476 <iinit>
    fileinit();      // file table
    8000107c:	00003097          	auipc	ra,0x3
    80001080:	38a080e7          	jalr	906(ra) # 80004406 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001084:	00005097          	auipc	ra,0x5
    80001088:	c8c080e7          	jalr	-884(ra) # 80005d10 <virtio_disk_init>
    userinit();      // first user process
    8000108c:	00001097          	auipc	ra,0x1
    80001090:	c7c080e7          	jalr	-900(ra) # 80001d08 <userinit>
    __sync_synchronize();
    80001094:	0ff0000f          	fence
    started = 1;
    80001098:	4785                	li	a5,1
    8000109a:	00008717          	auipc	a4,0x8
    8000109e:	f6f72d23          	sw	a5,-134(a4) # 80009014 <started>
    800010a2:	b789                	j	80000fe4 <main+0x56>

00000000800010a4 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010a4:	7139                	addi	sp,sp,-64
    800010a6:	fc06                	sd	ra,56(sp)
    800010a8:	f822                	sd	s0,48(sp)
    800010aa:	f426                	sd	s1,40(sp)
    800010ac:	f04a                	sd	s2,32(sp)
    800010ae:	ec4e                	sd	s3,24(sp)
    800010b0:	e852                	sd	s4,16(sp)
    800010b2:	e456                	sd	s5,8(sp)
    800010b4:	e05a                	sd	s6,0(sp)
    800010b6:	0080                	addi	s0,sp,64
    800010b8:	84aa                	mv	s1,a0
    800010ba:	89ae                	mv	s3,a1
    800010bc:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800010be:	57fd                	li	a5,-1
    800010c0:	83e9                	srli	a5,a5,0x1a
    800010c2:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010c4:	4b31                	li	s6,12
  if(va >= MAXVA)
    800010c6:	04b7f263          	bgeu	a5,a1,8000110a <walk+0x66>
    panic("walk");
    800010ca:	00007517          	auipc	a0,0x7
    800010ce:	00650513          	addi	a0,a0,6 # 800080d0 <digits+0x90>
    800010d2:	fffff097          	auipc	ra,0xfffff
    800010d6:	476080e7          	jalr	1142(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010da:	060a8663          	beqz	s5,80001146 <walk+0xa2>
    800010de:	00000097          	auipc	ra,0x0
    800010e2:	b18080e7          	jalr	-1256(ra) # 80000bf6 <kalloc>
    800010e6:	84aa                	mv	s1,a0
    800010e8:	c529                	beqz	a0,80001132 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010ea:	6605                	lui	a2,0x1
    800010ec:	4581                	li	a1,0
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	cf4080e7          	jalr	-780(ra) # 80000de2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010f6:	00c4d793          	srli	a5,s1,0xc
    800010fa:	07aa                	slli	a5,a5,0xa
    800010fc:	0017e793          	ori	a5,a5,1
    80001100:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001104:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd8ff7>
    80001106:	036a0063          	beq	s4,s6,80001126 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000110a:	0149d933          	srl	s2,s3,s4
    8000110e:	1ff97913          	andi	s2,s2,511
    80001112:	090e                	slli	s2,s2,0x3
    80001114:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001116:	00093483          	ld	s1,0(s2)
    8000111a:	0014f793          	andi	a5,s1,1
    8000111e:	dfd5                	beqz	a5,800010da <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001120:	80a9                	srli	s1,s1,0xa
    80001122:	04b2                	slli	s1,s1,0xc
    80001124:	b7c5                	j	80001104 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001126:	00c9d513          	srli	a0,s3,0xc
    8000112a:	1ff57513          	andi	a0,a0,511
    8000112e:	050e                	slli	a0,a0,0x3
    80001130:	9526                	add	a0,a0,s1
}
    80001132:	70e2                	ld	ra,56(sp)
    80001134:	7442                	ld	s0,48(sp)
    80001136:	74a2                	ld	s1,40(sp)
    80001138:	7902                	ld	s2,32(sp)
    8000113a:	69e2                	ld	s3,24(sp)
    8000113c:	6a42                	ld	s4,16(sp)
    8000113e:	6aa2                	ld	s5,8(sp)
    80001140:	6b02                	ld	s6,0(sp)
    80001142:	6121                	addi	sp,sp,64
    80001144:	8082                	ret
        return 0;
    80001146:	4501                	li	a0,0
    80001148:	b7ed                	j	80001132 <walk+0x8e>

000000008000114a <kvminithart>:
{
    8000114a:	1141                	addi	sp,sp,-16
    8000114c:	e422                	sd	s0,8(sp)
    8000114e:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001150:	00008797          	auipc	a5,0x8
    80001154:	ec87b783          	ld	a5,-312(a5) # 80009018 <kernel_pagetable>
    80001158:	83b1                	srli	a5,a5,0xc
    8000115a:	577d                	li	a4,-1
    8000115c:	177e                	slli	a4,a4,0x3f
    8000115e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001160:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001164:	12000073          	sfence.vma
}
    80001168:	6422                	ld	s0,8(sp)
    8000116a:	0141                	addi	sp,sp,16
    8000116c:	8082                	ret

000000008000116e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000116e:	57fd                	li	a5,-1
    80001170:	83e9                	srli	a5,a5,0x1a
    80001172:	00b7f463          	bgeu	a5,a1,8000117a <walkaddr+0xc>
    return 0;
    80001176:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001178:	8082                	ret
{
    8000117a:	1141                	addi	sp,sp,-16
    8000117c:	e406                	sd	ra,8(sp)
    8000117e:	e022                	sd	s0,0(sp)
    80001180:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001182:	4601                	li	a2,0
    80001184:	00000097          	auipc	ra,0x0
    80001188:	f20080e7          	jalr	-224(ra) # 800010a4 <walk>
  if(pte == 0)
    8000118c:	c105                	beqz	a0,800011ac <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000118e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001190:	0117f693          	andi	a3,a5,17
    80001194:	4745                	li	a4,17
    return 0;
    80001196:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001198:	00e68663          	beq	a3,a4,800011a4 <walkaddr+0x36>
}
    8000119c:	60a2                	ld	ra,8(sp)
    8000119e:	6402                	ld	s0,0(sp)
    800011a0:	0141                	addi	sp,sp,16
    800011a2:	8082                	ret
  pa = PTE2PA(*pte);
    800011a4:	83a9                	srli	a5,a5,0xa
    800011a6:	00c79513          	slli	a0,a5,0xc
  return pa;
    800011aa:	bfcd                	j	8000119c <walkaddr+0x2e>
    return 0;
    800011ac:	4501                	li	a0,0
    800011ae:	b7fd                	j	8000119c <walkaddr+0x2e>

00000000800011b0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011b0:	715d                	addi	sp,sp,-80
    800011b2:	e486                	sd	ra,72(sp)
    800011b4:	e0a2                	sd	s0,64(sp)
    800011b6:	fc26                	sd	s1,56(sp)
    800011b8:	f84a                	sd	s2,48(sp)
    800011ba:	f44e                	sd	s3,40(sp)
    800011bc:	f052                	sd	s4,32(sp)
    800011be:	ec56                	sd	s5,24(sp)
    800011c0:	e85a                	sd	s6,16(sp)
    800011c2:	e45e                	sd	s7,8(sp)
    800011c4:	0880                	addi	s0,sp,80
    800011c6:	8aaa                	mv	s5,a0
    800011c8:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011ca:	777d                	lui	a4,0xfffff
    800011cc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011d0:	fff60993          	addi	s3,a2,-1 # fff <_entry-0x7ffff001>
    800011d4:	99ae                	add	s3,s3,a1
    800011d6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011da:	893e                	mv	s2,a5
    800011dc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011e0:	6b85                	lui	s7,0x1
    800011e2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011e6:	4605                	li	a2,1
    800011e8:	85ca                	mv	a1,s2
    800011ea:	8556                	mv	a0,s5
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	eb8080e7          	jalr	-328(ra) # 800010a4 <walk>
    800011f4:	c51d                	beqz	a0,80001222 <mappages+0x72>
    if(*pte & PTE_V)
    800011f6:	611c                	ld	a5,0(a0)
    800011f8:	8b85                	andi	a5,a5,1
    800011fa:	ef81                	bnez	a5,80001212 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011fc:	80b1                	srli	s1,s1,0xc
    800011fe:	04aa                	slli	s1,s1,0xa
    80001200:	0164e4b3          	or	s1,s1,s6
    80001204:	0014e493          	ori	s1,s1,1
    80001208:	e104                	sd	s1,0(a0)
    if(a == last)
    8000120a:	03390863          	beq	s2,s3,8000123a <mappages+0x8a>
    a += PGSIZE;
    8000120e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001210:	bfc9                	j	800011e2 <mappages+0x32>
      panic("remap");
    80001212:	00007517          	auipc	a0,0x7
    80001216:	ec650513          	addi	a0,a0,-314 # 800080d8 <digits+0x98>
    8000121a:	fffff097          	auipc	ra,0xfffff
    8000121e:	32e080e7          	jalr	814(ra) # 80000548 <panic>
      return -1;
    80001222:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001224:	60a6                	ld	ra,72(sp)
    80001226:	6406                	ld	s0,64(sp)
    80001228:	74e2                	ld	s1,56(sp)
    8000122a:	7942                	ld	s2,48(sp)
    8000122c:	79a2                	ld	s3,40(sp)
    8000122e:	7a02                	ld	s4,32(sp)
    80001230:	6ae2                	ld	s5,24(sp)
    80001232:	6b42                	ld	s6,16(sp)
    80001234:	6ba2                	ld	s7,8(sp)
    80001236:	6161                	addi	sp,sp,80
    80001238:	8082                	ret
  return 0;
    8000123a:	4501                	li	a0,0
    8000123c:	b7e5                	j	80001224 <mappages+0x74>

000000008000123e <kvmmap>:
{
    8000123e:	1141                	addi	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	addi	s0,sp,16
    80001246:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001248:	86ae                	mv	a3,a1
    8000124a:	85aa                	mv	a1,a0
    8000124c:	00008517          	auipc	a0,0x8
    80001250:	dcc53503          	ld	a0,-564(a0) # 80009018 <kernel_pagetable>
    80001254:	00000097          	auipc	ra,0x0
    80001258:	f5c080e7          	jalr	-164(ra) # 800011b0 <mappages>
    8000125c:	e509                	bnez	a0,80001266 <kvmmap+0x28>
}
    8000125e:	60a2                	ld	ra,8(sp)
    80001260:	6402                	ld	s0,0(sp)
    80001262:	0141                	addi	sp,sp,16
    80001264:	8082                	ret
    panic("kvmmap");
    80001266:	00007517          	auipc	a0,0x7
    8000126a:	e7a50513          	addi	a0,a0,-390 # 800080e0 <digits+0xa0>
    8000126e:	fffff097          	auipc	ra,0xfffff
    80001272:	2da080e7          	jalr	730(ra) # 80000548 <panic>

0000000080001276 <kvminit>:
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001280:	00000097          	auipc	ra,0x0
    80001284:	976080e7          	jalr	-1674(ra) # 80000bf6 <kalloc>
    80001288:	00008717          	auipc	a4,0x8
    8000128c:	d8a73823          	sd	a0,-624(a4) # 80009018 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001290:	6605                	lui	a2,0x1
    80001292:	4581                	li	a1,0
    80001294:	00000097          	auipc	ra,0x0
    80001298:	b4e080e7          	jalr	-1202(ra) # 80000de2 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000129c:	4699                	li	a3,6
    8000129e:	6605                	lui	a2,0x1
    800012a0:	100005b7          	lui	a1,0x10000
    800012a4:	10000537          	lui	a0,0x10000
    800012a8:	00000097          	auipc	ra,0x0
    800012ac:	f96080e7          	jalr	-106(ra) # 8000123e <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012b0:	4699                	li	a3,6
    800012b2:	6605                	lui	a2,0x1
    800012b4:	100015b7          	lui	a1,0x10001
    800012b8:	10001537          	lui	a0,0x10001
    800012bc:	00000097          	auipc	ra,0x0
    800012c0:	f82080e7          	jalr	-126(ra) # 8000123e <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012c4:	4699                	li	a3,6
    800012c6:	00400637          	lui	a2,0x400
    800012ca:	0c0005b7          	lui	a1,0xc000
    800012ce:	0c000537          	lui	a0,0xc000
    800012d2:	00000097          	auipc	ra,0x0
    800012d6:	f6c080e7          	jalr	-148(ra) # 8000123e <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012da:	00007497          	auipc	s1,0x7
    800012de:	d2648493          	addi	s1,s1,-730 # 80008000 <etext>
    800012e2:	46a9                	li	a3,10
    800012e4:	80007617          	auipc	a2,0x80007
    800012e8:	d1c60613          	addi	a2,a2,-740 # 8000 <_entry-0x7fff8000>
    800012ec:	4585                	li	a1,1
    800012ee:	05fe                	slli	a1,a1,0x1f
    800012f0:	852e                	mv	a0,a1
    800012f2:	00000097          	auipc	ra,0x0
    800012f6:	f4c080e7          	jalr	-180(ra) # 8000123e <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012fa:	4699                	li	a3,6
    800012fc:	4645                	li	a2,17
    800012fe:	066e                	slli	a2,a2,0x1b
    80001300:	8e05                	sub	a2,a2,s1
    80001302:	85a6                	mv	a1,s1
    80001304:	8526                	mv	a0,s1
    80001306:	00000097          	auipc	ra,0x0
    8000130a:	f38080e7          	jalr	-200(ra) # 8000123e <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000130e:	46a9                	li	a3,10
    80001310:	6605                	lui	a2,0x1
    80001312:	00006597          	auipc	a1,0x6
    80001316:	cee58593          	addi	a1,a1,-786 # 80007000 <_trampoline>
    8000131a:	04000537          	lui	a0,0x4000
    8000131e:	157d                	addi	a0,a0,-1 # 3ffffff <_entry-0x7c000001>
    80001320:	0532                	slli	a0,a0,0xc
    80001322:	00000097          	auipc	ra,0x0
    80001326:	f1c080e7          	jalr	-228(ra) # 8000123e <kvmmap>
}
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret

0000000080001334 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001334:	715d                	addi	sp,sp,-80
    80001336:	e486                	sd	ra,72(sp)
    80001338:	e0a2                	sd	s0,64(sp)
    8000133a:	fc26                	sd	s1,56(sp)
    8000133c:	f84a                	sd	s2,48(sp)
    8000133e:	f44e                	sd	s3,40(sp)
    80001340:	f052                	sd	s4,32(sp)
    80001342:	ec56                	sd	s5,24(sp)
    80001344:	e85a                	sd	s6,16(sp)
    80001346:	e45e                	sd	s7,8(sp)
    80001348:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000134a:	03459793          	slli	a5,a1,0x34
    8000134e:	e795                	bnez	a5,8000137a <uvmunmap+0x46>
    80001350:	8a2a                	mv	s4,a0
    80001352:	892e                	mv	s2,a1
    80001354:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001356:	0632                	slli	a2,a2,0xc
    80001358:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000135c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000135e:	6b05                	lui	s6,0x1
    80001360:	0735e263          	bltu	a1,s3,800013c4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001364:	60a6                	ld	ra,72(sp)
    80001366:	6406                	ld	s0,64(sp)
    80001368:	74e2                	ld	s1,56(sp)
    8000136a:	7942                	ld	s2,48(sp)
    8000136c:	79a2                	ld	s3,40(sp)
    8000136e:	7a02                	ld	s4,32(sp)
    80001370:	6ae2                	ld	s5,24(sp)
    80001372:	6b42                	ld	s6,16(sp)
    80001374:	6ba2                	ld	s7,8(sp)
    80001376:	6161                	addi	sp,sp,80
    80001378:	8082                	ret
    panic("uvmunmap: not aligned");
    8000137a:	00007517          	auipc	a0,0x7
    8000137e:	d6e50513          	addi	a0,a0,-658 # 800080e8 <digits+0xa8>
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	1c6080e7          	jalr	454(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    8000138a:	00007517          	auipc	a0,0x7
    8000138e:	d7650513          	addi	a0,a0,-650 # 80008100 <digits+0xc0>
    80001392:	fffff097          	auipc	ra,0xfffff
    80001396:	1b6080e7          	jalr	438(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    8000139a:	00007517          	auipc	a0,0x7
    8000139e:	d7650513          	addi	a0,a0,-650 # 80008110 <digits+0xd0>
    800013a2:	fffff097          	auipc	ra,0xfffff
    800013a6:	1a6080e7          	jalr	422(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800013aa:	00007517          	auipc	a0,0x7
    800013ae:	d7e50513          	addi	a0,a0,-642 # 80008128 <digits+0xe8>
    800013b2:	fffff097          	auipc	ra,0xfffff
    800013b6:	196080e7          	jalr	406(ra) # 80000548 <panic>
    *pte = 0;
    800013ba:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013be:	995a                	add	s2,s2,s6
    800013c0:	fb3972e3          	bgeu	s2,s3,80001364 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013c4:	4601                	li	a2,0
    800013c6:	85ca                	mv	a1,s2
    800013c8:	8552                	mv	a0,s4
    800013ca:	00000097          	auipc	ra,0x0
    800013ce:	cda080e7          	jalr	-806(ra) # 800010a4 <walk>
    800013d2:	84aa                	mv	s1,a0
    800013d4:	d95d                	beqz	a0,8000138a <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013d6:	6108                	ld	a0,0(a0)
    800013d8:	00157793          	andi	a5,a0,1
    800013dc:	dfdd                	beqz	a5,8000139a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013de:	3ff57793          	andi	a5,a0,1023
    800013e2:	fd7784e3          	beq	a5,s7,800013aa <uvmunmap+0x76>
    if(do_free){
    800013e6:	fc0a8ae3          	beqz	s5,800013ba <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013ea:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013ec:	0532                	slli	a0,a0,0xc
    800013ee:	fffff097          	auipc	ra,0xfffff
    800013f2:	70a080e7          	jalr	1802(ra) # 80000af8 <kfree>
    800013f6:	b7d1                	j	800013ba <uvmunmap+0x86>

00000000800013f8 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013f8:	1101                	addi	sp,sp,-32
    800013fa:	ec06                	sd	ra,24(sp)
    800013fc:	e822                	sd	s0,16(sp)
    800013fe:	e426                	sd	s1,8(sp)
    80001400:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001402:	fffff097          	auipc	ra,0xfffff
    80001406:	7f4080e7          	jalr	2036(ra) # 80000bf6 <kalloc>
    8000140a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000140c:	c519                	beqz	a0,8000141a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000140e:	6605                	lui	a2,0x1
    80001410:	4581                	li	a1,0
    80001412:	00000097          	auipc	ra,0x0
    80001416:	9d0080e7          	jalr	-1584(ra) # 80000de2 <memset>
  return pagetable;
}
    8000141a:	8526                	mv	a0,s1
    8000141c:	60e2                	ld	ra,24(sp)
    8000141e:	6442                	ld	s0,16(sp)
    80001420:	64a2                	ld	s1,8(sp)
    80001422:	6105                	addi	sp,sp,32
    80001424:	8082                	ret

0000000080001426 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001426:	7179                	addi	sp,sp,-48
    80001428:	f406                	sd	ra,40(sp)
    8000142a:	f022                	sd	s0,32(sp)
    8000142c:	ec26                	sd	s1,24(sp)
    8000142e:	e84a                	sd	s2,16(sp)
    80001430:	e44e                	sd	s3,8(sp)
    80001432:	e052                	sd	s4,0(sp)
    80001434:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001436:	6785                	lui	a5,0x1
    80001438:	04f67863          	bgeu	a2,a5,80001488 <uvminit+0x62>
    8000143c:	8a2a                	mv	s4,a0
    8000143e:	89ae                	mv	s3,a1
    80001440:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	7b4080e7          	jalr	1972(ra) # 80000bf6 <kalloc>
    8000144a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000144c:	6605                	lui	a2,0x1
    8000144e:	4581                	li	a1,0
    80001450:	00000097          	auipc	ra,0x0
    80001454:	992080e7          	jalr	-1646(ra) # 80000de2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001458:	4779                	li	a4,30
    8000145a:	86ca                	mv	a3,s2
    8000145c:	6605                	lui	a2,0x1
    8000145e:	4581                	li	a1,0
    80001460:	8552                	mv	a0,s4
    80001462:	00000097          	auipc	ra,0x0
    80001466:	d4e080e7          	jalr	-690(ra) # 800011b0 <mappages>
  memmove(mem, src, sz);
    8000146a:	8626                	mv	a2,s1
    8000146c:	85ce                	mv	a1,s3
    8000146e:	854a                	mv	a0,s2
    80001470:	00000097          	auipc	ra,0x0
    80001474:	9ce080e7          	jalr	-1586(ra) # 80000e3e <memmove>
}
    80001478:	70a2                	ld	ra,40(sp)
    8000147a:	7402                	ld	s0,32(sp)
    8000147c:	64e2                	ld	s1,24(sp)
    8000147e:	6942                	ld	s2,16(sp)
    80001480:	69a2                	ld	s3,8(sp)
    80001482:	6a02                	ld	s4,0(sp)
    80001484:	6145                	addi	sp,sp,48
    80001486:	8082                	ret
    panic("inituvm: more than a page");
    80001488:	00007517          	auipc	a0,0x7
    8000148c:	cb850513          	addi	a0,a0,-840 # 80008140 <digits+0x100>
    80001490:	fffff097          	auipc	ra,0xfffff
    80001494:	0b8080e7          	jalr	184(ra) # 80000548 <panic>

0000000080001498 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001498:	1101                	addi	sp,sp,-32
    8000149a:	ec06                	sd	ra,24(sp)
    8000149c:	e822                	sd	s0,16(sp)
    8000149e:	e426                	sd	s1,8(sp)
    800014a0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014a2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014a4:	00b67d63          	bgeu	a2,a1,800014be <uvmdealloc+0x26>
    800014a8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014aa:	6785                	lui	a5,0x1
    800014ac:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014ae:	00f60733          	add	a4,a2,a5
    800014b2:	76fd                	lui	a3,0xfffff
    800014b4:	8f75                	and	a4,a4,a3
    800014b6:	97ae                	add	a5,a5,a1
    800014b8:	8ff5                	and	a5,a5,a3
    800014ba:	00f76863          	bltu	a4,a5,800014ca <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014be:	8526                	mv	a0,s1
    800014c0:	60e2                	ld	ra,24(sp)
    800014c2:	6442                	ld	s0,16(sp)
    800014c4:	64a2                	ld	s1,8(sp)
    800014c6:	6105                	addi	sp,sp,32
    800014c8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014ca:	8f99                	sub	a5,a5,a4
    800014cc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014ce:	4685                	li	a3,1
    800014d0:	0007861b          	sext.w	a2,a5
    800014d4:	85ba                	mv	a1,a4
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	e5e080e7          	jalr	-418(ra) # 80001334 <uvmunmap>
    800014de:	b7c5                	j	800014be <uvmdealloc+0x26>

00000000800014e0 <uvmalloc>:
  if(newsz < oldsz)
    800014e0:	0ab66163          	bltu	a2,a1,80001582 <uvmalloc+0xa2>
{
    800014e4:	7139                	addi	sp,sp,-64
    800014e6:	fc06                	sd	ra,56(sp)
    800014e8:	f822                	sd	s0,48(sp)
    800014ea:	f426                	sd	s1,40(sp)
    800014ec:	f04a                	sd	s2,32(sp)
    800014ee:	ec4e                	sd	s3,24(sp)
    800014f0:	e852                	sd	s4,16(sp)
    800014f2:	e456                	sd	s5,8(sp)
    800014f4:	0080                	addi	s0,sp,64
    800014f6:	8aaa                	mv	s5,a0
    800014f8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014fa:	6785                	lui	a5,0x1
    800014fc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014fe:	95be                	add	a1,a1,a5
    80001500:	77fd                	lui	a5,0xfffff
    80001502:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001506:	08c9f063          	bgeu	s3,a2,80001586 <uvmalloc+0xa6>
    8000150a:	894e                	mv	s2,s3
    mem = kalloc();
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	6ea080e7          	jalr	1770(ra) # 80000bf6 <kalloc>
    80001514:	84aa                	mv	s1,a0
    if(mem == 0){
    80001516:	c51d                	beqz	a0,80001544 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001518:	6605                	lui	a2,0x1
    8000151a:	4581                	li	a1,0
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	8c6080e7          	jalr	-1850(ra) # 80000de2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001524:	4779                	li	a4,30
    80001526:	86a6                	mv	a3,s1
    80001528:	6605                	lui	a2,0x1
    8000152a:	85ca                	mv	a1,s2
    8000152c:	8556                	mv	a0,s5
    8000152e:	00000097          	auipc	ra,0x0
    80001532:	c82080e7          	jalr	-894(ra) # 800011b0 <mappages>
    80001536:	e905                	bnez	a0,80001566 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001538:	6785                	lui	a5,0x1
    8000153a:	993e                	add	s2,s2,a5
    8000153c:	fd4968e3          	bltu	s2,s4,8000150c <uvmalloc+0x2c>
  return newsz;
    80001540:	8552                	mv	a0,s4
    80001542:	a809                	j	80001554 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001544:	864e                	mv	a2,s3
    80001546:	85ca                	mv	a1,s2
    80001548:	8556                	mv	a0,s5
    8000154a:	00000097          	auipc	ra,0x0
    8000154e:	f4e080e7          	jalr	-178(ra) # 80001498 <uvmdealloc>
      return 0;
    80001552:	4501                	li	a0,0
}
    80001554:	70e2                	ld	ra,56(sp)
    80001556:	7442                	ld	s0,48(sp)
    80001558:	74a2                	ld	s1,40(sp)
    8000155a:	7902                	ld	s2,32(sp)
    8000155c:	69e2                	ld	s3,24(sp)
    8000155e:	6a42                	ld	s4,16(sp)
    80001560:	6aa2                	ld	s5,8(sp)
    80001562:	6121                	addi	sp,sp,64
    80001564:	8082                	ret
      kfree(mem);
    80001566:	8526                	mv	a0,s1
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	590080e7          	jalr	1424(ra) # 80000af8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001570:	864e                	mv	a2,s3
    80001572:	85ca                	mv	a1,s2
    80001574:	8556                	mv	a0,s5
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	f22080e7          	jalr	-222(ra) # 80001498 <uvmdealloc>
      return 0;
    8000157e:	4501                	li	a0,0
    80001580:	bfd1                	j	80001554 <uvmalloc+0x74>
    return oldsz;
    80001582:	852e                	mv	a0,a1
}
    80001584:	8082                	ret
  return newsz;
    80001586:	8532                	mv	a0,a2
    80001588:	b7f1                	j	80001554 <uvmalloc+0x74>

000000008000158a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000158a:	7179                	addi	sp,sp,-48
    8000158c:	f406                	sd	ra,40(sp)
    8000158e:	f022                	sd	s0,32(sp)
    80001590:	ec26                	sd	s1,24(sp)
    80001592:	e84a                	sd	s2,16(sp)
    80001594:	e44e                	sd	s3,8(sp)
    80001596:	e052                	sd	s4,0(sp)
    80001598:	1800                	addi	s0,sp,48
    8000159a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000159c:	84aa                	mv	s1,a0
    8000159e:	6905                	lui	s2,0x1
    800015a0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a2:	4985                	li	s3,1
    800015a4:	a829                	j	800015be <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015a6:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015a8:	00c79513          	slli	a0,a5,0xc
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	fde080e7          	jalr	-34(ra) # 8000158a <freewalk>
      pagetable[i] = 0;
    800015b4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015b8:	04a1                	addi	s1,s1,8
    800015ba:	03248163          	beq	s1,s2,800015dc <freewalk+0x52>
    pte_t pte = pagetable[i];
    800015be:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c0:	00f7f713          	andi	a4,a5,15
    800015c4:	ff3701e3          	beq	a4,s3,800015a6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015c8:	8b85                	andi	a5,a5,1
    800015ca:	d7fd                	beqz	a5,800015b8 <freewalk+0x2e>
      panic("freewalk: leaf");
    800015cc:	00007517          	auipc	a0,0x7
    800015d0:	b9450513          	addi	a0,a0,-1132 # 80008160 <digits+0x120>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	f74080e7          	jalr	-140(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    800015dc:	8552                	mv	a0,s4
    800015de:	fffff097          	auipc	ra,0xfffff
    800015e2:	51a080e7          	jalr	1306(ra) # 80000af8 <kfree>
}
    800015e6:	70a2                	ld	ra,40(sp)
    800015e8:	7402                	ld	s0,32(sp)
    800015ea:	64e2                	ld	s1,24(sp)
    800015ec:	6942                	ld	s2,16(sp)
    800015ee:	69a2                	ld	s3,8(sp)
    800015f0:	6a02                	ld	s4,0(sp)
    800015f2:	6145                	addi	sp,sp,48
    800015f4:	8082                	ret

00000000800015f6 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015f6:	1101                	addi	sp,sp,-32
    800015f8:	ec06                	sd	ra,24(sp)
    800015fa:	e822                	sd	s0,16(sp)
    800015fc:	e426                	sd	s1,8(sp)
    800015fe:	1000                	addi	s0,sp,32
    80001600:	84aa                	mv	s1,a0
  if(sz > 0)
    80001602:	e999                	bnez	a1,80001618 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001604:	8526                	mv	a0,s1
    80001606:	00000097          	auipc	ra,0x0
    8000160a:	f84080e7          	jalr	-124(ra) # 8000158a <freewalk>
}
    8000160e:	60e2                	ld	ra,24(sp)
    80001610:	6442                	ld	s0,16(sp)
    80001612:	64a2                	ld	s1,8(sp)
    80001614:	6105                	addi	sp,sp,32
    80001616:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001618:	6785                	lui	a5,0x1
    8000161a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000161c:	95be                	add	a1,a1,a5
    8000161e:	4685                	li	a3,1
    80001620:	00c5d613          	srli	a2,a1,0xc
    80001624:	4581                	li	a1,0
    80001626:	00000097          	auipc	ra,0x0
    8000162a:	d0e080e7          	jalr	-754(ra) # 80001334 <uvmunmap>
    8000162e:	bfd9                	j	80001604 <uvmfree+0xe>

0000000080001630 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001630:	c679                	beqz	a2,800016fe <uvmcopy+0xce>
{
    80001632:	715d                	addi	sp,sp,-80
    80001634:	e486                	sd	ra,72(sp)
    80001636:	e0a2                	sd	s0,64(sp)
    80001638:	fc26                	sd	s1,56(sp)
    8000163a:	f84a                	sd	s2,48(sp)
    8000163c:	f44e                	sd	s3,40(sp)
    8000163e:	f052                	sd	s4,32(sp)
    80001640:	ec56                	sd	s5,24(sp)
    80001642:	e85a                	sd	s6,16(sp)
    80001644:	e45e                	sd	s7,8(sp)
    80001646:	0880                	addi	s0,sp,80
    80001648:	8b2a                	mv	s6,a0
    8000164a:	8aae                	mv	s5,a1
    8000164c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001650:	4601                	li	a2,0
    80001652:	85ce                	mv	a1,s3
    80001654:	855a                	mv	a0,s6
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	a4e080e7          	jalr	-1458(ra) # 800010a4 <walk>
    8000165e:	c531                	beqz	a0,800016aa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001660:	6118                	ld	a4,0(a0)
    80001662:	00177793          	andi	a5,a4,1
    80001666:	cbb1                	beqz	a5,800016ba <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001668:	00a75593          	srli	a1,a4,0xa
    8000166c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001670:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	582080e7          	jalr	1410(ra) # 80000bf6 <kalloc>
    8000167c:	892a                	mv	s2,a0
    8000167e:	c939                	beqz	a0,800016d4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001680:	6605                	lui	a2,0x1
    80001682:	85de                	mv	a1,s7
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	7ba080e7          	jalr	1978(ra) # 80000e3e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000168c:	8726                	mv	a4,s1
    8000168e:	86ca                	mv	a3,s2
    80001690:	6605                	lui	a2,0x1
    80001692:	85ce                	mv	a1,s3
    80001694:	8556                	mv	a0,s5
    80001696:	00000097          	auipc	ra,0x0
    8000169a:	b1a080e7          	jalr	-1254(ra) # 800011b0 <mappages>
    8000169e:	e515                	bnez	a0,800016ca <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016a0:	6785                	lui	a5,0x1
    800016a2:	99be                	add	s3,s3,a5
    800016a4:	fb49e6e3          	bltu	s3,s4,80001650 <uvmcopy+0x20>
    800016a8:	a081                	j	800016e8 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016aa:	00007517          	auipc	a0,0x7
    800016ae:	ac650513          	addi	a0,a0,-1338 # 80008170 <digits+0x130>
    800016b2:	fffff097          	auipc	ra,0xfffff
    800016b6:	e96080e7          	jalr	-362(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800016ba:	00007517          	auipc	a0,0x7
    800016be:	ad650513          	addi	a0,a0,-1322 # 80008190 <digits+0x150>
    800016c2:	fffff097          	auipc	ra,0xfffff
    800016c6:	e86080e7          	jalr	-378(ra) # 80000548 <panic>
      kfree(mem);
    800016ca:	854a                	mv	a0,s2
    800016cc:	fffff097          	auipc	ra,0xfffff
    800016d0:	42c080e7          	jalr	1068(ra) # 80000af8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016d4:	4685                	li	a3,1
    800016d6:	00c9d613          	srli	a2,s3,0xc
    800016da:	4581                	li	a1,0
    800016dc:	8556                	mv	a0,s5
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	c56080e7          	jalr	-938(ra) # 80001334 <uvmunmap>
  return -1;
    800016e6:	557d                	li	a0,-1
}
    800016e8:	60a6                	ld	ra,72(sp)
    800016ea:	6406                	ld	s0,64(sp)
    800016ec:	74e2                	ld	s1,56(sp)
    800016ee:	7942                	ld	s2,48(sp)
    800016f0:	79a2                	ld	s3,40(sp)
    800016f2:	7a02                	ld	s4,32(sp)
    800016f4:	6ae2                	ld	s5,24(sp)
    800016f6:	6b42                	ld	s6,16(sp)
    800016f8:	6ba2                	ld	s7,8(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret
  return 0;
    800016fe:	4501                	li	a0,0
}
    80001700:	8082                	ret

0000000080001702 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001702:	1141                	addi	sp,sp,-16
    80001704:	e406                	sd	ra,8(sp)
    80001706:	e022                	sd	s0,0(sp)
    80001708:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000170a:	4601                	li	a2,0
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	998080e7          	jalr	-1640(ra) # 800010a4 <walk>
  if(pte == 0)
    80001714:	c901                	beqz	a0,80001724 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001716:	611c                	ld	a5,0(a0)
    80001718:	9bbd                	andi	a5,a5,-17
    8000171a:	e11c                	sd	a5,0(a0)
}
    8000171c:	60a2                	ld	ra,8(sp)
    8000171e:	6402                	ld	s0,0(sp)
    80001720:	0141                	addi	sp,sp,16
    80001722:	8082                	ret
    panic("uvmclear");
    80001724:	00007517          	auipc	a0,0x7
    80001728:	a8c50513          	addi	a0,a0,-1396 # 800081b0 <digits+0x170>
    8000172c:	fffff097          	auipc	ra,0xfffff
    80001730:	e1c080e7          	jalr	-484(ra) # 80000548 <panic>

0000000080001734 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001734:	c6bd                	beqz	a3,800017a2 <copyout+0x6e>
{
    80001736:	715d                	addi	sp,sp,-80
    80001738:	e486                	sd	ra,72(sp)
    8000173a:	e0a2                	sd	s0,64(sp)
    8000173c:	fc26                	sd	s1,56(sp)
    8000173e:	f84a                	sd	s2,48(sp)
    80001740:	f44e                	sd	s3,40(sp)
    80001742:	f052                	sd	s4,32(sp)
    80001744:	ec56                	sd	s5,24(sp)
    80001746:	e85a                	sd	s6,16(sp)
    80001748:	e45e                	sd	s7,8(sp)
    8000174a:	e062                	sd	s8,0(sp)
    8000174c:	0880                	addi	s0,sp,80
    8000174e:	8b2a                	mv	s6,a0
    80001750:	8c2e                	mv	s8,a1
    80001752:	8a32                	mv	s4,a2
    80001754:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001756:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001758:	6a85                	lui	s5,0x1
    8000175a:	a015                	j	8000177e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000175c:	9562                	add	a0,a0,s8
    8000175e:	0004861b          	sext.w	a2,s1
    80001762:	85d2                	mv	a1,s4
    80001764:	41250533          	sub	a0,a0,s2
    80001768:	fffff097          	auipc	ra,0xfffff
    8000176c:	6d6080e7          	jalr	1750(ra) # 80000e3e <memmove>

    len -= n;
    80001770:	409989b3          	sub	s3,s3,s1
    src += n;
    80001774:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001776:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000177a:	02098263          	beqz	s3,8000179e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000177e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001782:	85ca                	mv	a1,s2
    80001784:	855a                	mv	a0,s6
    80001786:	00000097          	auipc	ra,0x0
    8000178a:	9e8080e7          	jalr	-1560(ra) # 8000116e <walkaddr>
    if(pa0 == 0)
    8000178e:	cd01                	beqz	a0,800017a6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001790:	418904b3          	sub	s1,s2,s8
    80001794:	94d6                	add	s1,s1,s5
    80001796:	fc99f3e3          	bgeu	s3,s1,8000175c <copyout+0x28>
    8000179a:	84ce                	mv	s1,s3
    8000179c:	b7c1                	j	8000175c <copyout+0x28>
  }
  return 0;
    8000179e:	4501                	li	a0,0
    800017a0:	a021                	j	800017a8 <copyout+0x74>
    800017a2:	4501                	li	a0,0
}
    800017a4:	8082                	ret
      return -1;
    800017a6:	557d                	li	a0,-1
}
    800017a8:	60a6                	ld	ra,72(sp)
    800017aa:	6406                	ld	s0,64(sp)
    800017ac:	74e2                	ld	s1,56(sp)
    800017ae:	7942                	ld	s2,48(sp)
    800017b0:	79a2                	ld	s3,40(sp)
    800017b2:	7a02                	ld	s4,32(sp)
    800017b4:	6ae2                	ld	s5,24(sp)
    800017b6:	6b42                	ld	s6,16(sp)
    800017b8:	6ba2                	ld	s7,8(sp)
    800017ba:	6c02                	ld	s8,0(sp)
    800017bc:	6161                	addi	sp,sp,80
    800017be:	8082                	ret

00000000800017c0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017c0:	caa5                	beqz	a3,80001830 <copyin+0x70>
{
    800017c2:	715d                	addi	sp,sp,-80
    800017c4:	e486                	sd	ra,72(sp)
    800017c6:	e0a2                	sd	s0,64(sp)
    800017c8:	fc26                	sd	s1,56(sp)
    800017ca:	f84a                	sd	s2,48(sp)
    800017cc:	f44e                	sd	s3,40(sp)
    800017ce:	f052                	sd	s4,32(sp)
    800017d0:	ec56                	sd	s5,24(sp)
    800017d2:	e85a                	sd	s6,16(sp)
    800017d4:	e45e                	sd	s7,8(sp)
    800017d6:	e062                	sd	s8,0(sp)
    800017d8:	0880                	addi	s0,sp,80
    800017da:	8b2a                	mv	s6,a0
    800017dc:	8a2e                	mv	s4,a1
    800017de:	8c32                	mv	s8,a2
    800017e0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017e2:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e4:	6a85                	lui	s5,0x1
    800017e6:	a01d                	j	8000180c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017e8:	018505b3          	add	a1,a0,s8
    800017ec:	0004861b          	sext.w	a2,s1
    800017f0:	412585b3          	sub	a1,a1,s2
    800017f4:	8552                	mv	a0,s4
    800017f6:	fffff097          	auipc	ra,0xfffff
    800017fa:	648080e7          	jalr	1608(ra) # 80000e3e <memmove>

    len -= n;
    800017fe:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001802:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001804:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001808:	02098263          	beqz	s3,8000182c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000180c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001810:	85ca                	mv	a1,s2
    80001812:	855a                	mv	a0,s6
    80001814:	00000097          	auipc	ra,0x0
    80001818:	95a080e7          	jalr	-1702(ra) # 8000116e <walkaddr>
    if(pa0 == 0)
    8000181c:	cd01                	beqz	a0,80001834 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000181e:	418904b3          	sub	s1,s2,s8
    80001822:	94d6                	add	s1,s1,s5
    80001824:	fc99f2e3          	bgeu	s3,s1,800017e8 <copyin+0x28>
    80001828:	84ce                	mv	s1,s3
    8000182a:	bf7d                	j	800017e8 <copyin+0x28>
  }
  return 0;
    8000182c:	4501                	li	a0,0
    8000182e:	a021                	j	80001836 <copyin+0x76>
    80001830:	4501                	li	a0,0
}
    80001832:	8082                	ret
      return -1;
    80001834:	557d                	li	a0,-1
}
    80001836:	60a6                	ld	ra,72(sp)
    80001838:	6406                	ld	s0,64(sp)
    8000183a:	74e2                	ld	s1,56(sp)
    8000183c:	7942                	ld	s2,48(sp)
    8000183e:	79a2                	ld	s3,40(sp)
    80001840:	7a02                	ld	s4,32(sp)
    80001842:	6ae2                	ld	s5,24(sp)
    80001844:	6b42                	ld	s6,16(sp)
    80001846:	6ba2                	ld	s7,8(sp)
    80001848:	6c02                	ld	s8,0(sp)
    8000184a:	6161                	addi	sp,sp,80
    8000184c:	8082                	ret

000000008000184e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000184e:	c2dd                	beqz	a3,800018f4 <copyinstr+0xa6>
{
    80001850:	715d                	addi	sp,sp,-80
    80001852:	e486                	sd	ra,72(sp)
    80001854:	e0a2                	sd	s0,64(sp)
    80001856:	fc26                	sd	s1,56(sp)
    80001858:	f84a                	sd	s2,48(sp)
    8000185a:	f44e                	sd	s3,40(sp)
    8000185c:	f052                	sd	s4,32(sp)
    8000185e:	ec56                	sd	s5,24(sp)
    80001860:	e85a                	sd	s6,16(sp)
    80001862:	e45e                	sd	s7,8(sp)
    80001864:	0880                	addi	s0,sp,80
    80001866:	8a2a                	mv	s4,a0
    80001868:	8b2e                	mv	s6,a1
    8000186a:	8bb2                	mv	s7,a2
    8000186c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000186e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001870:	6985                	lui	s3,0x1
    80001872:	a02d                	j	8000189c <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001874:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001878:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000187a:	37fd                	addiw	a5,a5,-1
    8000187c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001880:	60a6                	ld	ra,72(sp)
    80001882:	6406                	ld	s0,64(sp)
    80001884:	74e2                	ld	s1,56(sp)
    80001886:	7942                	ld	s2,48(sp)
    80001888:	79a2                	ld	s3,40(sp)
    8000188a:	7a02                	ld	s4,32(sp)
    8000188c:	6ae2                	ld	s5,24(sp)
    8000188e:	6b42                	ld	s6,16(sp)
    80001890:	6ba2                	ld	s7,8(sp)
    80001892:	6161                	addi	sp,sp,80
    80001894:	8082                	ret
    srcva = va0 + PGSIZE;
    80001896:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000189a:	c8a9                	beqz	s1,800018ec <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000189c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018a0:	85ca                	mv	a1,s2
    800018a2:	8552                	mv	a0,s4
    800018a4:	00000097          	auipc	ra,0x0
    800018a8:	8ca080e7          	jalr	-1846(ra) # 8000116e <walkaddr>
    if(pa0 == 0)
    800018ac:	c131                	beqz	a0,800018f0 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800018ae:	417906b3          	sub	a3,s2,s7
    800018b2:	96ce                	add	a3,a3,s3
    800018b4:	00d4f363          	bgeu	s1,a3,800018ba <copyinstr+0x6c>
    800018b8:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018ba:	955e                	add	a0,a0,s7
    800018bc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018c0:	daf9                	beqz	a3,80001896 <copyinstr+0x48>
    800018c2:	87da                	mv	a5,s6
    800018c4:	885a                	mv	a6,s6
      if(*p == '\0'){
    800018c6:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800018ca:	96da                	add	a3,a3,s6
    800018cc:	85be                	mv	a1,a5
      if(*p == '\0'){
    800018ce:	00f60733          	add	a4,a2,a5
    800018d2:	00074703          	lbu	a4,0(a4)
    800018d6:	df59                	beqz	a4,80001874 <copyinstr+0x26>
        *dst = *p;
    800018d8:	00e78023          	sb	a4,0(a5)
      dst++;
    800018dc:	0785                	addi	a5,a5,1
    while(n > 0){
    800018de:	fed797e3          	bne	a5,a3,800018cc <copyinstr+0x7e>
    800018e2:	14fd                	addi	s1,s1,-1
    800018e4:	94c2                	add	s1,s1,a6
      --max;
    800018e6:	8c8d                	sub	s1,s1,a1
      dst++;
    800018e8:	8b3e                	mv	s6,a5
    800018ea:	b775                	j	80001896 <copyinstr+0x48>
    800018ec:	4781                	li	a5,0
    800018ee:	b771                	j	8000187a <copyinstr+0x2c>
      return -1;
    800018f0:	557d                	li	a0,-1
    800018f2:	b779                	j	80001880 <copyinstr+0x32>
  int got_null = 0;
    800018f4:	4781                	li	a5,0
  if(got_null){
    800018f6:	37fd                	addiw	a5,a5,-1
    800018f8:	0007851b          	sext.w	a0,a5
}
    800018fc:	8082                	ret

00000000800018fe <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018fe:	1101                	addi	sp,sp,-32
    80001900:	ec06                	sd	ra,24(sp)
    80001902:	e822                	sd	s0,16(sp)
    80001904:	e426                	sd	s1,8(sp)
    80001906:	1000                	addi	s0,sp,32
    80001908:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	362080e7          	jalr	866(ra) # 80000c6c <holding>
    80001912:	c909                	beqz	a0,80001924 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001914:	749c                	ld	a5,40(s1)
    80001916:	00978f63          	beq	a5,s1,80001934 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    8000191a:	60e2                	ld	ra,24(sp)
    8000191c:	6442                	ld	s0,16(sp)
    8000191e:	64a2                	ld	s1,8(sp)
    80001920:	6105                	addi	sp,sp,32
    80001922:	8082                	ret
    panic("wakeup1");
    80001924:	00007517          	auipc	a0,0x7
    80001928:	89c50513          	addi	a0,a0,-1892 # 800081c0 <digits+0x180>
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	c1c080e7          	jalr	-996(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001934:	4c98                	lw	a4,24(s1)
    80001936:	4785                	li	a5,1
    80001938:	fef711e3          	bne	a4,a5,8000191a <wakeup1+0x1c>
    p->state = RUNNABLE;
    8000193c:	4789                	li	a5,2
    8000193e:	cc9c                	sw	a5,24(s1)
}
    80001940:	bfe9                	j	8000191a <wakeup1+0x1c>

0000000080001942 <procinit>:
{
    80001942:	715d                	addi	sp,sp,-80
    80001944:	e486                	sd	ra,72(sp)
    80001946:	e0a2                	sd	s0,64(sp)
    80001948:	fc26                	sd	s1,56(sp)
    8000194a:	f84a                	sd	s2,48(sp)
    8000194c:	f44e                	sd	s3,40(sp)
    8000194e:	f052                	sd	s4,32(sp)
    80001950:	ec56                	sd	s5,24(sp)
    80001952:	e85a                	sd	s6,16(sp)
    80001954:	e45e                	sd	s7,8(sp)
    80001956:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001958:	00007597          	auipc	a1,0x7
    8000195c:	87058593          	addi	a1,a1,-1936 # 800081c8 <digits+0x188>
    80001960:	00010517          	auipc	a0,0x10
    80001964:	93050513          	addi	a0,a0,-1744 # 80011290 <pid_lock>
    80001968:	fffff097          	auipc	ra,0xfffff
    8000196c:	2ee080e7          	jalr	750(ra) # 80000c56 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001970:	00010917          	auipc	s2,0x10
    80001974:	d3890913          	addi	s2,s2,-712 # 800116a8 <proc>
      initlock(&p->lock, "proc");
    80001978:	00007b97          	auipc	s7,0x7
    8000197c:	858b8b93          	addi	s7,s7,-1960 # 800081d0 <digits+0x190>
      uint64 va = KSTACK((int) (p - proc));
    80001980:	8b4a                	mv	s6,s2
    80001982:	00006a97          	auipc	s5,0x6
    80001986:	67ea8a93          	addi	s5,s5,1662 # 80008000 <etext>
    8000198a:	040009b7          	lui	s3,0x4000
    8000198e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001990:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001992:	00015a17          	auipc	s4,0x15
    80001996:	716a0a13          	addi	s4,s4,1814 # 800170a8 <tickslock>
      initlock(&p->lock, "proc");
    8000199a:	85de                	mv	a1,s7
    8000199c:	854a                	mv	a0,s2
    8000199e:	fffff097          	auipc	ra,0xfffff
    800019a2:	2b8080e7          	jalr	696(ra) # 80000c56 <initlock>
      char *pa = kalloc();
    800019a6:	fffff097          	auipc	ra,0xfffff
    800019aa:	250080e7          	jalr	592(ra) # 80000bf6 <kalloc>
    800019ae:	85aa                	mv	a1,a0
      if(pa == 0)
    800019b0:	c929                	beqz	a0,80001a02 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019b2:	416904b3          	sub	s1,s2,s6
    800019b6:	848d                	srai	s1,s1,0x3
    800019b8:	000ab783          	ld	a5,0(s5)
    800019bc:	02f484b3          	mul	s1,s1,a5
    800019c0:	2485                	addiw	s1,s1,1
    800019c2:	00d4949b          	slliw	s1,s1,0xd
    800019c6:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ca:	4699                	li	a3,6
    800019cc:	6605                	lui	a2,0x1
    800019ce:	8526                	mv	a0,s1
    800019d0:	00000097          	auipc	ra,0x0
    800019d4:	86e080e7          	jalr	-1938(ra) # 8000123e <kvmmap>
      p->kstack = va;
    800019d8:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019dc:	16890913          	addi	s2,s2,360
    800019e0:	fb491de3          	bne	s2,s4,8000199a <procinit+0x58>
  kvminithart();
    800019e4:	fffff097          	auipc	ra,0xfffff
    800019e8:	766080e7          	jalr	1894(ra) # 8000114a <kvminithart>
}
    800019ec:	60a6                	ld	ra,72(sp)
    800019ee:	6406                	ld	s0,64(sp)
    800019f0:	74e2                	ld	s1,56(sp)
    800019f2:	7942                	ld	s2,48(sp)
    800019f4:	79a2                	ld	s3,40(sp)
    800019f6:	7a02                	ld	s4,32(sp)
    800019f8:	6ae2                	ld	s5,24(sp)
    800019fa:	6b42                	ld	s6,16(sp)
    800019fc:	6ba2                	ld	s7,8(sp)
    800019fe:	6161                	addi	sp,sp,80
    80001a00:	8082                	ret
        panic("kalloc");
    80001a02:	00006517          	auipc	a0,0x6
    80001a06:	7d650513          	addi	a0,a0,2006 # 800081d8 <digits+0x198>
    80001a0a:	fffff097          	auipc	ra,0xfffff
    80001a0e:	b3e080e7          	jalr	-1218(ra) # 80000548 <panic>

0000000080001a12 <cpuid>:
{
    80001a12:	1141                	addi	sp,sp,-16
    80001a14:	e422                	sd	s0,8(sp)
    80001a16:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a18:	8512                	mv	a0,tp
}
    80001a1a:	2501                	sext.w	a0,a0
    80001a1c:	6422                	ld	s0,8(sp)
    80001a1e:	0141                	addi	sp,sp,16
    80001a20:	8082                	ret

0000000080001a22 <mycpu>:
mycpu(void) {
    80001a22:	1141                	addi	sp,sp,-16
    80001a24:	e422                	sd	s0,8(sp)
    80001a26:	0800                	addi	s0,sp,16
    80001a28:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a2a:	2781                	sext.w	a5,a5
    80001a2c:	079e                	slli	a5,a5,0x7
}
    80001a2e:	00010517          	auipc	a0,0x10
    80001a32:	87a50513          	addi	a0,a0,-1926 # 800112a8 <cpus>
    80001a36:	953e                	add	a0,a0,a5
    80001a38:	6422                	ld	s0,8(sp)
    80001a3a:	0141                	addi	sp,sp,16
    80001a3c:	8082                	ret

0000000080001a3e <myproc>:
myproc(void) {
    80001a3e:	1101                	addi	sp,sp,-32
    80001a40:	ec06                	sd	ra,24(sp)
    80001a42:	e822                	sd	s0,16(sp)
    80001a44:	e426                	sd	s1,8(sp)
    80001a46:	1000                	addi	s0,sp,32
  push_off();
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	252080e7          	jalr	594(ra) # 80000c9a <push_off>
    80001a50:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a52:	2781                	sext.w	a5,a5
    80001a54:	079e                	slli	a5,a5,0x7
    80001a56:	00010717          	auipc	a4,0x10
    80001a5a:	83a70713          	addi	a4,a4,-1990 # 80011290 <pid_lock>
    80001a5e:	97ba                	add	a5,a5,a4
    80001a60:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	2d8080e7          	jalr	728(ra) # 80000d3a <pop_off>
}
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	6105                	addi	sp,sp,32
    80001a74:	8082                	ret

0000000080001a76 <forkret>:
{
    80001a76:	1141                	addi	sp,sp,-16
    80001a78:	e406                	sd	ra,8(sp)
    80001a7a:	e022                	sd	s0,0(sp)
    80001a7c:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	fc0080e7          	jalr	-64(ra) # 80001a3e <myproc>
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	314080e7          	jalr	788(ra) # 80000d9a <release>
  if (first) {
    80001a8e:	00007797          	auipc	a5,0x7
    80001a92:	d727a783          	lw	a5,-654(a5) # 80008800 <first.1>
    80001a96:	eb89                	bnez	a5,80001aa8 <forkret+0x32>
  usertrapret();
    80001a98:	00001097          	auipc	ra,0x1
    80001a9c:	c1c080e7          	jalr	-996(ra) # 800026b4 <usertrapret>
}
    80001aa0:	60a2                	ld	ra,8(sp)
    80001aa2:	6402                	ld	s0,0(sp)
    80001aa4:	0141                	addi	sp,sp,16
    80001aa6:	8082                	ret
    first = 0;
    80001aa8:	00007797          	auipc	a5,0x7
    80001aac:	d407ac23          	sw	zero,-680(a5) # 80008800 <first.1>
    fsinit(ROOTDEV);
    80001ab0:	4505                	li	a0,1
    80001ab2:	00002097          	auipc	ra,0x2
    80001ab6:	944080e7          	jalr	-1724(ra) # 800033f6 <fsinit>
    80001aba:	bff9                	j	80001a98 <forkret+0x22>

0000000080001abc <allocpid>:
allocpid() {
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	e04a                	sd	s2,0(sp)
    80001ac6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ac8:	0000f917          	auipc	s2,0xf
    80001acc:	7c890913          	addi	s2,s2,1992 # 80011290 <pid_lock>
    80001ad0:	854a                	mv	a0,s2
    80001ad2:	fffff097          	auipc	ra,0xfffff
    80001ad6:	214080e7          	jalr	532(ra) # 80000ce6 <acquire>
  pid = nextpid;
    80001ada:	00007797          	auipc	a5,0x7
    80001ade:	d2a78793          	addi	a5,a5,-726 # 80008804 <nextpid>
    80001ae2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ae4:	0014871b          	addiw	a4,s1,1
    80001ae8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aea:	854a                	mv	a0,s2
    80001aec:	fffff097          	auipc	ra,0xfffff
    80001af0:	2ae080e7          	jalr	686(ra) # 80000d9a <release>
}
    80001af4:	8526                	mv	a0,s1
    80001af6:	60e2                	ld	ra,24(sp)
    80001af8:	6442                	ld	s0,16(sp)
    80001afa:	64a2                	ld	s1,8(sp)
    80001afc:	6902                	ld	s2,0(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret

0000000080001b02 <proc_pagetable>:
{
    80001b02:	1101                	addi	sp,sp,-32
    80001b04:	ec06                	sd	ra,24(sp)
    80001b06:	e822                	sd	s0,16(sp)
    80001b08:	e426                	sd	s1,8(sp)
    80001b0a:	e04a                	sd	s2,0(sp)
    80001b0c:	1000                	addi	s0,sp,32
    80001b0e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b10:	00000097          	auipc	ra,0x0
    80001b14:	8e8080e7          	jalr	-1816(ra) # 800013f8 <uvmcreate>
    80001b18:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b1a:	c121                	beqz	a0,80001b5a <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b1c:	4729                	li	a4,10
    80001b1e:	00005697          	auipc	a3,0x5
    80001b22:	4e268693          	addi	a3,a3,1250 # 80007000 <_trampoline>
    80001b26:	6605                	lui	a2,0x1
    80001b28:	040005b7          	lui	a1,0x4000
    80001b2c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b2e:	05b2                	slli	a1,a1,0xc
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	680080e7          	jalr	1664(ra) # 800011b0 <mappages>
    80001b38:	02054863          	bltz	a0,80001b68 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b3c:	4719                	li	a4,6
    80001b3e:	05893683          	ld	a3,88(s2)
    80001b42:	6605                	lui	a2,0x1
    80001b44:	020005b7          	lui	a1,0x2000
    80001b48:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b4a:	05b6                	slli	a1,a1,0xd
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	662080e7          	jalr	1634(ra) # 800011b0 <mappages>
    80001b56:	02054163          	bltz	a0,80001b78 <proc_pagetable+0x76>
}
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	60e2                	ld	ra,24(sp)
    80001b5e:	6442                	ld	s0,16(sp)
    80001b60:	64a2                	ld	s1,8(sp)
    80001b62:	6902                	ld	s2,0(sp)
    80001b64:	6105                	addi	sp,sp,32
    80001b66:	8082                	ret
    uvmfree(pagetable, 0);
    80001b68:	4581                	li	a1,0
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	00000097          	auipc	ra,0x0
    80001b70:	a8a080e7          	jalr	-1398(ra) # 800015f6 <uvmfree>
    return 0;
    80001b74:	4481                	li	s1,0
    80001b76:	b7d5                	j	80001b5a <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b78:	4681                	li	a3,0
    80001b7a:	4605                	li	a2,1
    80001b7c:	040005b7          	lui	a1,0x4000
    80001b80:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b82:	05b2                	slli	a1,a1,0xc
    80001b84:	8526                	mv	a0,s1
    80001b86:	fffff097          	auipc	ra,0xfffff
    80001b8a:	7ae080e7          	jalr	1966(ra) # 80001334 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b8e:	4581                	li	a1,0
    80001b90:	8526                	mv	a0,s1
    80001b92:	00000097          	auipc	ra,0x0
    80001b96:	a64080e7          	jalr	-1436(ra) # 800015f6 <uvmfree>
    return 0;
    80001b9a:	4481                	li	s1,0
    80001b9c:	bf7d                	j	80001b5a <proc_pagetable+0x58>

0000000080001b9e <proc_freepagetable>:
{
    80001b9e:	1101                	addi	sp,sp,-32
    80001ba0:	ec06                	sd	ra,24(sp)
    80001ba2:	e822                	sd	s0,16(sp)
    80001ba4:	e426                	sd	s1,8(sp)
    80001ba6:	e04a                	sd	s2,0(sp)
    80001ba8:	1000                	addi	s0,sp,32
    80001baa:	84aa                	mv	s1,a0
    80001bac:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bae:	4681                	li	a3,0
    80001bb0:	4605                	li	a2,1
    80001bb2:	040005b7          	lui	a1,0x4000
    80001bb6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bb8:	05b2                	slli	a1,a1,0xc
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	77a080e7          	jalr	1914(ra) # 80001334 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bc2:	4681                	li	a3,0
    80001bc4:	4605                	li	a2,1
    80001bc6:	020005b7          	lui	a1,0x2000
    80001bca:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bcc:	05b6                	slli	a1,a1,0xd
    80001bce:	8526                	mv	a0,s1
    80001bd0:	fffff097          	auipc	ra,0xfffff
    80001bd4:	764080e7          	jalr	1892(ra) # 80001334 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bd8:	85ca                	mv	a1,s2
    80001bda:	8526                	mv	a0,s1
    80001bdc:	00000097          	auipc	ra,0x0
    80001be0:	a1a080e7          	jalr	-1510(ra) # 800015f6 <uvmfree>
}
    80001be4:	60e2                	ld	ra,24(sp)
    80001be6:	6442                	ld	s0,16(sp)
    80001be8:	64a2                	ld	s1,8(sp)
    80001bea:	6902                	ld	s2,0(sp)
    80001bec:	6105                	addi	sp,sp,32
    80001bee:	8082                	ret

0000000080001bf0 <freeproc>:
{
    80001bf0:	1101                	addi	sp,sp,-32
    80001bf2:	ec06                	sd	ra,24(sp)
    80001bf4:	e822                	sd	s0,16(sp)
    80001bf6:	e426                	sd	s1,8(sp)
    80001bf8:	1000                	addi	s0,sp,32
    80001bfa:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bfc:	6d28                	ld	a0,88(a0)
    80001bfe:	c509                	beqz	a0,80001c08 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	ef8080e7          	jalr	-264(ra) # 80000af8 <kfree>
  p->trapframe = 0;
    80001c08:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c0c:	68a8                	ld	a0,80(s1)
    80001c0e:	c511                	beqz	a0,80001c1a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c10:	64ac                	ld	a1,72(s1)
    80001c12:	00000097          	auipc	ra,0x0
    80001c16:	f8c080e7          	jalr	-116(ra) # 80001b9e <proc_freepagetable>
  p->pagetable = 0;
    80001c1a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c1e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c22:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c26:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c2a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c2e:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c32:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c36:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c3a:	0004ac23          	sw	zero,24(s1)
}
    80001c3e:	60e2                	ld	ra,24(sp)
    80001c40:	6442                	ld	s0,16(sp)
    80001c42:	64a2                	ld	s1,8(sp)
    80001c44:	6105                	addi	sp,sp,32
    80001c46:	8082                	ret

0000000080001c48 <allocproc>:
{
    80001c48:	1101                	addi	sp,sp,-32
    80001c4a:	ec06                	sd	ra,24(sp)
    80001c4c:	e822                	sd	s0,16(sp)
    80001c4e:	e426                	sd	s1,8(sp)
    80001c50:	e04a                	sd	s2,0(sp)
    80001c52:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c54:	00010497          	auipc	s1,0x10
    80001c58:	a5448493          	addi	s1,s1,-1452 # 800116a8 <proc>
    80001c5c:	00015917          	auipc	s2,0x15
    80001c60:	44c90913          	addi	s2,s2,1100 # 800170a8 <tickslock>
    acquire(&p->lock);
    80001c64:	8526                	mv	a0,s1
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	080080e7          	jalr	128(ra) # 80000ce6 <acquire>
    if(p->state == UNUSED) {
    80001c6e:	4c9c                	lw	a5,24(s1)
    80001c70:	cf81                	beqz	a5,80001c88 <allocproc+0x40>
      release(&p->lock);
    80001c72:	8526                	mv	a0,s1
    80001c74:	fffff097          	auipc	ra,0xfffff
    80001c78:	126080e7          	jalr	294(ra) # 80000d9a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c7c:	16848493          	addi	s1,s1,360
    80001c80:	ff2492e3          	bne	s1,s2,80001c64 <allocproc+0x1c>
  return 0;
    80001c84:	4481                	li	s1,0
    80001c86:	a0b9                	j	80001cd4 <allocproc+0x8c>
  p->pid = allocpid();
    80001c88:	00000097          	auipc	ra,0x0
    80001c8c:	e34080e7          	jalr	-460(ra) # 80001abc <allocpid>
    80001c90:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	f64080e7          	jalr	-156(ra) # 80000bf6 <kalloc>
    80001c9a:	892a                	mv	s2,a0
    80001c9c:	eca8                	sd	a0,88(s1)
    80001c9e:	c131                	beqz	a0,80001ce2 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	00000097          	auipc	ra,0x0
    80001ca6:	e60080e7          	jalr	-416(ra) # 80001b02 <proc_pagetable>
    80001caa:	892a                	mv	s2,a0
    80001cac:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cae:	c129                	beqz	a0,80001cf0 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001cb0:	07000613          	li	a2,112
    80001cb4:	4581                	li	a1,0
    80001cb6:	06048513          	addi	a0,s1,96
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	128080e7          	jalr	296(ra) # 80000de2 <memset>
  p->context.ra = (uint64)forkret;
    80001cc2:	00000797          	auipc	a5,0x0
    80001cc6:	db478793          	addi	a5,a5,-588 # 80001a76 <forkret>
    80001cca:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ccc:	60bc                	ld	a5,64(s1)
    80001cce:	6705                	lui	a4,0x1
    80001cd0:	97ba                	add	a5,a5,a4
    80001cd2:	f4bc                	sd	a5,104(s1)
}
    80001cd4:	8526                	mv	a0,s1
    80001cd6:	60e2                	ld	ra,24(sp)
    80001cd8:	6442                	ld	s0,16(sp)
    80001cda:	64a2                	ld	s1,8(sp)
    80001cdc:	6902                	ld	s2,0(sp)
    80001cde:	6105                	addi	sp,sp,32
    80001ce0:	8082                	ret
    release(&p->lock);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	0b6080e7          	jalr	182(ra) # 80000d9a <release>
    return 0;
    80001cec:	84ca                	mv	s1,s2
    80001cee:	b7dd                	j	80001cd4 <allocproc+0x8c>
    freeproc(p);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	efe080e7          	jalr	-258(ra) # 80001bf0 <freeproc>
    release(&p->lock);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	09e080e7          	jalr	158(ra) # 80000d9a <release>
    return 0;
    80001d04:	84ca                	mv	s1,s2
    80001d06:	b7f9                	j	80001cd4 <allocproc+0x8c>

0000000080001d08 <userinit>:
{
    80001d08:	1101                	addi	sp,sp,-32
    80001d0a:	ec06                	sd	ra,24(sp)
    80001d0c:	e822                	sd	s0,16(sp)
    80001d0e:	e426                	sd	s1,8(sp)
    80001d10:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	f36080e7          	jalr	-202(ra) # 80001c48 <allocproc>
    80001d1a:	84aa                	mv	s1,a0
  initproc = p;
    80001d1c:	00007797          	auipc	a5,0x7
    80001d20:	30a7b223          	sd	a0,772(a5) # 80009020 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d24:	03400613          	li	a2,52
    80001d28:	00007597          	auipc	a1,0x7
    80001d2c:	ae858593          	addi	a1,a1,-1304 # 80008810 <initcode>
    80001d30:	6928                	ld	a0,80(a0)
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	6f4080e7          	jalr	1780(ra) # 80001426 <uvminit>
  p->sz = PGSIZE;
    80001d3a:	6785                	lui	a5,0x1
    80001d3c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d3e:	6cb8                	ld	a4,88(s1)
    80001d40:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d44:	6cb8                	ld	a4,88(s1)
    80001d46:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d48:	4641                	li	a2,16
    80001d4a:	00006597          	auipc	a1,0x6
    80001d4e:	49658593          	addi	a1,a1,1174 # 800081e0 <digits+0x1a0>
    80001d52:	15848513          	addi	a0,s1,344
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	1dc080e7          	jalr	476(ra) # 80000f32 <safestrcpy>
  p->cwd = namei("/");
    80001d5e:	00006517          	auipc	a0,0x6
    80001d62:	49250513          	addi	a0,a0,1170 # 800081f0 <digits+0x1b0>
    80001d66:	00002097          	auipc	ra,0x2
    80001d6a:	0b8080e7          	jalr	184(ra) # 80003e1e <namei>
    80001d6e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d72:	4789                	li	a5,2
    80001d74:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	022080e7          	jalr	34(ra) # 80000d9a <release>
}
    80001d80:	60e2                	ld	ra,24(sp)
    80001d82:	6442                	ld	s0,16(sp)
    80001d84:	64a2                	ld	s1,8(sp)
    80001d86:	6105                	addi	sp,sp,32
    80001d88:	8082                	ret

0000000080001d8a <growproc>:
{
    80001d8a:	1101                	addi	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	e04a                	sd	s2,0(sp)
    80001d94:	1000                	addi	s0,sp,32
    80001d96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	ca6080e7          	jalr	-858(ra) # 80001a3e <myproc>
    80001da0:	892a                	mv	s2,a0
  sz = p->sz;
    80001da2:	652c                	ld	a1,72(a0)
    80001da4:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001da8:	00904f63          	bgtz	s1,80001dc6 <growproc+0x3c>
  } else if(n < 0){
    80001dac:	0204cd63          	bltz	s1,80001de6 <growproc+0x5c>
  p->sz = sz;
    80001db0:	1782                	slli	a5,a5,0x20
    80001db2:	9381                	srli	a5,a5,0x20
    80001db4:	04f93423          	sd	a5,72(s2)
  return 0;
    80001db8:	4501                	li	a0,0
}
    80001dba:	60e2                	ld	ra,24(sp)
    80001dbc:	6442                	ld	s0,16(sp)
    80001dbe:	64a2                	ld	s1,8(sp)
    80001dc0:	6902                	ld	s2,0(sp)
    80001dc2:	6105                	addi	sp,sp,32
    80001dc4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dc6:	00f4863b          	addw	a2,s1,a5
    80001dca:	1602                	slli	a2,a2,0x20
    80001dcc:	9201                	srli	a2,a2,0x20
    80001dce:	1582                	slli	a1,a1,0x20
    80001dd0:	9181                	srli	a1,a1,0x20
    80001dd2:	6928                	ld	a0,80(a0)
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	70c080e7          	jalr	1804(ra) # 800014e0 <uvmalloc>
    80001ddc:	0005079b          	sext.w	a5,a0
    80001de0:	fbe1                	bnez	a5,80001db0 <growproc+0x26>
      return -1;
    80001de2:	557d                	li	a0,-1
    80001de4:	bfd9                	j	80001dba <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001de6:	00f4863b          	addw	a2,s1,a5
    80001dea:	1602                	slli	a2,a2,0x20
    80001dec:	9201                	srli	a2,a2,0x20
    80001dee:	1582                	slli	a1,a1,0x20
    80001df0:	9181                	srli	a1,a1,0x20
    80001df2:	6928                	ld	a0,80(a0)
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	6a4080e7          	jalr	1700(ra) # 80001498 <uvmdealloc>
    80001dfc:	0005079b          	sext.w	a5,a0
    80001e00:	bf45                	j	80001db0 <growproc+0x26>

0000000080001e02 <fork>:
{
    80001e02:	7139                	addi	sp,sp,-64
    80001e04:	fc06                	sd	ra,56(sp)
    80001e06:	f822                	sd	s0,48(sp)
    80001e08:	f426                	sd	s1,40(sp)
    80001e0a:	f04a                	sd	s2,32(sp)
    80001e0c:	ec4e                	sd	s3,24(sp)
    80001e0e:	e852                	sd	s4,16(sp)
    80001e10:	e456                	sd	s5,8(sp)
    80001e12:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	c2a080e7          	jalr	-982(ra) # 80001a3e <myproc>
    80001e1c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	e2a080e7          	jalr	-470(ra) # 80001c48 <allocproc>
    80001e26:	c17d                	beqz	a0,80001f0c <fork+0x10a>
    80001e28:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e2a:	048ab603          	ld	a2,72(s5)
    80001e2e:	692c                	ld	a1,80(a0)
    80001e30:	050ab503          	ld	a0,80(s5)
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	7fc080e7          	jalr	2044(ra) # 80001630 <uvmcopy>
    80001e3c:	04054a63          	bltz	a0,80001e90 <fork+0x8e>
  np->sz = p->sz;
    80001e40:	048ab783          	ld	a5,72(s5)
    80001e44:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e48:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e4c:	058ab683          	ld	a3,88(s5)
    80001e50:	87b6                	mv	a5,a3
    80001e52:	058a3703          	ld	a4,88(s4)
    80001e56:	12068693          	addi	a3,a3,288
    80001e5a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5e:	6788                	ld	a0,8(a5)
    80001e60:	6b8c                	ld	a1,16(a5)
    80001e62:	6f90                	ld	a2,24(a5)
    80001e64:	01073023          	sd	a6,0(a4)
    80001e68:	e708                	sd	a0,8(a4)
    80001e6a:	eb0c                	sd	a1,16(a4)
    80001e6c:	ef10                	sd	a2,24(a4)
    80001e6e:	02078793          	addi	a5,a5,32
    80001e72:	02070713          	addi	a4,a4,32
    80001e76:	fed792e3          	bne	a5,a3,80001e5a <fork+0x58>
  np->trapframe->a0 = 0;
    80001e7a:	058a3783          	ld	a5,88(s4)
    80001e7e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e82:	0d0a8493          	addi	s1,s5,208
    80001e86:	0d0a0913          	addi	s2,s4,208
    80001e8a:	150a8993          	addi	s3,s5,336
    80001e8e:	a00d                	j	80001eb0 <fork+0xae>
    freeproc(np);
    80001e90:	8552                	mv	a0,s4
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	d5e080e7          	jalr	-674(ra) # 80001bf0 <freeproc>
    release(&np->lock);
    80001e9a:	8552                	mv	a0,s4
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	efe080e7          	jalr	-258(ra) # 80000d9a <release>
    return -1;
    80001ea4:	54fd                	li	s1,-1
    80001ea6:	a889                	j	80001ef8 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001ea8:	04a1                	addi	s1,s1,8
    80001eaa:	0921                	addi	s2,s2,8
    80001eac:	01348b63          	beq	s1,s3,80001ec2 <fork+0xc0>
    if(p->ofile[i])
    80001eb0:	6088                	ld	a0,0(s1)
    80001eb2:	d97d                	beqz	a0,80001ea8 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb4:	00002097          	auipc	ra,0x2
    80001eb8:	5e4080e7          	jalr	1508(ra) # 80004498 <filedup>
    80001ebc:	00a93023          	sd	a0,0(s2)
    80001ec0:	b7e5                	j	80001ea8 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ec2:	150ab503          	ld	a0,336(s5)
    80001ec6:	00001097          	auipc	ra,0x1
    80001eca:	766080e7          	jalr	1894(ra) # 8000362c <idup>
    80001ece:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed2:	4641                	li	a2,16
    80001ed4:	158a8593          	addi	a1,s5,344
    80001ed8:	158a0513          	addi	a0,s4,344
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	056080e7          	jalr	86(ra) # 80000f32 <safestrcpy>
  pid = np->pid;
    80001ee4:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001ee8:	4789                	li	a5,2
    80001eea:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eee:	8552                	mv	a0,s4
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	eaa080e7          	jalr	-342(ra) # 80000d9a <release>
}
    80001ef8:	8526                	mv	a0,s1
    80001efa:	70e2                	ld	ra,56(sp)
    80001efc:	7442                	ld	s0,48(sp)
    80001efe:	74a2                	ld	s1,40(sp)
    80001f00:	7902                	ld	s2,32(sp)
    80001f02:	69e2                	ld	s3,24(sp)
    80001f04:	6a42                	ld	s4,16(sp)
    80001f06:	6aa2                	ld	s5,8(sp)
    80001f08:	6121                	addi	sp,sp,64
    80001f0a:	8082                	ret
    return -1;
    80001f0c:	54fd                	li	s1,-1
    80001f0e:	b7ed                	j	80001ef8 <fork+0xf6>

0000000080001f10 <reparent>:
{
    80001f10:	7179                	addi	sp,sp,-48
    80001f12:	f406                	sd	ra,40(sp)
    80001f14:	f022                	sd	s0,32(sp)
    80001f16:	ec26                	sd	s1,24(sp)
    80001f18:	e84a                	sd	s2,16(sp)
    80001f1a:	e44e                	sd	s3,8(sp)
    80001f1c:	e052                	sd	s4,0(sp)
    80001f1e:	1800                	addi	s0,sp,48
    80001f20:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f22:	0000f497          	auipc	s1,0xf
    80001f26:	78648493          	addi	s1,s1,1926 # 800116a8 <proc>
      pp->parent = initproc;
    80001f2a:	00007a17          	auipc	s4,0x7
    80001f2e:	0f6a0a13          	addi	s4,s4,246 # 80009020 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f32:	00015997          	auipc	s3,0x15
    80001f36:	17698993          	addi	s3,s3,374 # 800170a8 <tickslock>
    80001f3a:	a029                	j	80001f44 <reparent+0x34>
    80001f3c:	16848493          	addi	s1,s1,360
    80001f40:	03348363          	beq	s1,s3,80001f66 <reparent+0x56>
    if(pp->parent == p){
    80001f44:	709c                	ld	a5,32(s1)
    80001f46:	ff279be3          	bne	a5,s2,80001f3c <reparent+0x2c>
      acquire(&pp->lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	d9a080e7          	jalr	-614(ra) # 80000ce6 <acquire>
      pp->parent = initproc;
    80001f54:	000a3783          	ld	a5,0(s4)
    80001f58:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	e3e080e7          	jalr	-450(ra) # 80000d9a <release>
    80001f64:	bfe1                	j	80001f3c <reparent+0x2c>
}
    80001f66:	70a2                	ld	ra,40(sp)
    80001f68:	7402                	ld	s0,32(sp)
    80001f6a:	64e2                	ld	s1,24(sp)
    80001f6c:	6942                	ld	s2,16(sp)
    80001f6e:	69a2                	ld	s3,8(sp)
    80001f70:	6a02                	ld	s4,0(sp)
    80001f72:	6145                	addi	sp,sp,48
    80001f74:	8082                	ret

0000000080001f76 <scheduler>:
{
    80001f76:	715d                	addi	sp,sp,-80
    80001f78:	e486                	sd	ra,72(sp)
    80001f7a:	e0a2                	sd	s0,64(sp)
    80001f7c:	fc26                	sd	s1,56(sp)
    80001f7e:	f84a                	sd	s2,48(sp)
    80001f80:	f44e                	sd	s3,40(sp)
    80001f82:	f052                	sd	s4,32(sp)
    80001f84:	ec56                	sd	s5,24(sp)
    80001f86:	e85a                	sd	s6,16(sp)
    80001f88:	e45e                	sd	s7,8(sp)
    80001f8a:	e062                	sd	s8,0(sp)
    80001f8c:	0880                	addi	s0,sp,80
    80001f8e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f90:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f92:	00779b93          	slli	s7,a5,0x7
    80001f96:	0000f717          	auipc	a4,0xf
    80001f9a:	2fa70713          	addi	a4,a4,762 # 80011290 <pid_lock>
    80001f9e:	975e                	add	a4,a4,s7
    80001fa0:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001fa4:	0000f717          	auipc	a4,0xf
    80001fa8:	30c70713          	addi	a4,a4,780 # 800112b0 <cpus+0x8>
    80001fac:	9bba                	add	s7,s7,a4
    int nproc = 0;
    80001fae:	4c01                	li	s8,0
      if(p->state == RUNNABLE) {
    80001fb0:	4a09                	li	s4,2
        c->proc = p;
    80001fb2:	079e                	slli	a5,a5,0x7
    80001fb4:	0000fa97          	auipc	s5,0xf
    80001fb8:	2dca8a93          	addi	s5,s5,732 # 80011290 <pid_lock>
    80001fbc:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fbe:	00015997          	auipc	s3,0x15
    80001fc2:	0ea98993          	addi	s3,s3,234 # 800170a8 <tickslock>
    80001fc6:	a8a1                	j	8000201e <scheduler+0xa8>
      release(&p->lock);
    80001fc8:	8526                	mv	a0,s1
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	dd0080e7          	jalr	-560(ra) # 80000d9a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fd2:	16848493          	addi	s1,s1,360
    80001fd6:	03348a63          	beq	s1,s3,8000200a <scheduler+0x94>
      acquire(&p->lock);
    80001fda:	8526                	mv	a0,s1
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	d0a080e7          	jalr	-758(ra) # 80000ce6 <acquire>
      if(p->state != UNUSED) {
    80001fe4:	4c9c                	lw	a5,24(s1)
    80001fe6:	d3ed                	beqz	a5,80001fc8 <scheduler+0x52>
        nproc++;
    80001fe8:	2905                	addiw	s2,s2,1
      if(p->state == RUNNABLE) {
    80001fea:	fd479fe3          	bne	a5,s4,80001fc8 <scheduler+0x52>
        p->state = RUNNING;
    80001fee:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001ff2:	009abc23          	sd	s1,24(s5)
        swtch(&c->context, &p->context);
    80001ff6:	06048593          	addi	a1,s1,96
    80001ffa:	855e                	mv	a0,s7
    80001ffc:	00000097          	auipc	ra,0x0
    80002000:	60e080e7          	jalr	1550(ra) # 8000260a <swtch>
        c->proc = 0;
    80002004:	000abc23          	sd	zero,24(s5)
    80002008:	b7c1                	j	80001fc8 <scheduler+0x52>
    if(nproc <= 2) {   // only init and sh exist
    8000200a:	012a4a63          	blt	s4,s2,8000201e <scheduler+0xa8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000200e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002012:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002016:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000201a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000201e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002022:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002026:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    8000202a:	8962                	mv	s2,s8
    for(p = proc; p < &proc[NPROC]; p++) {
    8000202c:	0000f497          	auipc	s1,0xf
    80002030:	67c48493          	addi	s1,s1,1660 # 800116a8 <proc>
        p->state = RUNNING;
    80002034:	4b0d                	li	s6,3
    80002036:	b755                	j	80001fda <scheduler+0x64>

0000000080002038 <sched>:
{
    80002038:	7179                	addi	sp,sp,-48
    8000203a:	f406                	sd	ra,40(sp)
    8000203c:	f022                	sd	s0,32(sp)
    8000203e:	ec26                	sd	s1,24(sp)
    80002040:	e84a                	sd	s2,16(sp)
    80002042:	e44e                	sd	s3,8(sp)
    80002044:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002046:	00000097          	auipc	ra,0x0
    8000204a:	9f8080e7          	jalr	-1544(ra) # 80001a3e <myproc>
    8000204e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	c1c080e7          	jalr	-996(ra) # 80000c6c <holding>
    80002058:	c93d                	beqz	a0,800020ce <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000205a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000205c:	2781                	sext.w	a5,a5
    8000205e:	079e                	slli	a5,a5,0x7
    80002060:	0000f717          	auipc	a4,0xf
    80002064:	23070713          	addi	a4,a4,560 # 80011290 <pid_lock>
    80002068:	97ba                	add	a5,a5,a4
    8000206a:	0907a703          	lw	a4,144(a5)
    8000206e:	4785                	li	a5,1
    80002070:	06f71763          	bne	a4,a5,800020de <sched+0xa6>
  if(p->state == RUNNING)
    80002074:	4c98                	lw	a4,24(s1)
    80002076:	478d                	li	a5,3
    80002078:	06f70b63          	beq	a4,a5,800020ee <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000207c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002080:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002082:	efb5                	bnez	a5,800020fe <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002084:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002086:	0000f917          	auipc	s2,0xf
    8000208a:	20a90913          	addi	s2,s2,522 # 80011290 <pid_lock>
    8000208e:	2781                	sext.w	a5,a5
    80002090:	079e                	slli	a5,a5,0x7
    80002092:	97ca                	add	a5,a5,s2
    80002094:	0947a983          	lw	s3,148(a5)
    80002098:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000209a:	2781                	sext.w	a5,a5
    8000209c:	079e                	slli	a5,a5,0x7
    8000209e:	0000f597          	auipc	a1,0xf
    800020a2:	21258593          	addi	a1,a1,530 # 800112b0 <cpus+0x8>
    800020a6:	95be                	add	a1,a1,a5
    800020a8:	06048513          	addi	a0,s1,96
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	55e080e7          	jalr	1374(ra) # 8000260a <swtch>
    800020b4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020b6:	2781                	sext.w	a5,a5
    800020b8:	079e                	slli	a5,a5,0x7
    800020ba:	993e                	add	s2,s2,a5
    800020bc:	09392a23          	sw	s3,148(s2)
}
    800020c0:	70a2                	ld	ra,40(sp)
    800020c2:	7402                	ld	s0,32(sp)
    800020c4:	64e2                	ld	s1,24(sp)
    800020c6:	6942                	ld	s2,16(sp)
    800020c8:	69a2                	ld	s3,8(sp)
    800020ca:	6145                	addi	sp,sp,48
    800020cc:	8082                	ret
    panic("sched p->lock");
    800020ce:	00006517          	auipc	a0,0x6
    800020d2:	12a50513          	addi	a0,a0,298 # 800081f8 <digits+0x1b8>
    800020d6:	ffffe097          	auipc	ra,0xffffe
    800020da:	472080e7          	jalr	1138(ra) # 80000548 <panic>
    panic("sched locks");
    800020de:	00006517          	auipc	a0,0x6
    800020e2:	12a50513          	addi	a0,a0,298 # 80008208 <digits+0x1c8>
    800020e6:	ffffe097          	auipc	ra,0xffffe
    800020ea:	462080e7          	jalr	1122(ra) # 80000548 <panic>
    panic("sched running");
    800020ee:	00006517          	auipc	a0,0x6
    800020f2:	12a50513          	addi	a0,a0,298 # 80008218 <digits+0x1d8>
    800020f6:	ffffe097          	auipc	ra,0xffffe
    800020fa:	452080e7          	jalr	1106(ra) # 80000548 <panic>
    panic("sched interruptible");
    800020fe:	00006517          	auipc	a0,0x6
    80002102:	12a50513          	addi	a0,a0,298 # 80008228 <digits+0x1e8>
    80002106:	ffffe097          	auipc	ra,0xffffe
    8000210a:	442080e7          	jalr	1090(ra) # 80000548 <panic>

000000008000210e <exit>:
{
    8000210e:	7179                	addi	sp,sp,-48
    80002110:	f406                	sd	ra,40(sp)
    80002112:	f022                	sd	s0,32(sp)
    80002114:	ec26                	sd	s1,24(sp)
    80002116:	e84a                	sd	s2,16(sp)
    80002118:	e44e                	sd	s3,8(sp)
    8000211a:	e052                	sd	s4,0(sp)
    8000211c:	1800                	addi	s0,sp,48
    8000211e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002120:	00000097          	auipc	ra,0x0
    80002124:	91e080e7          	jalr	-1762(ra) # 80001a3e <myproc>
    80002128:	89aa                	mv	s3,a0
  if(p == initproc)
    8000212a:	00007797          	auipc	a5,0x7
    8000212e:	ef67b783          	ld	a5,-266(a5) # 80009020 <initproc>
    80002132:	0d050493          	addi	s1,a0,208
    80002136:	15050913          	addi	s2,a0,336
    8000213a:	02a79363          	bne	a5,a0,80002160 <exit+0x52>
    panic("init exiting");
    8000213e:	00006517          	auipc	a0,0x6
    80002142:	10250513          	addi	a0,a0,258 # 80008240 <digits+0x200>
    80002146:	ffffe097          	auipc	ra,0xffffe
    8000214a:	402080e7          	jalr	1026(ra) # 80000548 <panic>
      fileclose(f);
    8000214e:	00002097          	auipc	ra,0x2
    80002152:	39c080e7          	jalr	924(ra) # 800044ea <fileclose>
      p->ofile[fd] = 0;
    80002156:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000215a:	04a1                	addi	s1,s1,8
    8000215c:	01248563          	beq	s1,s2,80002166 <exit+0x58>
    if(p->ofile[fd]){
    80002160:	6088                	ld	a0,0(s1)
    80002162:	f575                	bnez	a0,8000214e <exit+0x40>
    80002164:	bfdd                	j	8000215a <exit+0x4c>
  begin_op();
    80002166:	00002097          	auipc	ra,0x2
    8000216a:	eb8080e7          	jalr	-328(ra) # 8000401e <begin_op>
  iput(p->cwd);
    8000216e:	1509b503          	ld	a0,336(s3)
    80002172:	00001097          	auipc	ra,0x1
    80002176:	6b2080e7          	jalr	1714(ra) # 80003824 <iput>
  end_op();
    8000217a:	00002097          	auipc	ra,0x2
    8000217e:	f1e080e7          	jalr	-226(ra) # 80004098 <end_op>
  p->cwd = 0;
    80002182:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002186:	00007497          	auipc	s1,0x7
    8000218a:	e9a48493          	addi	s1,s1,-358 # 80009020 <initproc>
    8000218e:	6088                	ld	a0,0(s1)
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	b56080e7          	jalr	-1194(ra) # 80000ce6 <acquire>
  wakeup1(initproc);
    80002198:	6088                	ld	a0,0(s1)
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	764080e7          	jalr	1892(ra) # 800018fe <wakeup1>
  release(&initproc->lock);
    800021a2:	6088                	ld	a0,0(s1)
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	bf6080e7          	jalr	-1034(ra) # 80000d9a <release>
  acquire(&p->lock);
    800021ac:	854e                	mv	a0,s3
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	b38080e7          	jalr	-1224(ra) # 80000ce6 <acquire>
  struct proc *original_parent = p->parent;
    800021b6:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021ba:	854e                	mv	a0,s3
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	bde080e7          	jalr	-1058(ra) # 80000d9a <release>
  acquire(&original_parent->lock);
    800021c4:	8526                	mv	a0,s1
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	b20080e7          	jalr	-1248(ra) # 80000ce6 <acquire>
  acquire(&p->lock);
    800021ce:	854e                	mv	a0,s3
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	b16080e7          	jalr	-1258(ra) # 80000ce6 <acquire>
  reparent(p);
    800021d8:	854e                	mv	a0,s3
    800021da:	00000097          	auipc	ra,0x0
    800021de:	d36080e7          	jalr	-714(ra) # 80001f10 <reparent>
  wakeup1(original_parent);
    800021e2:	8526                	mv	a0,s1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	71a080e7          	jalr	1818(ra) # 800018fe <wakeup1>
  p->xstate = status;
    800021ec:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021f0:	4791                	li	a5,4
    800021f2:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021f6:	8526                	mv	a0,s1
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	ba2080e7          	jalr	-1118(ra) # 80000d9a <release>
  sched();
    80002200:	00000097          	auipc	ra,0x0
    80002204:	e38080e7          	jalr	-456(ra) # 80002038 <sched>
  panic("zombie exit");
    80002208:	00006517          	auipc	a0,0x6
    8000220c:	04850513          	addi	a0,a0,72 # 80008250 <digits+0x210>
    80002210:	ffffe097          	auipc	ra,0xffffe
    80002214:	338080e7          	jalr	824(ra) # 80000548 <panic>

0000000080002218 <yield>:
{
    80002218:	1101                	addi	sp,sp,-32
    8000221a:	ec06                	sd	ra,24(sp)
    8000221c:	e822                	sd	s0,16(sp)
    8000221e:	e426                	sd	s1,8(sp)
    80002220:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002222:	00000097          	auipc	ra,0x0
    80002226:	81c080e7          	jalr	-2020(ra) # 80001a3e <myproc>
    8000222a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	aba080e7          	jalr	-1350(ra) # 80000ce6 <acquire>
  p->state = RUNNABLE;
    80002234:	4789                	li	a5,2
    80002236:	cc9c                	sw	a5,24(s1)
  sched();
    80002238:	00000097          	auipc	ra,0x0
    8000223c:	e00080e7          	jalr	-512(ra) # 80002038 <sched>
  release(&p->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	b58080e7          	jalr	-1192(ra) # 80000d9a <release>
}
    8000224a:	60e2                	ld	ra,24(sp)
    8000224c:	6442                	ld	s0,16(sp)
    8000224e:	64a2                	ld	s1,8(sp)
    80002250:	6105                	addi	sp,sp,32
    80002252:	8082                	ret

0000000080002254 <sleep>:
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	1800                	addi	s0,sp,48
    80002262:	89aa                	mv	s3,a0
    80002264:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	7d8080e7          	jalr	2008(ra) # 80001a3e <myproc>
    8000226e:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002270:	05250663          	beq	a0,s2,800022bc <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	a72080e7          	jalr	-1422(ra) # 80000ce6 <acquire>
    release(lk);
    8000227c:	854a                	mv	a0,s2
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	b1c080e7          	jalr	-1252(ra) # 80000d9a <release>
  p->chan = chan;
    80002286:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000228a:	4785                	li	a5,1
    8000228c:	cc9c                	sw	a5,24(s1)
  sched();
    8000228e:	00000097          	auipc	ra,0x0
    80002292:	daa080e7          	jalr	-598(ra) # 80002038 <sched>
  p->chan = 0;
    80002296:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000229a:	8526                	mv	a0,s1
    8000229c:	fffff097          	auipc	ra,0xfffff
    800022a0:	afe080e7          	jalr	-1282(ra) # 80000d9a <release>
    acquire(lk);
    800022a4:	854a                	mv	a0,s2
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	a40080e7          	jalr	-1472(ra) # 80000ce6 <acquire>
}
    800022ae:	70a2                	ld	ra,40(sp)
    800022b0:	7402                	ld	s0,32(sp)
    800022b2:	64e2                	ld	s1,24(sp)
    800022b4:	6942                	ld	s2,16(sp)
    800022b6:	69a2                	ld	s3,8(sp)
    800022b8:	6145                	addi	sp,sp,48
    800022ba:	8082                	ret
  p->chan = chan;
    800022bc:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022c0:	4785                	li	a5,1
    800022c2:	cd1c                	sw	a5,24(a0)
  sched();
    800022c4:	00000097          	auipc	ra,0x0
    800022c8:	d74080e7          	jalr	-652(ra) # 80002038 <sched>
  p->chan = 0;
    800022cc:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022d0:	bff9                	j	800022ae <sleep+0x5a>

00000000800022d2 <wait>:
{
    800022d2:	715d                	addi	sp,sp,-80
    800022d4:	e486                	sd	ra,72(sp)
    800022d6:	e0a2                	sd	s0,64(sp)
    800022d8:	fc26                	sd	s1,56(sp)
    800022da:	f84a                	sd	s2,48(sp)
    800022dc:	f44e                	sd	s3,40(sp)
    800022de:	f052                	sd	s4,32(sp)
    800022e0:	ec56                	sd	s5,24(sp)
    800022e2:	e85a                	sd	s6,16(sp)
    800022e4:	e45e                	sd	s7,8(sp)
    800022e6:	0880                	addi	s0,sp,80
    800022e8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	754080e7          	jalr	1876(ra) # 80001a3e <myproc>
    800022f2:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	9f2080e7          	jalr	-1550(ra) # 80000ce6 <acquire>
    havekids = 0;
    800022fc:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022fe:	4a11                	li	s4,4
        havekids = 1;
    80002300:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002302:	00015997          	auipc	s3,0x15
    80002306:	da698993          	addi	s3,s3,-602 # 800170a8 <tickslock>
    8000230a:	a845                	j	800023ba <wait+0xe8>
          pid = np->pid;
    8000230c:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002310:	000b0e63          	beqz	s6,8000232c <wait+0x5a>
    80002314:	4691                	li	a3,4
    80002316:	03448613          	addi	a2,s1,52
    8000231a:	85da                	mv	a1,s6
    8000231c:	05093503          	ld	a0,80(s2)
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	414080e7          	jalr	1044(ra) # 80001734 <copyout>
    80002328:	02054d63          	bltz	a0,80002362 <wait+0x90>
          freeproc(np);
    8000232c:	8526                	mv	a0,s1
    8000232e:	00000097          	auipc	ra,0x0
    80002332:	8c2080e7          	jalr	-1854(ra) # 80001bf0 <freeproc>
          release(&np->lock);
    80002336:	8526                	mv	a0,s1
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	a62080e7          	jalr	-1438(ra) # 80000d9a <release>
          release(&p->lock);
    80002340:	854a                	mv	a0,s2
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	a58080e7          	jalr	-1448(ra) # 80000d9a <release>
}
    8000234a:	854e                	mv	a0,s3
    8000234c:	60a6                	ld	ra,72(sp)
    8000234e:	6406                	ld	s0,64(sp)
    80002350:	74e2                	ld	s1,56(sp)
    80002352:	7942                	ld	s2,48(sp)
    80002354:	79a2                	ld	s3,40(sp)
    80002356:	7a02                	ld	s4,32(sp)
    80002358:	6ae2                	ld	s5,24(sp)
    8000235a:	6b42                	ld	s6,16(sp)
    8000235c:	6ba2                	ld	s7,8(sp)
    8000235e:	6161                	addi	sp,sp,80
    80002360:	8082                	ret
            release(&np->lock);
    80002362:	8526                	mv	a0,s1
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	a36080e7          	jalr	-1482(ra) # 80000d9a <release>
            release(&p->lock);
    8000236c:	854a                	mv	a0,s2
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	a2c080e7          	jalr	-1492(ra) # 80000d9a <release>
            return -1;
    80002376:	59fd                	li	s3,-1
    80002378:	bfc9                	j	8000234a <wait+0x78>
    for(np = proc; np < &proc[NPROC]; np++){
    8000237a:	16848493          	addi	s1,s1,360
    8000237e:	03348463          	beq	s1,s3,800023a6 <wait+0xd4>
      if(np->parent == p){
    80002382:	709c                	ld	a5,32(s1)
    80002384:	ff279be3          	bne	a5,s2,8000237a <wait+0xa8>
        acquire(&np->lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	95c080e7          	jalr	-1700(ra) # 80000ce6 <acquire>
        if(np->state == ZOMBIE){
    80002392:	4c9c                	lw	a5,24(s1)
    80002394:	f7478ce3          	beq	a5,s4,8000230c <wait+0x3a>
        release(&np->lock);
    80002398:	8526                	mv	a0,s1
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	a00080e7          	jalr	-1536(ra) # 80000d9a <release>
        havekids = 1;
    800023a2:	8756                	mv	a4,s5
    800023a4:	bfd9                	j	8000237a <wait+0xa8>
    if(!havekids || p->killed){
    800023a6:	c305                	beqz	a4,800023c6 <wait+0xf4>
    800023a8:	03092783          	lw	a5,48(s2)
    800023ac:	ef89                	bnez	a5,800023c6 <wait+0xf4>
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023ae:	85ca                	mv	a1,s2
    800023b0:	854a                	mv	a0,s2
    800023b2:	00000097          	auipc	ra,0x0
    800023b6:	ea2080e7          	jalr	-350(ra) # 80002254 <sleep>
    havekids = 0;
    800023ba:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800023bc:	0000f497          	auipc	s1,0xf
    800023c0:	2ec48493          	addi	s1,s1,748 # 800116a8 <proc>
    800023c4:	bf7d                	j	80002382 <wait+0xb0>
      release(&p->lock);
    800023c6:	854a                	mv	a0,s2
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	9d2080e7          	jalr	-1582(ra) # 80000d9a <release>
      return -1;
    800023d0:	59fd                	li	s3,-1
    800023d2:	bfa5                	j	8000234a <wait+0x78>

00000000800023d4 <wakeup>:
{
    800023d4:	7139                	addi	sp,sp,-64
    800023d6:	fc06                	sd	ra,56(sp)
    800023d8:	f822                	sd	s0,48(sp)
    800023da:	f426                	sd	s1,40(sp)
    800023dc:	f04a                	sd	s2,32(sp)
    800023de:	ec4e                	sd	s3,24(sp)
    800023e0:	e852                	sd	s4,16(sp)
    800023e2:	e456                	sd	s5,8(sp)
    800023e4:	0080                	addi	s0,sp,64
    800023e6:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023e8:	0000f497          	auipc	s1,0xf
    800023ec:	2c048493          	addi	s1,s1,704 # 800116a8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023f0:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023f2:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023f4:	00015917          	auipc	s2,0x15
    800023f8:	cb490913          	addi	s2,s2,-844 # 800170a8 <tickslock>
    800023fc:	a811                	j	80002410 <wakeup+0x3c>
    release(&p->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	99a080e7          	jalr	-1638(ra) # 80000d9a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002408:	16848493          	addi	s1,s1,360
    8000240c:	03248063          	beq	s1,s2,8000242c <wakeup+0x58>
    acquire(&p->lock);
    80002410:	8526                	mv	a0,s1
    80002412:	fffff097          	auipc	ra,0xfffff
    80002416:	8d4080e7          	jalr	-1836(ra) # 80000ce6 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000241a:	4c9c                	lw	a5,24(s1)
    8000241c:	ff3791e3          	bne	a5,s3,800023fe <wakeup+0x2a>
    80002420:	749c                	ld	a5,40(s1)
    80002422:	fd479ee3          	bne	a5,s4,800023fe <wakeup+0x2a>
      p->state = RUNNABLE;
    80002426:	0154ac23          	sw	s5,24(s1)
    8000242a:	bfd1                	j	800023fe <wakeup+0x2a>
}
    8000242c:	70e2                	ld	ra,56(sp)
    8000242e:	7442                	ld	s0,48(sp)
    80002430:	74a2                	ld	s1,40(sp)
    80002432:	7902                	ld	s2,32(sp)
    80002434:	69e2                	ld	s3,24(sp)
    80002436:	6a42                	ld	s4,16(sp)
    80002438:	6aa2                	ld	s5,8(sp)
    8000243a:	6121                	addi	sp,sp,64
    8000243c:	8082                	ret

000000008000243e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000243e:	7179                	addi	sp,sp,-48
    80002440:	f406                	sd	ra,40(sp)
    80002442:	f022                	sd	s0,32(sp)
    80002444:	ec26                	sd	s1,24(sp)
    80002446:	e84a                	sd	s2,16(sp)
    80002448:	e44e                	sd	s3,8(sp)
    8000244a:	1800                	addi	s0,sp,48
    8000244c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000244e:	0000f497          	auipc	s1,0xf
    80002452:	25a48493          	addi	s1,s1,602 # 800116a8 <proc>
    80002456:	00015997          	auipc	s3,0x15
    8000245a:	c5298993          	addi	s3,s3,-942 # 800170a8 <tickslock>
    acquire(&p->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	886080e7          	jalr	-1914(ra) # 80000ce6 <acquire>
    if(p->pid == pid){
    80002468:	5c9c                	lw	a5,56(s1)
    8000246a:	01278d63          	beq	a5,s2,80002484 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	92a080e7          	jalr	-1750(ra) # 80000d9a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002478:	16848493          	addi	s1,s1,360
    8000247c:	ff3491e3          	bne	s1,s3,8000245e <kill+0x20>
  }
  return -1;
    80002480:	557d                	li	a0,-1
    80002482:	a821                	j	8000249a <kill+0x5c>
      p->killed = 1;
    80002484:	4785                	li	a5,1
    80002486:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002488:	4c98                	lw	a4,24(s1)
    8000248a:	00f70f63          	beq	a4,a5,800024a8 <kill+0x6a>
      release(&p->lock);
    8000248e:	8526                	mv	a0,s1
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	90a080e7          	jalr	-1782(ra) # 80000d9a <release>
      return 0;
    80002498:	4501                	li	a0,0
}
    8000249a:	70a2                	ld	ra,40(sp)
    8000249c:	7402                	ld	s0,32(sp)
    8000249e:	64e2                	ld	s1,24(sp)
    800024a0:	6942                	ld	s2,16(sp)
    800024a2:	69a2                	ld	s3,8(sp)
    800024a4:	6145                	addi	sp,sp,48
    800024a6:	8082                	ret
        p->state = RUNNABLE;
    800024a8:	4789                	li	a5,2
    800024aa:	cc9c                	sw	a5,24(s1)
    800024ac:	b7cd                	j	8000248e <kill+0x50>

00000000800024ae <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024ae:	7179                	addi	sp,sp,-48
    800024b0:	f406                	sd	ra,40(sp)
    800024b2:	f022                	sd	s0,32(sp)
    800024b4:	ec26                	sd	s1,24(sp)
    800024b6:	e84a                	sd	s2,16(sp)
    800024b8:	e44e                	sd	s3,8(sp)
    800024ba:	e052                	sd	s4,0(sp)
    800024bc:	1800                	addi	s0,sp,48
    800024be:	84aa                	mv	s1,a0
    800024c0:	892e                	mv	s2,a1
    800024c2:	89b2                	mv	s3,a2
    800024c4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	578080e7          	jalr	1400(ra) # 80001a3e <myproc>
  if(user_dst){
    800024ce:	c08d                	beqz	s1,800024f0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024d0:	86d2                	mv	a3,s4
    800024d2:	864e                	mv	a2,s3
    800024d4:	85ca                	mv	a1,s2
    800024d6:	6928                	ld	a0,80(a0)
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	25c080e7          	jalr	604(ra) # 80001734 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024e0:	70a2                	ld	ra,40(sp)
    800024e2:	7402                	ld	s0,32(sp)
    800024e4:	64e2                	ld	s1,24(sp)
    800024e6:	6942                	ld	s2,16(sp)
    800024e8:	69a2                	ld	s3,8(sp)
    800024ea:	6a02                	ld	s4,0(sp)
    800024ec:	6145                	addi	sp,sp,48
    800024ee:	8082                	ret
    memmove((char *)dst, src, len);
    800024f0:	000a061b          	sext.w	a2,s4
    800024f4:	85ce                	mv	a1,s3
    800024f6:	854a                	mv	a0,s2
    800024f8:	fffff097          	auipc	ra,0xfffff
    800024fc:	946080e7          	jalr	-1722(ra) # 80000e3e <memmove>
    return 0;
    80002500:	8526                	mv	a0,s1
    80002502:	bff9                	j	800024e0 <either_copyout+0x32>

0000000080002504 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002504:	7179                	addi	sp,sp,-48
    80002506:	f406                	sd	ra,40(sp)
    80002508:	f022                	sd	s0,32(sp)
    8000250a:	ec26                	sd	s1,24(sp)
    8000250c:	e84a                	sd	s2,16(sp)
    8000250e:	e44e                	sd	s3,8(sp)
    80002510:	e052                	sd	s4,0(sp)
    80002512:	1800                	addi	s0,sp,48
    80002514:	892a                	mv	s2,a0
    80002516:	84ae                	mv	s1,a1
    80002518:	89b2                	mv	s3,a2
    8000251a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	522080e7          	jalr	1314(ra) # 80001a3e <myproc>
  if(user_src){
    80002524:	c08d                	beqz	s1,80002546 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002526:	86d2                	mv	a3,s4
    80002528:	864e                	mv	a2,s3
    8000252a:	85ca                	mv	a1,s2
    8000252c:	6928                	ld	a0,80(a0)
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	292080e7          	jalr	658(ra) # 800017c0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002536:	70a2                	ld	ra,40(sp)
    80002538:	7402                	ld	s0,32(sp)
    8000253a:	64e2                	ld	s1,24(sp)
    8000253c:	6942                	ld	s2,16(sp)
    8000253e:	69a2                	ld	s3,8(sp)
    80002540:	6a02                	ld	s4,0(sp)
    80002542:	6145                	addi	sp,sp,48
    80002544:	8082                	ret
    memmove(dst, (char*)src, len);
    80002546:	000a061b          	sext.w	a2,s4
    8000254a:	85ce                	mv	a1,s3
    8000254c:	854a                	mv	a0,s2
    8000254e:	fffff097          	auipc	ra,0xfffff
    80002552:	8f0080e7          	jalr	-1808(ra) # 80000e3e <memmove>
    return 0;
    80002556:	8526                	mv	a0,s1
    80002558:	bff9                	j	80002536 <either_copyin+0x32>

000000008000255a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000255a:	715d                	addi	sp,sp,-80
    8000255c:	e486                	sd	ra,72(sp)
    8000255e:	e0a2                	sd	s0,64(sp)
    80002560:	fc26                	sd	s1,56(sp)
    80002562:	f84a                	sd	s2,48(sp)
    80002564:	f44e                	sd	s3,40(sp)
    80002566:	f052                	sd	s4,32(sp)
    80002568:	ec56                	sd	s5,24(sp)
    8000256a:	e85a                	sd	s6,16(sp)
    8000256c:	e45e                	sd	s7,8(sp)
    8000256e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002570:	00006517          	auipc	a0,0x6
    80002574:	b5850513          	addi	a0,a0,-1192 # 800080c8 <digits+0x88>
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	01a080e7          	jalr	26(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002580:	0000f497          	auipc	s1,0xf
    80002584:	28048493          	addi	s1,s1,640 # 80011800 <proc+0x158>
    80002588:	00015917          	auipc	s2,0x15
    8000258c:	c7890913          	addi	s2,s2,-904 # 80017200 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002590:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002592:	00006997          	auipc	s3,0x6
    80002596:	cce98993          	addi	s3,s3,-818 # 80008260 <digits+0x220>
    printf("%d %s %s", p->pid, state, p->name);
    8000259a:	00006a97          	auipc	s5,0x6
    8000259e:	ccea8a93          	addi	s5,s5,-818 # 80008268 <digits+0x228>
    printf("\n");
    800025a2:	00006a17          	auipc	s4,0x6
    800025a6:	b26a0a13          	addi	s4,s4,-1242 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025aa:	00006b97          	auipc	s7,0x6
    800025ae:	cf6b8b93          	addi	s7,s7,-778 # 800082a0 <states.0>
    800025b2:	a00d                	j	800025d4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025b4:	ee06a583          	lw	a1,-288(a3)
    800025b8:	8556                	mv	a0,s5
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	fd8080e7          	jalr	-40(ra) # 80000592 <printf>
    printf("\n");
    800025c2:	8552                	mv	a0,s4
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	fce080e7          	jalr	-50(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025cc:	16848493          	addi	s1,s1,360
    800025d0:	03248263          	beq	s1,s2,800025f4 <procdump+0x9a>
    if(p->state == UNUSED)
    800025d4:	86a6                	mv	a3,s1
    800025d6:	ec04a783          	lw	a5,-320(s1)
    800025da:	dbed                	beqz	a5,800025cc <procdump+0x72>
      state = "???";
    800025dc:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025de:	fcfb6be3          	bltu	s6,a5,800025b4 <procdump+0x5a>
    800025e2:	02079713          	slli	a4,a5,0x20
    800025e6:	01d75793          	srli	a5,a4,0x1d
    800025ea:	97de                	add	a5,a5,s7
    800025ec:	6390                	ld	a2,0(a5)
    800025ee:	f279                	bnez	a2,800025b4 <procdump+0x5a>
      state = "???";
    800025f0:	864e                	mv	a2,s3
    800025f2:	b7c9                	j	800025b4 <procdump+0x5a>
  }
}
    800025f4:	60a6                	ld	ra,72(sp)
    800025f6:	6406                	ld	s0,64(sp)
    800025f8:	74e2                	ld	s1,56(sp)
    800025fa:	7942                	ld	s2,48(sp)
    800025fc:	79a2                	ld	s3,40(sp)
    800025fe:	7a02                	ld	s4,32(sp)
    80002600:	6ae2                	ld	s5,24(sp)
    80002602:	6b42                	ld	s6,16(sp)
    80002604:	6ba2                	ld	s7,8(sp)
    80002606:	6161                	addi	sp,sp,80
    80002608:	8082                	ret

000000008000260a <swtch>:
    8000260a:	00153023          	sd	ra,0(a0)
    8000260e:	00253423          	sd	sp,8(a0)
    80002612:	e900                	sd	s0,16(a0)
    80002614:	ed04                	sd	s1,24(a0)
    80002616:	03253023          	sd	s2,32(a0)
    8000261a:	03353423          	sd	s3,40(a0)
    8000261e:	03453823          	sd	s4,48(a0)
    80002622:	03553c23          	sd	s5,56(a0)
    80002626:	05653023          	sd	s6,64(a0)
    8000262a:	05753423          	sd	s7,72(a0)
    8000262e:	05853823          	sd	s8,80(a0)
    80002632:	05953c23          	sd	s9,88(a0)
    80002636:	07a53023          	sd	s10,96(a0)
    8000263a:	07b53423          	sd	s11,104(a0)
    8000263e:	0005b083          	ld	ra,0(a1)
    80002642:	0085b103          	ld	sp,8(a1)
    80002646:	6980                	ld	s0,16(a1)
    80002648:	6d84                	ld	s1,24(a1)
    8000264a:	0205b903          	ld	s2,32(a1)
    8000264e:	0285b983          	ld	s3,40(a1)
    80002652:	0305ba03          	ld	s4,48(a1)
    80002656:	0385ba83          	ld	s5,56(a1)
    8000265a:	0405bb03          	ld	s6,64(a1)
    8000265e:	0485bb83          	ld	s7,72(a1)
    80002662:	0505bc03          	ld	s8,80(a1)
    80002666:	0585bc83          	ld	s9,88(a1)
    8000266a:	0605bd03          	ld	s10,96(a1)
    8000266e:	0685bd83          	ld	s11,104(a1)
    80002672:	8082                	ret

0000000080002674 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002674:	1141                	addi	sp,sp,-16
    80002676:	e406                	sd	ra,8(sp)
    80002678:	e022                	sd	s0,0(sp)
    8000267a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000267c:	00006597          	auipc	a1,0x6
    80002680:	c4c58593          	addi	a1,a1,-948 # 800082c8 <states.0+0x28>
    80002684:	00015517          	auipc	a0,0x15
    80002688:	a2450513          	addi	a0,a0,-1500 # 800170a8 <tickslock>
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	5ca080e7          	jalr	1482(ra) # 80000c56 <initlock>
}
    80002694:	60a2                	ld	ra,8(sp)
    80002696:	6402                	ld	s0,0(sp)
    80002698:	0141                	addi	sp,sp,16
    8000269a:	8082                	ret

000000008000269c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000269c:	1141                	addi	sp,sp,-16
    8000269e:	e422                	sd	s0,8(sp)
    800026a0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026a2:	00003797          	auipc	a5,0x3
    800026a6:	47e78793          	addi	a5,a5,1150 # 80005b20 <kernelvec>
    800026aa:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026ae:	6422                	ld	s0,8(sp)
    800026b0:	0141                	addi	sp,sp,16
    800026b2:	8082                	ret

00000000800026b4 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026b4:	1141                	addi	sp,sp,-16
    800026b6:	e406                	sd	ra,8(sp)
    800026b8:	e022                	sd	s0,0(sp)
    800026ba:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026bc:	fffff097          	auipc	ra,0xfffff
    800026c0:	382080e7          	jalr	898(ra) # 80001a3e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026c8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ca:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026ce:	00005697          	auipc	a3,0x5
    800026d2:	93268693          	addi	a3,a3,-1742 # 80007000 <_trampoline>
    800026d6:	00005717          	auipc	a4,0x5
    800026da:	92a70713          	addi	a4,a4,-1750 # 80007000 <_trampoline>
    800026de:	8f15                	sub	a4,a4,a3
    800026e0:	040007b7          	lui	a5,0x4000
    800026e4:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026e6:	07b2                	slli	a5,a5,0xc
    800026e8:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ea:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026ee:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026f0:	18002673          	csrr	a2,satp
    800026f4:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026f6:	6d30                	ld	a2,88(a0)
    800026f8:	6138                	ld	a4,64(a0)
    800026fa:	6585                	lui	a1,0x1
    800026fc:	972e                	add	a4,a4,a1
    800026fe:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002700:	6d38                	ld	a4,88(a0)
    80002702:	00000617          	auipc	a2,0x0
    80002706:	13c60613          	addi	a2,a2,316 # 8000283e <usertrap>
    8000270a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000270c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000270e:	8612                	mv	a2,tp
    80002710:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002712:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002716:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000271a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000271e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002722:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002724:	6f18                	ld	a4,24(a4)
    80002726:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000272a:	692c                	ld	a1,80(a0)
    8000272c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000272e:	00005717          	auipc	a4,0x5
    80002732:	96270713          	addi	a4,a4,-1694 # 80007090 <userret>
    80002736:	8f15                	sub	a4,a4,a3
    80002738:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000273a:	577d                	li	a4,-1
    8000273c:	177e                	slli	a4,a4,0x3f
    8000273e:	8dd9                	or	a1,a1,a4
    80002740:	02000537          	lui	a0,0x2000
    80002744:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002746:	0536                	slli	a0,a0,0xd
    80002748:	9782                	jalr	a5
}
    8000274a:	60a2                	ld	ra,8(sp)
    8000274c:	6402                	ld	s0,0(sp)
    8000274e:	0141                	addi	sp,sp,16
    80002750:	8082                	ret

0000000080002752 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002752:	1101                	addi	sp,sp,-32
    80002754:	ec06                	sd	ra,24(sp)
    80002756:	e822                	sd	s0,16(sp)
    80002758:	e426                	sd	s1,8(sp)
    8000275a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000275c:	00015497          	auipc	s1,0x15
    80002760:	94c48493          	addi	s1,s1,-1716 # 800170a8 <tickslock>
    80002764:	8526                	mv	a0,s1
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	580080e7          	jalr	1408(ra) # 80000ce6 <acquire>
  ticks++;
    8000276e:	00007517          	auipc	a0,0x7
    80002772:	8ba50513          	addi	a0,a0,-1862 # 80009028 <ticks>
    80002776:	411c                	lw	a5,0(a0)
    80002778:	2785                	addiw	a5,a5,1
    8000277a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000277c:	00000097          	auipc	ra,0x0
    80002780:	c58080e7          	jalr	-936(ra) # 800023d4 <wakeup>
  release(&tickslock);
    80002784:	8526                	mv	a0,s1
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	614080e7          	jalr	1556(ra) # 80000d9a <release>
}
    8000278e:	60e2                	ld	ra,24(sp)
    80002790:	6442                	ld	s0,16(sp)
    80002792:	64a2                	ld	s1,8(sp)
    80002794:	6105                	addi	sp,sp,32
    80002796:	8082                	ret

0000000080002798 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002798:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000279c:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000279e:	0807df63          	bgez	a5,8000283c <devintr+0xa4>
{
    800027a2:	1101                	addi	sp,sp,-32
    800027a4:	ec06                	sd	ra,24(sp)
    800027a6:	e822                	sd	s0,16(sp)
    800027a8:	e426                	sd	s1,8(sp)
    800027aa:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    800027ac:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800027b0:	46a5                	li	a3,9
    800027b2:	00d70d63          	beq	a4,a3,800027cc <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    800027b6:	577d                	li	a4,-1
    800027b8:	177e                	slli	a4,a4,0x3f
    800027ba:	0705                	addi	a4,a4,1
    return 0;
    800027bc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027be:	04e78e63          	beq	a5,a4,8000281a <devintr+0x82>
  }
}
    800027c2:	60e2                	ld	ra,24(sp)
    800027c4:	6442                	ld	s0,16(sp)
    800027c6:	64a2                	ld	s1,8(sp)
    800027c8:	6105                	addi	sp,sp,32
    800027ca:	8082                	ret
    int irq = plic_claim();
    800027cc:	00003097          	auipc	ra,0x3
    800027d0:	45c080e7          	jalr	1116(ra) # 80005c28 <plic_claim>
    800027d4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027d6:	47a9                	li	a5,10
    800027d8:	02f50763          	beq	a0,a5,80002806 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    800027dc:	4785                	li	a5,1
    800027de:	02f50963          	beq	a0,a5,80002810 <devintr+0x78>
    return 1;
    800027e2:	4505                	li	a0,1
    } else if(irq){
    800027e4:	dcf9                	beqz	s1,800027c2 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800027e6:	85a6                	mv	a1,s1
    800027e8:	00006517          	auipc	a0,0x6
    800027ec:	ae850513          	addi	a0,a0,-1304 # 800082d0 <states.0+0x30>
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	da2080e7          	jalr	-606(ra) # 80000592 <printf>
      plic_complete(irq);
    800027f8:	8526                	mv	a0,s1
    800027fa:	00003097          	auipc	ra,0x3
    800027fe:	452080e7          	jalr	1106(ra) # 80005c4c <plic_complete>
    return 1;
    80002802:	4505                	li	a0,1
    80002804:	bf7d                	j	800027c2 <devintr+0x2a>
      uartintr();
    80002806:	ffffe097          	auipc	ra,0xffffe
    8000280a:	1be080e7          	jalr	446(ra) # 800009c4 <uartintr>
    if(irq)
    8000280e:	b7ed                	j	800027f8 <devintr+0x60>
      virtio_disk_intr();
    80002810:	00004097          	auipc	ra,0x4
    80002814:	8c6080e7          	jalr	-1850(ra) # 800060d6 <virtio_disk_intr>
    if(irq)
    80002818:	b7c5                	j	800027f8 <devintr+0x60>
    if(cpuid() == 0){
    8000281a:	fffff097          	auipc	ra,0xfffff
    8000281e:	1f8080e7          	jalr	504(ra) # 80001a12 <cpuid>
    80002822:	c901                	beqz	a0,80002832 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002824:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002828:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000282a:	14479073          	csrw	sip,a5
    return 2;
    8000282e:	4509                	li	a0,2
    80002830:	bf49                	j	800027c2 <devintr+0x2a>
      clockintr();
    80002832:	00000097          	auipc	ra,0x0
    80002836:	f20080e7          	jalr	-224(ra) # 80002752 <clockintr>
    8000283a:	b7ed                	j	80002824 <devintr+0x8c>
}
    8000283c:	8082                	ret

000000008000283e <usertrap>:
{
    8000283e:	1101                	addi	sp,sp,-32
    80002840:	ec06                	sd	ra,24(sp)
    80002842:	e822                	sd	s0,16(sp)
    80002844:	e426                	sd	s1,8(sp)
    80002846:	e04a                	sd	s2,0(sp)
    80002848:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000284a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000284e:	1007f793          	andi	a5,a5,256
    80002852:	e3ad                	bnez	a5,800028b4 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002854:	00003797          	auipc	a5,0x3
    80002858:	2cc78793          	addi	a5,a5,716 # 80005b20 <kernelvec>
    8000285c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002860:	fffff097          	auipc	ra,0xfffff
    80002864:	1de080e7          	jalr	478(ra) # 80001a3e <myproc>
    80002868:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000286a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000286c:	14102773          	csrr	a4,sepc
    80002870:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002872:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002876:	47a1                	li	a5,8
    80002878:	04f71c63          	bne	a4,a5,800028d0 <usertrap+0x92>
    if(p->killed)
    8000287c:	591c                	lw	a5,48(a0)
    8000287e:	e3b9                	bnez	a5,800028c4 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002880:	6cb8                	ld	a4,88(s1)
    80002882:	6f1c                	ld	a5,24(a4)
    80002884:	0791                	addi	a5,a5,4
    80002886:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002888:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000288c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002890:	10079073          	csrw	sstatus,a5
    syscall();
    80002894:	00000097          	auipc	ra,0x0
    80002898:	2e0080e7          	jalr	736(ra) # 80002b74 <syscall>
  if(p->killed)
    8000289c:	589c                	lw	a5,48(s1)
    8000289e:	ebc1                	bnez	a5,8000292e <usertrap+0xf0>
  usertrapret();
    800028a0:	00000097          	auipc	ra,0x0
    800028a4:	e14080e7          	jalr	-492(ra) # 800026b4 <usertrapret>
}
    800028a8:	60e2                	ld	ra,24(sp)
    800028aa:	6442                	ld	s0,16(sp)
    800028ac:	64a2                	ld	s1,8(sp)
    800028ae:	6902                	ld	s2,0(sp)
    800028b0:	6105                	addi	sp,sp,32
    800028b2:	8082                	ret
    panic("usertrap: not from user mode");
    800028b4:	00006517          	auipc	a0,0x6
    800028b8:	a3c50513          	addi	a0,a0,-1476 # 800082f0 <states.0+0x50>
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	c8c080e7          	jalr	-884(ra) # 80000548 <panic>
      exit(-1);
    800028c4:	557d                	li	a0,-1
    800028c6:	00000097          	auipc	ra,0x0
    800028ca:	848080e7          	jalr	-1976(ra) # 8000210e <exit>
    800028ce:	bf4d                	j	80002880 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028d0:	00000097          	auipc	ra,0x0
    800028d4:	ec8080e7          	jalr	-312(ra) # 80002798 <devintr>
    800028d8:	892a                	mv	s2,a0
    800028da:	c501                	beqz	a0,800028e2 <usertrap+0xa4>
  if(p->killed)
    800028dc:	589c                	lw	a5,48(s1)
    800028de:	c3a1                	beqz	a5,8000291e <usertrap+0xe0>
    800028e0:	a815                	j	80002914 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028e6:	5c90                	lw	a2,56(s1)
    800028e8:	00006517          	auipc	a0,0x6
    800028ec:	a2850513          	addi	a0,a0,-1496 # 80008310 <states.0+0x70>
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	ca2080e7          	jalr	-862(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028f8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028fc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002900:	00006517          	auipc	a0,0x6
    80002904:	a4050513          	addi	a0,a0,-1472 # 80008340 <states.0+0xa0>
    80002908:	ffffe097          	auipc	ra,0xffffe
    8000290c:	c8a080e7          	jalr	-886(ra) # 80000592 <printf>
    p->killed = 1;
    80002910:	4785                	li	a5,1
    80002912:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002914:	557d                	li	a0,-1
    80002916:	fffff097          	auipc	ra,0xfffff
    8000291a:	7f8080e7          	jalr	2040(ra) # 8000210e <exit>
  if(which_dev == 2)
    8000291e:	4789                	li	a5,2
    80002920:	f8f910e3          	bne	s2,a5,800028a0 <usertrap+0x62>
    yield();
    80002924:	00000097          	auipc	ra,0x0
    80002928:	8f4080e7          	jalr	-1804(ra) # 80002218 <yield>
    8000292c:	bf95                	j	800028a0 <usertrap+0x62>
  int which_dev = 0;
    8000292e:	4901                	li	s2,0
    80002930:	b7d5                	j	80002914 <usertrap+0xd6>

0000000080002932 <kerneltrap>:
{
    80002932:	7179                	addi	sp,sp,-48
    80002934:	f406                	sd	ra,40(sp)
    80002936:	f022                	sd	s0,32(sp)
    80002938:	ec26                	sd	s1,24(sp)
    8000293a:	e84a                	sd	s2,16(sp)
    8000293c:	e44e                	sd	s3,8(sp)
    8000293e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002940:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002944:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002948:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000294c:	1004f793          	andi	a5,s1,256
    80002950:	cb85                	beqz	a5,80002980 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002952:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002956:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002958:	ef85                	bnez	a5,80002990 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000295a:	00000097          	auipc	ra,0x0
    8000295e:	e3e080e7          	jalr	-450(ra) # 80002798 <devintr>
    80002962:	cd1d                	beqz	a0,800029a0 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002964:	4789                	li	a5,2
    80002966:	06f50a63          	beq	a0,a5,800029da <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000296a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000296e:	10049073          	csrw	sstatus,s1
}
    80002972:	70a2                	ld	ra,40(sp)
    80002974:	7402                	ld	s0,32(sp)
    80002976:	64e2                	ld	s1,24(sp)
    80002978:	6942                	ld	s2,16(sp)
    8000297a:	69a2                	ld	s3,8(sp)
    8000297c:	6145                	addi	sp,sp,48
    8000297e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002980:	00006517          	auipc	a0,0x6
    80002984:	9e050513          	addi	a0,a0,-1568 # 80008360 <states.0+0xc0>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	bc0080e7          	jalr	-1088(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002990:	00006517          	auipc	a0,0x6
    80002994:	9f850513          	addi	a0,a0,-1544 # 80008388 <states.0+0xe8>
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	bb0080e7          	jalr	-1104(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    800029a0:	85ce                	mv	a1,s3
    800029a2:	00006517          	auipc	a0,0x6
    800029a6:	a0650513          	addi	a0,a0,-1530 # 800083a8 <states.0+0x108>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	be8080e7          	jalr	-1048(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029b6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029ba:	00006517          	auipc	a0,0x6
    800029be:	9fe50513          	addi	a0,a0,-1538 # 800083b8 <states.0+0x118>
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	bd0080e7          	jalr	-1072(ra) # 80000592 <printf>
    panic("kerneltrap");
    800029ca:	00006517          	auipc	a0,0x6
    800029ce:	a0650513          	addi	a0,a0,-1530 # 800083d0 <states.0+0x130>
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	b76080e7          	jalr	-1162(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029da:	fffff097          	auipc	ra,0xfffff
    800029de:	064080e7          	jalr	100(ra) # 80001a3e <myproc>
    800029e2:	d541                	beqz	a0,8000296a <kerneltrap+0x38>
    800029e4:	fffff097          	auipc	ra,0xfffff
    800029e8:	05a080e7          	jalr	90(ra) # 80001a3e <myproc>
    800029ec:	4d18                	lw	a4,24(a0)
    800029ee:	478d                	li	a5,3
    800029f0:	f6f71de3          	bne	a4,a5,8000296a <kerneltrap+0x38>
    yield();
    800029f4:	00000097          	auipc	ra,0x0
    800029f8:	824080e7          	jalr	-2012(ra) # 80002218 <yield>
    800029fc:	b7bd                	j	8000296a <kerneltrap+0x38>

00000000800029fe <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029fe:	1101                	addi	sp,sp,-32
    80002a00:	ec06                	sd	ra,24(sp)
    80002a02:	e822                	sd	s0,16(sp)
    80002a04:	e426                	sd	s1,8(sp)
    80002a06:	1000                	addi	s0,sp,32
    80002a08:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a0a:	fffff097          	auipc	ra,0xfffff
    80002a0e:	034080e7          	jalr	52(ra) # 80001a3e <myproc>
  switch (n) {
    80002a12:	4795                	li	a5,5
    80002a14:	0497e163          	bltu	a5,s1,80002a56 <argraw+0x58>
    80002a18:	048a                	slli	s1,s1,0x2
    80002a1a:	00006717          	auipc	a4,0x6
    80002a1e:	9ee70713          	addi	a4,a4,-1554 # 80008408 <states.0+0x168>
    80002a22:	94ba                	add	s1,s1,a4
    80002a24:	409c                	lw	a5,0(s1)
    80002a26:	97ba                	add	a5,a5,a4
    80002a28:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a2a:	6d3c                	ld	a5,88(a0)
    80002a2c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a2e:	60e2                	ld	ra,24(sp)
    80002a30:	6442                	ld	s0,16(sp)
    80002a32:	64a2                	ld	s1,8(sp)
    80002a34:	6105                	addi	sp,sp,32
    80002a36:	8082                	ret
    return p->trapframe->a1;
    80002a38:	6d3c                	ld	a5,88(a0)
    80002a3a:	7fa8                	ld	a0,120(a5)
    80002a3c:	bfcd                	j	80002a2e <argraw+0x30>
    return p->trapframe->a2;
    80002a3e:	6d3c                	ld	a5,88(a0)
    80002a40:	63c8                	ld	a0,128(a5)
    80002a42:	b7f5                	j	80002a2e <argraw+0x30>
    return p->trapframe->a3;
    80002a44:	6d3c                	ld	a5,88(a0)
    80002a46:	67c8                	ld	a0,136(a5)
    80002a48:	b7dd                	j	80002a2e <argraw+0x30>
    return p->trapframe->a4;
    80002a4a:	6d3c                	ld	a5,88(a0)
    80002a4c:	6bc8                	ld	a0,144(a5)
    80002a4e:	b7c5                	j	80002a2e <argraw+0x30>
    return p->trapframe->a5;
    80002a50:	6d3c                	ld	a5,88(a0)
    80002a52:	6fc8                	ld	a0,152(a5)
    80002a54:	bfe9                	j	80002a2e <argraw+0x30>
  panic("argraw");
    80002a56:	00006517          	auipc	a0,0x6
    80002a5a:	98a50513          	addi	a0,a0,-1654 # 800083e0 <states.0+0x140>
    80002a5e:	ffffe097          	auipc	ra,0xffffe
    80002a62:	aea080e7          	jalr	-1302(ra) # 80000548 <panic>

0000000080002a66 <fetchaddr>:
{
    80002a66:	1101                	addi	sp,sp,-32
    80002a68:	ec06                	sd	ra,24(sp)
    80002a6a:	e822                	sd	s0,16(sp)
    80002a6c:	e426                	sd	s1,8(sp)
    80002a6e:	e04a                	sd	s2,0(sp)
    80002a70:	1000                	addi	s0,sp,32
    80002a72:	84aa                	mv	s1,a0
    80002a74:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a76:	fffff097          	auipc	ra,0xfffff
    80002a7a:	fc8080e7          	jalr	-56(ra) # 80001a3e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a7e:	653c                	ld	a5,72(a0)
    80002a80:	02f4f863          	bgeu	s1,a5,80002ab0 <fetchaddr+0x4a>
    80002a84:	00848713          	addi	a4,s1,8
    80002a88:	02e7e663          	bltu	a5,a4,80002ab4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a8c:	46a1                	li	a3,8
    80002a8e:	8626                	mv	a2,s1
    80002a90:	85ca                	mv	a1,s2
    80002a92:	6928                	ld	a0,80(a0)
    80002a94:	fffff097          	auipc	ra,0xfffff
    80002a98:	d2c080e7          	jalr	-724(ra) # 800017c0 <copyin>
    80002a9c:	00a03533          	snez	a0,a0
    80002aa0:	40a00533          	neg	a0,a0
}
    80002aa4:	60e2                	ld	ra,24(sp)
    80002aa6:	6442                	ld	s0,16(sp)
    80002aa8:	64a2                	ld	s1,8(sp)
    80002aaa:	6902                	ld	s2,0(sp)
    80002aac:	6105                	addi	sp,sp,32
    80002aae:	8082                	ret
    return -1;
    80002ab0:	557d                	li	a0,-1
    80002ab2:	bfcd                	j	80002aa4 <fetchaddr+0x3e>
    80002ab4:	557d                	li	a0,-1
    80002ab6:	b7fd                	j	80002aa4 <fetchaddr+0x3e>

0000000080002ab8 <fetchstr>:
{
    80002ab8:	7179                	addi	sp,sp,-48
    80002aba:	f406                	sd	ra,40(sp)
    80002abc:	f022                	sd	s0,32(sp)
    80002abe:	ec26                	sd	s1,24(sp)
    80002ac0:	e84a                	sd	s2,16(sp)
    80002ac2:	e44e                	sd	s3,8(sp)
    80002ac4:	1800                	addi	s0,sp,48
    80002ac6:	892a                	mv	s2,a0
    80002ac8:	84ae                	mv	s1,a1
    80002aca:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002acc:	fffff097          	auipc	ra,0xfffff
    80002ad0:	f72080e7          	jalr	-142(ra) # 80001a3e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ad4:	86ce                	mv	a3,s3
    80002ad6:	864a                	mv	a2,s2
    80002ad8:	85a6                	mv	a1,s1
    80002ada:	6928                	ld	a0,80(a0)
    80002adc:	fffff097          	auipc	ra,0xfffff
    80002ae0:	d72080e7          	jalr	-654(ra) # 8000184e <copyinstr>
  if(err < 0)
    80002ae4:	00054763          	bltz	a0,80002af2 <fetchstr+0x3a>
  return strlen(buf);
    80002ae8:	8526                	mv	a0,s1
    80002aea:	ffffe097          	auipc	ra,0xffffe
    80002aee:	47a080e7          	jalr	1146(ra) # 80000f64 <strlen>
}
    80002af2:	70a2                	ld	ra,40(sp)
    80002af4:	7402                	ld	s0,32(sp)
    80002af6:	64e2                	ld	s1,24(sp)
    80002af8:	6942                	ld	s2,16(sp)
    80002afa:	69a2                	ld	s3,8(sp)
    80002afc:	6145                	addi	sp,sp,48
    80002afe:	8082                	ret

0000000080002b00 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b00:	1101                	addi	sp,sp,-32
    80002b02:	ec06                	sd	ra,24(sp)
    80002b04:	e822                	sd	s0,16(sp)
    80002b06:	e426                	sd	s1,8(sp)
    80002b08:	1000                	addi	s0,sp,32
    80002b0a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b0c:	00000097          	auipc	ra,0x0
    80002b10:	ef2080e7          	jalr	-270(ra) # 800029fe <argraw>
    80002b14:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b16:	4501                	li	a0,0
    80002b18:	60e2                	ld	ra,24(sp)
    80002b1a:	6442                	ld	s0,16(sp)
    80002b1c:	64a2                	ld	s1,8(sp)
    80002b1e:	6105                	addi	sp,sp,32
    80002b20:	8082                	ret

0000000080002b22 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b22:	1101                	addi	sp,sp,-32
    80002b24:	ec06                	sd	ra,24(sp)
    80002b26:	e822                	sd	s0,16(sp)
    80002b28:	e426                	sd	s1,8(sp)
    80002b2a:	1000                	addi	s0,sp,32
    80002b2c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b2e:	00000097          	auipc	ra,0x0
    80002b32:	ed0080e7          	jalr	-304(ra) # 800029fe <argraw>
    80002b36:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b38:	4501                	li	a0,0
    80002b3a:	60e2                	ld	ra,24(sp)
    80002b3c:	6442                	ld	s0,16(sp)
    80002b3e:	64a2                	ld	s1,8(sp)
    80002b40:	6105                	addi	sp,sp,32
    80002b42:	8082                	ret

0000000080002b44 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b44:	1101                	addi	sp,sp,-32
    80002b46:	ec06                	sd	ra,24(sp)
    80002b48:	e822                	sd	s0,16(sp)
    80002b4a:	e426                	sd	s1,8(sp)
    80002b4c:	e04a                	sd	s2,0(sp)
    80002b4e:	1000                	addi	s0,sp,32
    80002b50:	84ae                	mv	s1,a1
    80002b52:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b54:	00000097          	auipc	ra,0x0
    80002b58:	eaa080e7          	jalr	-342(ra) # 800029fe <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b5c:	864a                	mv	a2,s2
    80002b5e:	85a6                	mv	a1,s1
    80002b60:	00000097          	auipc	ra,0x0
    80002b64:	f58080e7          	jalr	-168(ra) # 80002ab8 <fetchstr>
}
    80002b68:	60e2                	ld	ra,24(sp)
    80002b6a:	6442                	ld	s0,16(sp)
    80002b6c:	64a2                	ld	s1,8(sp)
    80002b6e:	6902                	ld	s2,0(sp)
    80002b70:	6105                	addi	sp,sp,32
    80002b72:	8082                	ret

0000000080002b74 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002b74:	1101                	addi	sp,sp,-32
    80002b76:	ec06                	sd	ra,24(sp)
    80002b78:	e822                	sd	s0,16(sp)
    80002b7a:	e426                	sd	s1,8(sp)
    80002b7c:	e04a                	sd	s2,0(sp)
    80002b7e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b80:	fffff097          	auipc	ra,0xfffff
    80002b84:	ebe080e7          	jalr	-322(ra) # 80001a3e <myproc>
    80002b88:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b8a:	05853903          	ld	s2,88(a0)
    80002b8e:	0a893783          	ld	a5,168(s2)
    80002b92:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b96:	37fd                	addiw	a5,a5,-1
    80002b98:	4751                	li	a4,20
    80002b9a:	00f76f63          	bltu	a4,a5,80002bb8 <syscall+0x44>
    80002b9e:	00369713          	slli	a4,a3,0x3
    80002ba2:	00006797          	auipc	a5,0x6
    80002ba6:	87e78793          	addi	a5,a5,-1922 # 80008420 <syscalls>
    80002baa:	97ba                	add	a5,a5,a4
    80002bac:	639c                	ld	a5,0(a5)
    80002bae:	c789                	beqz	a5,80002bb8 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002bb0:	9782                	jalr	a5
    80002bb2:	06a93823          	sd	a0,112(s2)
    80002bb6:	a839                	j	80002bd4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bb8:	15848613          	addi	a2,s1,344
    80002bbc:	5c8c                	lw	a1,56(s1)
    80002bbe:	00006517          	auipc	a0,0x6
    80002bc2:	82a50513          	addi	a0,a0,-2006 # 800083e8 <states.0+0x148>
    80002bc6:	ffffe097          	auipc	ra,0xffffe
    80002bca:	9cc080e7          	jalr	-1588(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bce:	6cbc                	ld	a5,88(s1)
    80002bd0:	577d                	li	a4,-1
    80002bd2:	fbb8                	sd	a4,112(a5)
  }
}
    80002bd4:	60e2                	ld	ra,24(sp)
    80002bd6:	6442                	ld	s0,16(sp)
    80002bd8:	64a2                	ld	s1,8(sp)
    80002bda:	6902                	ld	s2,0(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002be8:	fec40593          	addi	a1,s0,-20
    80002bec:	4501                	li	a0,0
    80002bee:	00000097          	auipc	ra,0x0
    80002bf2:	f12080e7          	jalr	-238(ra) # 80002b00 <argint>
    return -1;
    80002bf6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002bf8:	00054963          	bltz	a0,80002c0a <sys_exit+0x2a>
  exit(n);
    80002bfc:	fec42503          	lw	a0,-20(s0)
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	50e080e7          	jalr	1294(ra) # 8000210e <exit>
  return 0;  // not reached
    80002c08:	4781                	li	a5,0
}
    80002c0a:	853e                	mv	a0,a5
    80002c0c:	60e2                	ld	ra,24(sp)
    80002c0e:	6442                	ld	s0,16(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret

0000000080002c14 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c14:	1141                	addi	sp,sp,-16
    80002c16:	e406                	sd	ra,8(sp)
    80002c18:	e022                	sd	s0,0(sp)
    80002c1a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c1c:	fffff097          	auipc	ra,0xfffff
    80002c20:	e22080e7          	jalr	-478(ra) # 80001a3e <myproc>
}
    80002c24:	5d08                	lw	a0,56(a0)
    80002c26:	60a2                	ld	ra,8(sp)
    80002c28:	6402                	ld	s0,0(sp)
    80002c2a:	0141                	addi	sp,sp,16
    80002c2c:	8082                	ret

0000000080002c2e <sys_fork>:

uint64
sys_fork(void)
{
    80002c2e:	1141                	addi	sp,sp,-16
    80002c30:	e406                	sd	ra,8(sp)
    80002c32:	e022                	sd	s0,0(sp)
    80002c34:	0800                	addi	s0,sp,16
  return fork();
    80002c36:	fffff097          	auipc	ra,0xfffff
    80002c3a:	1cc080e7          	jalr	460(ra) # 80001e02 <fork>
}
    80002c3e:	60a2                	ld	ra,8(sp)
    80002c40:	6402                	ld	s0,0(sp)
    80002c42:	0141                	addi	sp,sp,16
    80002c44:	8082                	ret

0000000080002c46 <sys_wait>:

uint64
sys_wait(void)
{
    80002c46:	1101                	addi	sp,sp,-32
    80002c48:	ec06                	sd	ra,24(sp)
    80002c4a:	e822                	sd	s0,16(sp)
    80002c4c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c4e:	fe840593          	addi	a1,s0,-24
    80002c52:	4501                	li	a0,0
    80002c54:	00000097          	auipc	ra,0x0
    80002c58:	ece080e7          	jalr	-306(ra) # 80002b22 <argaddr>
    80002c5c:	87aa                	mv	a5,a0
    return -1;
    80002c5e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c60:	0007c863          	bltz	a5,80002c70 <sys_wait+0x2a>
  return wait(p);
    80002c64:	fe843503          	ld	a0,-24(s0)
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	66a080e7          	jalr	1642(ra) # 800022d2 <wait>
}
    80002c70:	60e2                	ld	ra,24(sp)
    80002c72:	6442                	ld	s0,16(sp)
    80002c74:	6105                	addi	sp,sp,32
    80002c76:	8082                	ret

0000000080002c78 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c78:	7179                	addi	sp,sp,-48
    80002c7a:	f406                	sd	ra,40(sp)
    80002c7c:	f022                	sd	s0,32(sp)
    80002c7e:	ec26                	sd	s1,24(sp)
    80002c80:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c82:	fdc40593          	addi	a1,s0,-36
    80002c86:	4501                	li	a0,0
    80002c88:	00000097          	auipc	ra,0x0
    80002c8c:	e78080e7          	jalr	-392(ra) # 80002b00 <argint>
    80002c90:	87aa                	mv	a5,a0
    return -1;
    80002c92:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002c94:	0207c063          	bltz	a5,80002cb4 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002c98:	fffff097          	auipc	ra,0xfffff
    80002c9c:	da6080e7          	jalr	-602(ra) # 80001a3e <myproc>
    80002ca0:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002ca2:	fdc42503          	lw	a0,-36(s0)
    80002ca6:	fffff097          	auipc	ra,0xfffff
    80002caa:	0e4080e7          	jalr	228(ra) # 80001d8a <growproc>
    80002cae:	00054863          	bltz	a0,80002cbe <sys_sbrk+0x46>
    return -1;
  return addr;
    80002cb2:	8526                	mv	a0,s1
}
    80002cb4:	70a2                	ld	ra,40(sp)
    80002cb6:	7402                	ld	s0,32(sp)
    80002cb8:	64e2                	ld	s1,24(sp)
    80002cba:	6145                	addi	sp,sp,48
    80002cbc:	8082                	ret
    return -1;
    80002cbe:	557d                	li	a0,-1
    80002cc0:	bfd5                	j	80002cb4 <sys_sbrk+0x3c>

0000000080002cc2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cc2:	7139                	addi	sp,sp,-64
    80002cc4:	fc06                	sd	ra,56(sp)
    80002cc6:	f822                	sd	s0,48(sp)
    80002cc8:	f426                	sd	s1,40(sp)
    80002cca:	f04a                	sd	s2,32(sp)
    80002ccc:	ec4e                	sd	s3,24(sp)
    80002cce:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002cd0:	fcc40593          	addi	a1,s0,-52
    80002cd4:	4501                	li	a0,0
    80002cd6:	00000097          	auipc	ra,0x0
    80002cda:	e2a080e7          	jalr	-470(ra) # 80002b00 <argint>
    return -1;
    80002cde:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ce0:	06054563          	bltz	a0,80002d4a <sys_sleep+0x88>
  acquire(&tickslock);
    80002ce4:	00014517          	auipc	a0,0x14
    80002ce8:	3c450513          	addi	a0,a0,964 # 800170a8 <tickslock>
    80002cec:	ffffe097          	auipc	ra,0xffffe
    80002cf0:	ffa080e7          	jalr	-6(ra) # 80000ce6 <acquire>
  ticks0 = ticks;
    80002cf4:	00006917          	auipc	s2,0x6
    80002cf8:	33492903          	lw	s2,820(s2) # 80009028 <ticks>
  while(ticks - ticks0 < n){
    80002cfc:	fcc42783          	lw	a5,-52(s0)
    80002d00:	cf85                	beqz	a5,80002d38 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d02:	00014997          	auipc	s3,0x14
    80002d06:	3a698993          	addi	s3,s3,934 # 800170a8 <tickslock>
    80002d0a:	00006497          	auipc	s1,0x6
    80002d0e:	31e48493          	addi	s1,s1,798 # 80009028 <ticks>
    if(myproc()->killed){
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	d2c080e7          	jalr	-724(ra) # 80001a3e <myproc>
    80002d1a:	591c                	lw	a5,48(a0)
    80002d1c:	ef9d                	bnez	a5,80002d5a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d1e:	85ce                	mv	a1,s3
    80002d20:	8526                	mv	a0,s1
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	532080e7          	jalr	1330(ra) # 80002254 <sleep>
  while(ticks - ticks0 < n){
    80002d2a:	409c                	lw	a5,0(s1)
    80002d2c:	412787bb          	subw	a5,a5,s2
    80002d30:	fcc42703          	lw	a4,-52(s0)
    80002d34:	fce7efe3          	bltu	a5,a4,80002d12 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d38:	00014517          	auipc	a0,0x14
    80002d3c:	37050513          	addi	a0,a0,880 # 800170a8 <tickslock>
    80002d40:	ffffe097          	auipc	ra,0xffffe
    80002d44:	05a080e7          	jalr	90(ra) # 80000d9a <release>
  return 0;
    80002d48:	4781                	li	a5,0
}
    80002d4a:	853e                	mv	a0,a5
    80002d4c:	70e2                	ld	ra,56(sp)
    80002d4e:	7442                	ld	s0,48(sp)
    80002d50:	74a2                	ld	s1,40(sp)
    80002d52:	7902                	ld	s2,32(sp)
    80002d54:	69e2                	ld	s3,24(sp)
    80002d56:	6121                	addi	sp,sp,64
    80002d58:	8082                	ret
      release(&tickslock);
    80002d5a:	00014517          	auipc	a0,0x14
    80002d5e:	34e50513          	addi	a0,a0,846 # 800170a8 <tickslock>
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	038080e7          	jalr	56(ra) # 80000d9a <release>
      return -1;
    80002d6a:	57fd                	li	a5,-1
    80002d6c:	bff9                	j	80002d4a <sys_sleep+0x88>

0000000080002d6e <sys_kill>:

uint64
sys_kill(void)
{
    80002d6e:	1101                	addi	sp,sp,-32
    80002d70:	ec06                	sd	ra,24(sp)
    80002d72:	e822                	sd	s0,16(sp)
    80002d74:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d76:	fec40593          	addi	a1,s0,-20
    80002d7a:	4501                	li	a0,0
    80002d7c:	00000097          	auipc	ra,0x0
    80002d80:	d84080e7          	jalr	-636(ra) # 80002b00 <argint>
    80002d84:	87aa                	mv	a5,a0
    return -1;
    80002d86:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d88:	0007c863          	bltz	a5,80002d98 <sys_kill+0x2a>
  return kill(pid);
    80002d8c:	fec42503          	lw	a0,-20(s0)
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	6ae080e7          	jalr	1710(ra) # 8000243e <kill>
}
    80002d98:	60e2                	ld	ra,24(sp)
    80002d9a:	6442                	ld	s0,16(sp)
    80002d9c:	6105                	addi	sp,sp,32
    80002d9e:	8082                	ret

0000000080002da0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002da0:	1101                	addi	sp,sp,-32
    80002da2:	ec06                	sd	ra,24(sp)
    80002da4:	e822                	sd	s0,16(sp)
    80002da6:	e426                	sd	s1,8(sp)
    80002da8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002daa:	00014517          	auipc	a0,0x14
    80002dae:	2fe50513          	addi	a0,a0,766 # 800170a8 <tickslock>
    80002db2:	ffffe097          	auipc	ra,0xffffe
    80002db6:	f34080e7          	jalr	-204(ra) # 80000ce6 <acquire>
  xticks = ticks;
    80002dba:	00006497          	auipc	s1,0x6
    80002dbe:	26e4a483          	lw	s1,622(s1) # 80009028 <ticks>
  release(&tickslock);
    80002dc2:	00014517          	auipc	a0,0x14
    80002dc6:	2e650513          	addi	a0,a0,742 # 800170a8 <tickslock>
    80002dca:	ffffe097          	auipc	ra,0xffffe
    80002dce:	fd0080e7          	jalr	-48(ra) # 80000d9a <release>
  return xticks;
}
    80002dd2:	02049513          	slli	a0,s1,0x20
    80002dd6:	9101                	srli	a0,a0,0x20
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	64a2                	ld	s1,8(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret

0000000080002de2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002de2:	7179                	addi	sp,sp,-48
    80002de4:	f406                	sd	ra,40(sp)
    80002de6:	f022                	sd	s0,32(sp)
    80002de8:	ec26                	sd	s1,24(sp)
    80002dea:	e84a                	sd	s2,16(sp)
    80002dec:	e44e                	sd	s3,8(sp)
    80002dee:	e052                	sd	s4,0(sp)
    80002df0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002df2:	00005597          	auipc	a1,0x5
    80002df6:	6de58593          	addi	a1,a1,1758 # 800084d0 <syscalls+0xb0>
    80002dfa:	00014517          	auipc	a0,0x14
    80002dfe:	2c650513          	addi	a0,a0,710 # 800170c0 <bcache>
    80002e02:	ffffe097          	auipc	ra,0xffffe
    80002e06:	e54080e7          	jalr	-428(ra) # 80000c56 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e0a:	0001c797          	auipc	a5,0x1c
    80002e0e:	2b678793          	addi	a5,a5,694 # 8001f0c0 <bcache+0x8000>
    80002e12:	0001c717          	auipc	a4,0x1c
    80002e16:	51670713          	addi	a4,a4,1302 # 8001f328 <bcache+0x8268>
    80002e1a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e1e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e22:	00014497          	auipc	s1,0x14
    80002e26:	2b648493          	addi	s1,s1,694 # 800170d8 <bcache+0x18>
    b->next = bcache.head.next;
    80002e2a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e2c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e2e:	00005a17          	auipc	s4,0x5
    80002e32:	6aaa0a13          	addi	s4,s4,1706 # 800084d8 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002e36:	2b893783          	ld	a5,696(s2)
    80002e3a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e3c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e40:	85d2                	mv	a1,s4
    80002e42:	01048513          	addi	a0,s1,16
    80002e46:	00001097          	auipc	ra,0x1
    80002e4a:	496080e7          	jalr	1174(ra) # 800042dc <initsleeplock>
    bcache.head.next->prev = b;
    80002e4e:	2b893783          	ld	a5,696(s2)
    80002e52:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e54:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e58:	45848493          	addi	s1,s1,1112
    80002e5c:	fd349de3          	bne	s1,s3,80002e36 <binit+0x54>
  }
}
    80002e60:	70a2                	ld	ra,40(sp)
    80002e62:	7402                	ld	s0,32(sp)
    80002e64:	64e2                	ld	s1,24(sp)
    80002e66:	6942                	ld	s2,16(sp)
    80002e68:	69a2                	ld	s3,8(sp)
    80002e6a:	6a02                	ld	s4,0(sp)
    80002e6c:	6145                	addi	sp,sp,48
    80002e6e:	8082                	ret

0000000080002e70 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e70:	7179                	addi	sp,sp,-48
    80002e72:	f406                	sd	ra,40(sp)
    80002e74:	f022                	sd	s0,32(sp)
    80002e76:	ec26                	sd	s1,24(sp)
    80002e78:	e84a                	sd	s2,16(sp)
    80002e7a:	e44e                	sd	s3,8(sp)
    80002e7c:	1800                	addi	s0,sp,48
    80002e7e:	892a                	mv	s2,a0
    80002e80:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e82:	00014517          	auipc	a0,0x14
    80002e86:	23e50513          	addi	a0,a0,574 # 800170c0 <bcache>
    80002e8a:	ffffe097          	auipc	ra,0xffffe
    80002e8e:	e5c080e7          	jalr	-420(ra) # 80000ce6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e92:	0001c497          	auipc	s1,0x1c
    80002e96:	4e64b483          	ld	s1,1254(s1) # 8001f378 <bcache+0x82b8>
    80002e9a:	0001c797          	auipc	a5,0x1c
    80002e9e:	48e78793          	addi	a5,a5,1166 # 8001f328 <bcache+0x8268>
    80002ea2:	02f48f63          	beq	s1,a5,80002ee0 <bread+0x70>
    80002ea6:	873e                	mv	a4,a5
    80002ea8:	a021                	j	80002eb0 <bread+0x40>
    80002eaa:	68a4                	ld	s1,80(s1)
    80002eac:	02e48a63          	beq	s1,a4,80002ee0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002eb0:	449c                	lw	a5,8(s1)
    80002eb2:	ff279ce3          	bne	a5,s2,80002eaa <bread+0x3a>
    80002eb6:	44dc                	lw	a5,12(s1)
    80002eb8:	ff3799e3          	bne	a5,s3,80002eaa <bread+0x3a>
      b->refcnt++;
    80002ebc:	40bc                	lw	a5,64(s1)
    80002ebe:	2785                	addiw	a5,a5,1
    80002ec0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ec2:	00014517          	auipc	a0,0x14
    80002ec6:	1fe50513          	addi	a0,a0,510 # 800170c0 <bcache>
    80002eca:	ffffe097          	auipc	ra,0xffffe
    80002ece:	ed0080e7          	jalr	-304(ra) # 80000d9a <release>
      acquiresleep(&b->lock);
    80002ed2:	01048513          	addi	a0,s1,16
    80002ed6:	00001097          	auipc	ra,0x1
    80002eda:	440080e7          	jalr	1088(ra) # 80004316 <acquiresleep>
      return b;
    80002ede:	a8b9                	j	80002f3c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ee0:	0001c497          	auipc	s1,0x1c
    80002ee4:	4904b483          	ld	s1,1168(s1) # 8001f370 <bcache+0x82b0>
    80002ee8:	0001c797          	auipc	a5,0x1c
    80002eec:	44078793          	addi	a5,a5,1088 # 8001f328 <bcache+0x8268>
    80002ef0:	00f48863          	beq	s1,a5,80002f00 <bread+0x90>
    80002ef4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ef6:	40bc                	lw	a5,64(s1)
    80002ef8:	cf81                	beqz	a5,80002f10 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002efa:	64a4                	ld	s1,72(s1)
    80002efc:	fee49de3          	bne	s1,a4,80002ef6 <bread+0x86>
  panic("bget: no buffers");
    80002f00:	00005517          	auipc	a0,0x5
    80002f04:	5e050513          	addi	a0,a0,1504 # 800084e0 <syscalls+0xc0>
    80002f08:	ffffd097          	auipc	ra,0xffffd
    80002f0c:	640080e7          	jalr	1600(ra) # 80000548 <panic>
      b->dev = dev;
    80002f10:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f14:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f18:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f1c:	4785                	li	a5,1
    80002f1e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f20:	00014517          	auipc	a0,0x14
    80002f24:	1a050513          	addi	a0,a0,416 # 800170c0 <bcache>
    80002f28:	ffffe097          	auipc	ra,0xffffe
    80002f2c:	e72080e7          	jalr	-398(ra) # 80000d9a <release>
      acquiresleep(&b->lock);
    80002f30:	01048513          	addi	a0,s1,16
    80002f34:	00001097          	auipc	ra,0x1
    80002f38:	3e2080e7          	jalr	994(ra) # 80004316 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f3c:	409c                	lw	a5,0(s1)
    80002f3e:	cb89                	beqz	a5,80002f50 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f40:	8526                	mv	a0,s1
    80002f42:	70a2                	ld	ra,40(sp)
    80002f44:	7402                	ld	s0,32(sp)
    80002f46:	64e2                	ld	s1,24(sp)
    80002f48:	6942                	ld	s2,16(sp)
    80002f4a:	69a2                	ld	s3,8(sp)
    80002f4c:	6145                	addi	sp,sp,48
    80002f4e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f50:	4581                	li	a1,0
    80002f52:	8526                	mv	a0,s1
    80002f54:	00003097          	auipc	ra,0x3
    80002f58:	efe080e7          	jalr	-258(ra) # 80005e52 <virtio_disk_rw>
    b->valid = 1;
    80002f5c:	4785                	li	a5,1
    80002f5e:	c09c                	sw	a5,0(s1)
  return b;
    80002f60:	b7c5                	j	80002f40 <bread+0xd0>

0000000080002f62 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f62:	1101                	addi	sp,sp,-32
    80002f64:	ec06                	sd	ra,24(sp)
    80002f66:	e822                	sd	s0,16(sp)
    80002f68:	e426                	sd	s1,8(sp)
    80002f6a:	1000                	addi	s0,sp,32
    80002f6c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f6e:	0541                	addi	a0,a0,16
    80002f70:	00001097          	auipc	ra,0x1
    80002f74:	440080e7          	jalr	1088(ra) # 800043b0 <holdingsleep>
    80002f78:	cd01                	beqz	a0,80002f90 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f7a:	4585                	li	a1,1
    80002f7c:	8526                	mv	a0,s1
    80002f7e:	00003097          	auipc	ra,0x3
    80002f82:	ed4080e7          	jalr	-300(ra) # 80005e52 <virtio_disk_rw>
}
    80002f86:	60e2                	ld	ra,24(sp)
    80002f88:	6442                	ld	s0,16(sp)
    80002f8a:	64a2                	ld	s1,8(sp)
    80002f8c:	6105                	addi	sp,sp,32
    80002f8e:	8082                	ret
    panic("bwrite");
    80002f90:	00005517          	auipc	a0,0x5
    80002f94:	56850513          	addi	a0,a0,1384 # 800084f8 <syscalls+0xd8>
    80002f98:	ffffd097          	auipc	ra,0xffffd
    80002f9c:	5b0080e7          	jalr	1456(ra) # 80000548 <panic>

0000000080002fa0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fa0:	1101                	addi	sp,sp,-32
    80002fa2:	ec06                	sd	ra,24(sp)
    80002fa4:	e822                	sd	s0,16(sp)
    80002fa6:	e426                	sd	s1,8(sp)
    80002fa8:	e04a                	sd	s2,0(sp)
    80002faa:	1000                	addi	s0,sp,32
    80002fac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fae:	01050913          	addi	s2,a0,16
    80002fb2:	854a                	mv	a0,s2
    80002fb4:	00001097          	auipc	ra,0x1
    80002fb8:	3fc080e7          	jalr	1020(ra) # 800043b0 <holdingsleep>
    80002fbc:	c925                	beqz	a0,8000302c <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80002fbe:	854a                	mv	a0,s2
    80002fc0:	00001097          	auipc	ra,0x1
    80002fc4:	3ac080e7          	jalr	940(ra) # 8000436c <releasesleep>

  acquire(&bcache.lock);
    80002fc8:	00014517          	auipc	a0,0x14
    80002fcc:	0f850513          	addi	a0,a0,248 # 800170c0 <bcache>
    80002fd0:	ffffe097          	auipc	ra,0xffffe
    80002fd4:	d16080e7          	jalr	-746(ra) # 80000ce6 <acquire>
  b->refcnt--;
    80002fd8:	40bc                	lw	a5,64(s1)
    80002fda:	37fd                	addiw	a5,a5,-1
    80002fdc:	0007871b          	sext.w	a4,a5
    80002fe0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fe2:	e71d                	bnez	a4,80003010 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fe4:	68b8                	ld	a4,80(s1)
    80002fe6:	64bc                	ld	a5,72(s1)
    80002fe8:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002fea:	68b8                	ld	a4,80(s1)
    80002fec:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fee:	0001c797          	auipc	a5,0x1c
    80002ff2:	0d278793          	addi	a5,a5,210 # 8001f0c0 <bcache+0x8000>
    80002ff6:	2b87b703          	ld	a4,696(a5)
    80002ffa:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ffc:	0001c717          	auipc	a4,0x1c
    80003000:	32c70713          	addi	a4,a4,812 # 8001f328 <bcache+0x8268>
    80003004:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003006:	2b87b703          	ld	a4,696(a5)
    8000300a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000300c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003010:	00014517          	auipc	a0,0x14
    80003014:	0b050513          	addi	a0,a0,176 # 800170c0 <bcache>
    80003018:	ffffe097          	auipc	ra,0xffffe
    8000301c:	d82080e7          	jalr	-638(ra) # 80000d9a <release>
}
    80003020:	60e2                	ld	ra,24(sp)
    80003022:	6442                	ld	s0,16(sp)
    80003024:	64a2                	ld	s1,8(sp)
    80003026:	6902                	ld	s2,0(sp)
    80003028:	6105                	addi	sp,sp,32
    8000302a:	8082                	ret
    panic("brelse");
    8000302c:	00005517          	auipc	a0,0x5
    80003030:	4d450513          	addi	a0,a0,1236 # 80008500 <syscalls+0xe0>
    80003034:	ffffd097          	auipc	ra,0xffffd
    80003038:	514080e7          	jalr	1300(ra) # 80000548 <panic>

000000008000303c <bpin>:

void
bpin(struct buf *b) {
    8000303c:	1101                	addi	sp,sp,-32
    8000303e:	ec06                	sd	ra,24(sp)
    80003040:	e822                	sd	s0,16(sp)
    80003042:	e426                	sd	s1,8(sp)
    80003044:	1000                	addi	s0,sp,32
    80003046:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003048:	00014517          	auipc	a0,0x14
    8000304c:	07850513          	addi	a0,a0,120 # 800170c0 <bcache>
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	c96080e7          	jalr	-874(ra) # 80000ce6 <acquire>
  b->refcnt++;
    80003058:	40bc                	lw	a5,64(s1)
    8000305a:	2785                	addiw	a5,a5,1
    8000305c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000305e:	00014517          	auipc	a0,0x14
    80003062:	06250513          	addi	a0,a0,98 # 800170c0 <bcache>
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	d34080e7          	jalr	-716(ra) # 80000d9a <release>
}
    8000306e:	60e2                	ld	ra,24(sp)
    80003070:	6442                	ld	s0,16(sp)
    80003072:	64a2                	ld	s1,8(sp)
    80003074:	6105                	addi	sp,sp,32
    80003076:	8082                	ret

0000000080003078 <bunpin>:

void
bunpin(struct buf *b) {
    80003078:	1101                	addi	sp,sp,-32
    8000307a:	ec06                	sd	ra,24(sp)
    8000307c:	e822                	sd	s0,16(sp)
    8000307e:	e426                	sd	s1,8(sp)
    80003080:	1000                	addi	s0,sp,32
    80003082:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003084:	00014517          	auipc	a0,0x14
    80003088:	03c50513          	addi	a0,a0,60 # 800170c0 <bcache>
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	c5a080e7          	jalr	-934(ra) # 80000ce6 <acquire>
  b->refcnt--;
    80003094:	40bc                	lw	a5,64(s1)
    80003096:	37fd                	addiw	a5,a5,-1
    80003098:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000309a:	00014517          	auipc	a0,0x14
    8000309e:	02650513          	addi	a0,a0,38 # 800170c0 <bcache>
    800030a2:	ffffe097          	auipc	ra,0xffffe
    800030a6:	cf8080e7          	jalr	-776(ra) # 80000d9a <release>
}
    800030aa:	60e2                	ld	ra,24(sp)
    800030ac:	6442                	ld	s0,16(sp)
    800030ae:	64a2                	ld	s1,8(sp)
    800030b0:	6105                	addi	sp,sp,32
    800030b2:	8082                	ret

00000000800030b4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030b4:	1101                	addi	sp,sp,-32
    800030b6:	ec06                	sd	ra,24(sp)
    800030b8:	e822                	sd	s0,16(sp)
    800030ba:	e426                	sd	s1,8(sp)
    800030bc:	e04a                	sd	s2,0(sp)
    800030be:	1000                	addi	s0,sp,32
    800030c0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030c2:	00d5d59b          	srliw	a1,a1,0xd
    800030c6:	0001c797          	auipc	a5,0x1c
    800030ca:	6d67a783          	lw	a5,1750(a5) # 8001f79c <sb+0x1c>
    800030ce:	9dbd                	addw	a1,a1,a5
    800030d0:	00000097          	auipc	ra,0x0
    800030d4:	da0080e7          	jalr	-608(ra) # 80002e70 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030d8:	0074f713          	andi	a4,s1,7
    800030dc:	4785                	li	a5,1
    800030de:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030e2:	14ce                	slli	s1,s1,0x33
    800030e4:	90d9                	srli	s1,s1,0x36
    800030e6:	00950733          	add	a4,a0,s1
    800030ea:	05874703          	lbu	a4,88(a4)
    800030ee:	00e7f6b3          	and	a3,a5,a4
    800030f2:	c69d                	beqz	a3,80003120 <bfree+0x6c>
    800030f4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030f6:	94aa                	add	s1,s1,a0
    800030f8:	fff7c793          	not	a5,a5
    800030fc:	8f7d                	and	a4,a4,a5
    800030fe:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003102:	00001097          	auipc	ra,0x1
    80003106:	0ee080e7          	jalr	238(ra) # 800041f0 <log_write>
  brelse(bp);
    8000310a:	854a                	mv	a0,s2
    8000310c:	00000097          	auipc	ra,0x0
    80003110:	e94080e7          	jalr	-364(ra) # 80002fa0 <brelse>
}
    80003114:	60e2                	ld	ra,24(sp)
    80003116:	6442                	ld	s0,16(sp)
    80003118:	64a2                	ld	s1,8(sp)
    8000311a:	6902                	ld	s2,0(sp)
    8000311c:	6105                	addi	sp,sp,32
    8000311e:	8082                	ret
    panic("freeing free block");
    80003120:	00005517          	auipc	a0,0x5
    80003124:	3e850513          	addi	a0,a0,1000 # 80008508 <syscalls+0xe8>
    80003128:	ffffd097          	auipc	ra,0xffffd
    8000312c:	420080e7          	jalr	1056(ra) # 80000548 <panic>

0000000080003130 <balloc>:
{
    80003130:	711d                	addi	sp,sp,-96
    80003132:	ec86                	sd	ra,88(sp)
    80003134:	e8a2                	sd	s0,80(sp)
    80003136:	e4a6                	sd	s1,72(sp)
    80003138:	e0ca                	sd	s2,64(sp)
    8000313a:	fc4e                	sd	s3,56(sp)
    8000313c:	f852                	sd	s4,48(sp)
    8000313e:	f456                	sd	s5,40(sp)
    80003140:	f05a                	sd	s6,32(sp)
    80003142:	ec5e                	sd	s7,24(sp)
    80003144:	e862                	sd	s8,16(sp)
    80003146:	e466                	sd	s9,8(sp)
    80003148:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000314a:	0001c797          	auipc	a5,0x1c
    8000314e:	63a7a783          	lw	a5,1594(a5) # 8001f784 <sb+0x4>
    80003152:	cbc1                	beqz	a5,800031e2 <balloc+0xb2>
    80003154:	8baa                	mv	s7,a0
    80003156:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003158:	0001cb17          	auipc	s6,0x1c
    8000315c:	628b0b13          	addi	s6,s6,1576 # 8001f780 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003160:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003162:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003164:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003166:	6c89                	lui	s9,0x2
    80003168:	a831                	j	80003184 <balloc+0x54>
    brelse(bp);
    8000316a:	854a                	mv	a0,s2
    8000316c:	00000097          	auipc	ra,0x0
    80003170:	e34080e7          	jalr	-460(ra) # 80002fa0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003174:	015c87bb          	addw	a5,s9,s5
    80003178:	00078a9b          	sext.w	s5,a5
    8000317c:	004b2703          	lw	a4,4(s6)
    80003180:	06eaf163          	bgeu	s5,a4,800031e2 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80003184:	41fad79b          	sraiw	a5,s5,0x1f
    80003188:	0137d79b          	srliw	a5,a5,0x13
    8000318c:	015787bb          	addw	a5,a5,s5
    80003190:	40d7d79b          	sraiw	a5,a5,0xd
    80003194:	01cb2583          	lw	a1,28(s6)
    80003198:	9dbd                	addw	a1,a1,a5
    8000319a:	855e                	mv	a0,s7
    8000319c:	00000097          	auipc	ra,0x0
    800031a0:	cd4080e7          	jalr	-812(ra) # 80002e70 <bread>
    800031a4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031a6:	004b2503          	lw	a0,4(s6)
    800031aa:	000a849b          	sext.w	s1,s5
    800031ae:	8762                	mv	a4,s8
    800031b0:	faa4fde3          	bgeu	s1,a0,8000316a <balloc+0x3a>
      m = 1 << (bi % 8);
    800031b4:	00777693          	andi	a3,a4,7
    800031b8:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031bc:	41f7579b          	sraiw	a5,a4,0x1f
    800031c0:	01d7d79b          	srliw	a5,a5,0x1d
    800031c4:	9fb9                	addw	a5,a5,a4
    800031c6:	4037d79b          	sraiw	a5,a5,0x3
    800031ca:	00f90633          	add	a2,s2,a5
    800031ce:	05864603          	lbu	a2,88(a2)
    800031d2:	00c6f5b3          	and	a1,a3,a2
    800031d6:	cd91                	beqz	a1,800031f2 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d8:	2705                	addiw	a4,a4,1
    800031da:	2485                	addiw	s1,s1,1
    800031dc:	fd471ae3          	bne	a4,s4,800031b0 <balloc+0x80>
    800031e0:	b769                	j	8000316a <balloc+0x3a>
  panic("balloc: out of blocks");
    800031e2:	00005517          	auipc	a0,0x5
    800031e6:	33e50513          	addi	a0,a0,830 # 80008520 <syscalls+0x100>
    800031ea:	ffffd097          	auipc	ra,0xffffd
    800031ee:	35e080e7          	jalr	862(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031f2:	97ca                	add	a5,a5,s2
    800031f4:	8e55                	or	a2,a2,a3
    800031f6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031fa:	854a                	mv	a0,s2
    800031fc:	00001097          	auipc	ra,0x1
    80003200:	ff4080e7          	jalr	-12(ra) # 800041f0 <log_write>
        brelse(bp);
    80003204:	854a                	mv	a0,s2
    80003206:	00000097          	auipc	ra,0x0
    8000320a:	d9a080e7          	jalr	-614(ra) # 80002fa0 <brelse>
  bp = bread(dev, bno);
    8000320e:	85a6                	mv	a1,s1
    80003210:	855e                	mv	a0,s7
    80003212:	00000097          	auipc	ra,0x0
    80003216:	c5e080e7          	jalr	-930(ra) # 80002e70 <bread>
    8000321a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000321c:	40000613          	li	a2,1024
    80003220:	4581                	li	a1,0
    80003222:	05850513          	addi	a0,a0,88
    80003226:	ffffe097          	auipc	ra,0xffffe
    8000322a:	bbc080e7          	jalr	-1092(ra) # 80000de2 <memset>
  log_write(bp);
    8000322e:	854a                	mv	a0,s2
    80003230:	00001097          	auipc	ra,0x1
    80003234:	fc0080e7          	jalr	-64(ra) # 800041f0 <log_write>
  brelse(bp);
    80003238:	854a                	mv	a0,s2
    8000323a:	00000097          	auipc	ra,0x0
    8000323e:	d66080e7          	jalr	-666(ra) # 80002fa0 <brelse>
}
    80003242:	8526                	mv	a0,s1
    80003244:	60e6                	ld	ra,88(sp)
    80003246:	6446                	ld	s0,80(sp)
    80003248:	64a6                	ld	s1,72(sp)
    8000324a:	6906                	ld	s2,64(sp)
    8000324c:	79e2                	ld	s3,56(sp)
    8000324e:	7a42                	ld	s4,48(sp)
    80003250:	7aa2                	ld	s5,40(sp)
    80003252:	7b02                	ld	s6,32(sp)
    80003254:	6be2                	ld	s7,24(sp)
    80003256:	6c42                	ld	s8,16(sp)
    80003258:	6ca2                	ld	s9,8(sp)
    8000325a:	6125                	addi	sp,sp,96
    8000325c:	8082                	ret

000000008000325e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000325e:	7179                	addi	sp,sp,-48
    80003260:	f406                	sd	ra,40(sp)
    80003262:	f022                	sd	s0,32(sp)
    80003264:	ec26                	sd	s1,24(sp)
    80003266:	e84a                	sd	s2,16(sp)
    80003268:	e44e                	sd	s3,8(sp)
    8000326a:	e052                	sd	s4,0(sp)
    8000326c:	1800                	addi	s0,sp,48
    8000326e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003270:	47ad                	li	a5,11
    80003272:	04b7fe63          	bgeu	a5,a1,800032ce <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003276:	ff45849b          	addiw	s1,a1,-12
    8000327a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000327e:	0ff00793          	li	a5,255
    80003282:	0ae7e463          	bltu	a5,a4,8000332a <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003286:	08052583          	lw	a1,128(a0)
    8000328a:	c5b5                	beqz	a1,800032f6 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000328c:	00092503          	lw	a0,0(s2)
    80003290:	00000097          	auipc	ra,0x0
    80003294:	be0080e7          	jalr	-1056(ra) # 80002e70 <bread>
    80003298:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000329a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000329e:	02049713          	slli	a4,s1,0x20
    800032a2:	01e75593          	srli	a1,a4,0x1e
    800032a6:	00b784b3          	add	s1,a5,a1
    800032aa:	0004a983          	lw	s3,0(s1)
    800032ae:	04098e63          	beqz	s3,8000330a <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032b2:	8552                	mv	a0,s4
    800032b4:	00000097          	auipc	ra,0x0
    800032b8:	cec080e7          	jalr	-788(ra) # 80002fa0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032bc:	854e                	mv	a0,s3
    800032be:	70a2                	ld	ra,40(sp)
    800032c0:	7402                	ld	s0,32(sp)
    800032c2:	64e2                	ld	s1,24(sp)
    800032c4:	6942                	ld	s2,16(sp)
    800032c6:	69a2                	ld	s3,8(sp)
    800032c8:	6a02                	ld	s4,0(sp)
    800032ca:	6145                	addi	sp,sp,48
    800032cc:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800032ce:	02059793          	slli	a5,a1,0x20
    800032d2:	01e7d593          	srli	a1,a5,0x1e
    800032d6:	00b504b3          	add	s1,a0,a1
    800032da:	0504a983          	lw	s3,80(s1)
    800032de:	fc099fe3          	bnez	s3,800032bc <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800032e2:	4108                	lw	a0,0(a0)
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	e4c080e7          	jalr	-436(ra) # 80003130 <balloc>
    800032ec:	0005099b          	sext.w	s3,a0
    800032f0:	0534a823          	sw	s3,80(s1)
    800032f4:	b7e1                	j	800032bc <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800032f6:	4108                	lw	a0,0(a0)
    800032f8:	00000097          	auipc	ra,0x0
    800032fc:	e38080e7          	jalr	-456(ra) # 80003130 <balloc>
    80003300:	0005059b          	sext.w	a1,a0
    80003304:	08b92023          	sw	a1,128(s2)
    80003308:	b751                	j	8000328c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000330a:	00092503          	lw	a0,0(s2)
    8000330e:	00000097          	auipc	ra,0x0
    80003312:	e22080e7          	jalr	-478(ra) # 80003130 <balloc>
    80003316:	0005099b          	sext.w	s3,a0
    8000331a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000331e:	8552                	mv	a0,s4
    80003320:	00001097          	auipc	ra,0x1
    80003324:	ed0080e7          	jalr	-304(ra) # 800041f0 <log_write>
    80003328:	b769                	j	800032b2 <bmap+0x54>
  panic("bmap: out of range");
    8000332a:	00005517          	auipc	a0,0x5
    8000332e:	20e50513          	addi	a0,a0,526 # 80008538 <syscalls+0x118>
    80003332:	ffffd097          	auipc	ra,0xffffd
    80003336:	216080e7          	jalr	534(ra) # 80000548 <panic>

000000008000333a <iget>:
{
    8000333a:	7179                	addi	sp,sp,-48
    8000333c:	f406                	sd	ra,40(sp)
    8000333e:	f022                	sd	s0,32(sp)
    80003340:	ec26                	sd	s1,24(sp)
    80003342:	e84a                	sd	s2,16(sp)
    80003344:	e44e                	sd	s3,8(sp)
    80003346:	e052                	sd	s4,0(sp)
    80003348:	1800                	addi	s0,sp,48
    8000334a:	89aa                	mv	s3,a0
    8000334c:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000334e:	0001c517          	auipc	a0,0x1c
    80003352:	45250513          	addi	a0,a0,1106 # 8001f7a0 <icache>
    80003356:	ffffe097          	auipc	ra,0xffffe
    8000335a:	990080e7          	jalr	-1648(ra) # 80000ce6 <acquire>
  empty = 0;
    8000335e:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003360:	0001c497          	auipc	s1,0x1c
    80003364:	45848493          	addi	s1,s1,1112 # 8001f7b8 <icache+0x18>
    80003368:	0001e697          	auipc	a3,0x1e
    8000336c:	ee068693          	addi	a3,a3,-288 # 80021248 <log>
    80003370:	a039                	j	8000337e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003372:	02090b63          	beqz	s2,800033a8 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003376:	08848493          	addi	s1,s1,136
    8000337a:	02d48a63          	beq	s1,a3,800033ae <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000337e:	449c                	lw	a5,8(s1)
    80003380:	fef059e3          	blez	a5,80003372 <iget+0x38>
    80003384:	4098                	lw	a4,0(s1)
    80003386:	ff3716e3          	bne	a4,s3,80003372 <iget+0x38>
    8000338a:	40d8                	lw	a4,4(s1)
    8000338c:	ff4713e3          	bne	a4,s4,80003372 <iget+0x38>
      ip->ref++;
    80003390:	2785                	addiw	a5,a5,1
    80003392:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003394:	0001c517          	auipc	a0,0x1c
    80003398:	40c50513          	addi	a0,a0,1036 # 8001f7a0 <icache>
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	9fe080e7          	jalr	-1538(ra) # 80000d9a <release>
      return ip;
    800033a4:	8926                	mv	s2,s1
    800033a6:	a03d                	j	800033d4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033a8:	f7f9                	bnez	a5,80003376 <iget+0x3c>
    800033aa:	8926                	mv	s2,s1
    800033ac:	b7e9                	j	80003376 <iget+0x3c>
  if(empty == 0)
    800033ae:	02090c63          	beqz	s2,800033e6 <iget+0xac>
  ip->dev = dev;
    800033b2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033b6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033ba:	4785                	li	a5,1
    800033bc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033c0:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800033c4:	0001c517          	auipc	a0,0x1c
    800033c8:	3dc50513          	addi	a0,a0,988 # 8001f7a0 <icache>
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	9ce080e7          	jalr	-1586(ra) # 80000d9a <release>
}
    800033d4:	854a                	mv	a0,s2
    800033d6:	70a2                	ld	ra,40(sp)
    800033d8:	7402                	ld	s0,32(sp)
    800033da:	64e2                	ld	s1,24(sp)
    800033dc:	6942                	ld	s2,16(sp)
    800033de:	69a2                	ld	s3,8(sp)
    800033e0:	6a02                	ld	s4,0(sp)
    800033e2:	6145                	addi	sp,sp,48
    800033e4:	8082                	ret
    panic("iget: no inodes");
    800033e6:	00005517          	auipc	a0,0x5
    800033ea:	16a50513          	addi	a0,a0,362 # 80008550 <syscalls+0x130>
    800033ee:	ffffd097          	auipc	ra,0xffffd
    800033f2:	15a080e7          	jalr	346(ra) # 80000548 <panic>

00000000800033f6 <fsinit>:
fsinit(int dev) {
    800033f6:	7179                	addi	sp,sp,-48
    800033f8:	f406                	sd	ra,40(sp)
    800033fa:	f022                	sd	s0,32(sp)
    800033fc:	ec26                	sd	s1,24(sp)
    800033fe:	e84a                	sd	s2,16(sp)
    80003400:	e44e                	sd	s3,8(sp)
    80003402:	1800                	addi	s0,sp,48
    80003404:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003406:	4585                	li	a1,1
    80003408:	00000097          	auipc	ra,0x0
    8000340c:	a68080e7          	jalr	-1432(ra) # 80002e70 <bread>
    80003410:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003412:	0001c997          	auipc	s3,0x1c
    80003416:	36e98993          	addi	s3,s3,878 # 8001f780 <sb>
    8000341a:	02000613          	li	a2,32
    8000341e:	05850593          	addi	a1,a0,88
    80003422:	854e                	mv	a0,s3
    80003424:	ffffe097          	auipc	ra,0xffffe
    80003428:	a1a080e7          	jalr	-1510(ra) # 80000e3e <memmove>
  brelse(bp);
    8000342c:	8526                	mv	a0,s1
    8000342e:	00000097          	auipc	ra,0x0
    80003432:	b72080e7          	jalr	-1166(ra) # 80002fa0 <brelse>
  if(sb.magic != FSMAGIC)
    80003436:	0009a703          	lw	a4,0(s3)
    8000343a:	102037b7          	lui	a5,0x10203
    8000343e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003442:	02f71263          	bne	a4,a5,80003466 <fsinit+0x70>
  initlog(dev, &sb);
    80003446:	0001c597          	auipc	a1,0x1c
    8000344a:	33a58593          	addi	a1,a1,826 # 8001f780 <sb>
    8000344e:	854a                	mv	a0,s2
    80003450:	00001097          	auipc	ra,0x1
    80003454:	b36080e7          	jalr	-1226(ra) # 80003f86 <initlog>
}
    80003458:	70a2                	ld	ra,40(sp)
    8000345a:	7402                	ld	s0,32(sp)
    8000345c:	64e2                	ld	s1,24(sp)
    8000345e:	6942                	ld	s2,16(sp)
    80003460:	69a2                	ld	s3,8(sp)
    80003462:	6145                	addi	sp,sp,48
    80003464:	8082                	ret
    panic("invalid file system");
    80003466:	00005517          	auipc	a0,0x5
    8000346a:	0fa50513          	addi	a0,a0,250 # 80008560 <syscalls+0x140>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	0da080e7          	jalr	218(ra) # 80000548 <panic>

0000000080003476 <iinit>:
{
    80003476:	7179                	addi	sp,sp,-48
    80003478:	f406                	sd	ra,40(sp)
    8000347a:	f022                	sd	s0,32(sp)
    8000347c:	ec26                	sd	s1,24(sp)
    8000347e:	e84a                	sd	s2,16(sp)
    80003480:	e44e                	sd	s3,8(sp)
    80003482:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003484:	00005597          	auipc	a1,0x5
    80003488:	0f458593          	addi	a1,a1,244 # 80008578 <syscalls+0x158>
    8000348c:	0001c517          	auipc	a0,0x1c
    80003490:	31450513          	addi	a0,a0,788 # 8001f7a0 <icache>
    80003494:	ffffd097          	auipc	ra,0xffffd
    80003498:	7c2080e7          	jalr	1986(ra) # 80000c56 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000349c:	0001c497          	auipc	s1,0x1c
    800034a0:	32c48493          	addi	s1,s1,812 # 8001f7c8 <icache+0x28>
    800034a4:	0001e997          	auipc	s3,0x1e
    800034a8:	db498993          	addi	s3,s3,-588 # 80021258 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800034ac:	00005917          	auipc	s2,0x5
    800034b0:	0d490913          	addi	s2,s2,212 # 80008580 <syscalls+0x160>
    800034b4:	85ca                	mv	a1,s2
    800034b6:	8526                	mv	a0,s1
    800034b8:	00001097          	auipc	ra,0x1
    800034bc:	e24080e7          	jalr	-476(ra) # 800042dc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034c0:	08848493          	addi	s1,s1,136
    800034c4:	ff3498e3          	bne	s1,s3,800034b4 <iinit+0x3e>
}
    800034c8:	70a2                	ld	ra,40(sp)
    800034ca:	7402                	ld	s0,32(sp)
    800034cc:	64e2                	ld	s1,24(sp)
    800034ce:	6942                	ld	s2,16(sp)
    800034d0:	69a2                	ld	s3,8(sp)
    800034d2:	6145                	addi	sp,sp,48
    800034d4:	8082                	ret

00000000800034d6 <ialloc>:
{
    800034d6:	7139                	addi	sp,sp,-64
    800034d8:	fc06                	sd	ra,56(sp)
    800034da:	f822                	sd	s0,48(sp)
    800034dc:	f426                	sd	s1,40(sp)
    800034de:	f04a                	sd	s2,32(sp)
    800034e0:	ec4e                	sd	s3,24(sp)
    800034e2:	e852                	sd	s4,16(sp)
    800034e4:	e456                	sd	s5,8(sp)
    800034e6:	e05a                	sd	s6,0(sp)
    800034e8:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800034ea:	0001c717          	auipc	a4,0x1c
    800034ee:	2a272703          	lw	a4,674(a4) # 8001f78c <sb+0xc>
    800034f2:	4785                	li	a5,1
    800034f4:	04e7f863          	bgeu	a5,a4,80003544 <ialloc+0x6e>
    800034f8:	8aaa                	mv	s5,a0
    800034fa:	8b2e                	mv	s6,a1
    800034fc:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034fe:	0001ca17          	auipc	s4,0x1c
    80003502:	282a0a13          	addi	s4,s4,642 # 8001f780 <sb>
    80003506:	00495593          	srli	a1,s2,0x4
    8000350a:	018a2783          	lw	a5,24(s4)
    8000350e:	9dbd                	addw	a1,a1,a5
    80003510:	8556                	mv	a0,s5
    80003512:	00000097          	auipc	ra,0x0
    80003516:	95e080e7          	jalr	-1698(ra) # 80002e70 <bread>
    8000351a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000351c:	05850993          	addi	s3,a0,88
    80003520:	00f97793          	andi	a5,s2,15
    80003524:	079a                	slli	a5,a5,0x6
    80003526:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003528:	00099783          	lh	a5,0(s3)
    8000352c:	c785                	beqz	a5,80003554 <ialloc+0x7e>
    brelse(bp);
    8000352e:	00000097          	auipc	ra,0x0
    80003532:	a72080e7          	jalr	-1422(ra) # 80002fa0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003536:	0905                	addi	s2,s2,1
    80003538:	00ca2703          	lw	a4,12(s4)
    8000353c:	0009079b          	sext.w	a5,s2
    80003540:	fce7e3e3          	bltu	a5,a4,80003506 <ialloc+0x30>
  panic("ialloc: no inodes");
    80003544:	00005517          	auipc	a0,0x5
    80003548:	04450513          	addi	a0,a0,68 # 80008588 <syscalls+0x168>
    8000354c:	ffffd097          	auipc	ra,0xffffd
    80003550:	ffc080e7          	jalr	-4(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    80003554:	04000613          	li	a2,64
    80003558:	4581                	li	a1,0
    8000355a:	854e                	mv	a0,s3
    8000355c:	ffffe097          	auipc	ra,0xffffe
    80003560:	886080e7          	jalr	-1914(ra) # 80000de2 <memset>
      dip->type = type;
    80003564:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003568:	8526                	mv	a0,s1
    8000356a:	00001097          	auipc	ra,0x1
    8000356e:	c86080e7          	jalr	-890(ra) # 800041f0 <log_write>
      brelse(bp);
    80003572:	8526                	mv	a0,s1
    80003574:	00000097          	auipc	ra,0x0
    80003578:	a2c080e7          	jalr	-1492(ra) # 80002fa0 <brelse>
      return iget(dev, inum);
    8000357c:	0009059b          	sext.w	a1,s2
    80003580:	8556                	mv	a0,s5
    80003582:	00000097          	auipc	ra,0x0
    80003586:	db8080e7          	jalr	-584(ra) # 8000333a <iget>
}
    8000358a:	70e2                	ld	ra,56(sp)
    8000358c:	7442                	ld	s0,48(sp)
    8000358e:	74a2                	ld	s1,40(sp)
    80003590:	7902                	ld	s2,32(sp)
    80003592:	69e2                	ld	s3,24(sp)
    80003594:	6a42                	ld	s4,16(sp)
    80003596:	6aa2                	ld	s5,8(sp)
    80003598:	6b02                	ld	s6,0(sp)
    8000359a:	6121                	addi	sp,sp,64
    8000359c:	8082                	ret

000000008000359e <iupdate>:
{
    8000359e:	1101                	addi	sp,sp,-32
    800035a0:	ec06                	sd	ra,24(sp)
    800035a2:	e822                	sd	s0,16(sp)
    800035a4:	e426                	sd	s1,8(sp)
    800035a6:	e04a                	sd	s2,0(sp)
    800035a8:	1000                	addi	s0,sp,32
    800035aa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035ac:	415c                	lw	a5,4(a0)
    800035ae:	0047d79b          	srliw	a5,a5,0x4
    800035b2:	0001c597          	auipc	a1,0x1c
    800035b6:	1e65a583          	lw	a1,486(a1) # 8001f798 <sb+0x18>
    800035ba:	9dbd                	addw	a1,a1,a5
    800035bc:	4108                	lw	a0,0(a0)
    800035be:	00000097          	auipc	ra,0x0
    800035c2:	8b2080e7          	jalr	-1870(ra) # 80002e70 <bread>
    800035c6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035c8:	05850793          	addi	a5,a0,88
    800035cc:	40d8                	lw	a4,4(s1)
    800035ce:	8b3d                	andi	a4,a4,15
    800035d0:	071a                	slli	a4,a4,0x6
    800035d2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035d4:	04449703          	lh	a4,68(s1)
    800035d8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035dc:	04649703          	lh	a4,70(s1)
    800035e0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800035e4:	04849703          	lh	a4,72(s1)
    800035e8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800035ec:	04a49703          	lh	a4,74(s1)
    800035f0:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800035f4:	44f8                	lw	a4,76(s1)
    800035f6:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035f8:	03400613          	li	a2,52
    800035fc:	05048593          	addi	a1,s1,80
    80003600:	00c78513          	addi	a0,a5,12
    80003604:	ffffe097          	auipc	ra,0xffffe
    80003608:	83a080e7          	jalr	-1990(ra) # 80000e3e <memmove>
  log_write(bp);
    8000360c:	854a                	mv	a0,s2
    8000360e:	00001097          	auipc	ra,0x1
    80003612:	be2080e7          	jalr	-1054(ra) # 800041f0 <log_write>
  brelse(bp);
    80003616:	854a                	mv	a0,s2
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	988080e7          	jalr	-1656(ra) # 80002fa0 <brelse>
}
    80003620:	60e2                	ld	ra,24(sp)
    80003622:	6442                	ld	s0,16(sp)
    80003624:	64a2                	ld	s1,8(sp)
    80003626:	6902                	ld	s2,0(sp)
    80003628:	6105                	addi	sp,sp,32
    8000362a:	8082                	ret

000000008000362c <idup>:
{
    8000362c:	1101                	addi	sp,sp,-32
    8000362e:	ec06                	sd	ra,24(sp)
    80003630:	e822                	sd	s0,16(sp)
    80003632:	e426                	sd	s1,8(sp)
    80003634:	1000                	addi	s0,sp,32
    80003636:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003638:	0001c517          	auipc	a0,0x1c
    8000363c:	16850513          	addi	a0,a0,360 # 8001f7a0 <icache>
    80003640:	ffffd097          	auipc	ra,0xffffd
    80003644:	6a6080e7          	jalr	1702(ra) # 80000ce6 <acquire>
  ip->ref++;
    80003648:	449c                	lw	a5,8(s1)
    8000364a:	2785                	addiw	a5,a5,1
    8000364c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000364e:	0001c517          	auipc	a0,0x1c
    80003652:	15250513          	addi	a0,a0,338 # 8001f7a0 <icache>
    80003656:	ffffd097          	auipc	ra,0xffffd
    8000365a:	744080e7          	jalr	1860(ra) # 80000d9a <release>
}
    8000365e:	8526                	mv	a0,s1
    80003660:	60e2                	ld	ra,24(sp)
    80003662:	6442                	ld	s0,16(sp)
    80003664:	64a2                	ld	s1,8(sp)
    80003666:	6105                	addi	sp,sp,32
    80003668:	8082                	ret

000000008000366a <ilock>:
{
    8000366a:	1101                	addi	sp,sp,-32
    8000366c:	ec06                	sd	ra,24(sp)
    8000366e:	e822                	sd	s0,16(sp)
    80003670:	e426                	sd	s1,8(sp)
    80003672:	e04a                	sd	s2,0(sp)
    80003674:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003676:	c115                	beqz	a0,8000369a <ilock+0x30>
    80003678:	84aa                	mv	s1,a0
    8000367a:	451c                	lw	a5,8(a0)
    8000367c:	00f05f63          	blez	a5,8000369a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003680:	0541                	addi	a0,a0,16
    80003682:	00001097          	auipc	ra,0x1
    80003686:	c94080e7          	jalr	-876(ra) # 80004316 <acquiresleep>
  if(ip->valid == 0){
    8000368a:	40bc                	lw	a5,64(s1)
    8000368c:	cf99                	beqz	a5,800036aa <ilock+0x40>
}
    8000368e:	60e2                	ld	ra,24(sp)
    80003690:	6442                	ld	s0,16(sp)
    80003692:	64a2                	ld	s1,8(sp)
    80003694:	6902                	ld	s2,0(sp)
    80003696:	6105                	addi	sp,sp,32
    80003698:	8082                	ret
    panic("ilock");
    8000369a:	00005517          	auipc	a0,0x5
    8000369e:	f0650513          	addi	a0,a0,-250 # 800085a0 <syscalls+0x180>
    800036a2:	ffffd097          	auipc	ra,0xffffd
    800036a6:	ea6080e7          	jalr	-346(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036aa:	40dc                	lw	a5,4(s1)
    800036ac:	0047d79b          	srliw	a5,a5,0x4
    800036b0:	0001c597          	auipc	a1,0x1c
    800036b4:	0e85a583          	lw	a1,232(a1) # 8001f798 <sb+0x18>
    800036b8:	9dbd                	addw	a1,a1,a5
    800036ba:	4088                	lw	a0,0(s1)
    800036bc:	fffff097          	auipc	ra,0xfffff
    800036c0:	7b4080e7          	jalr	1972(ra) # 80002e70 <bread>
    800036c4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036c6:	05850593          	addi	a1,a0,88
    800036ca:	40dc                	lw	a5,4(s1)
    800036cc:	8bbd                	andi	a5,a5,15
    800036ce:	079a                	slli	a5,a5,0x6
    800036d0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036d2:	00059783          	lh	a5,0(a1)
    800036d6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036da:	00259783          	lh	a5,2(a1)
    800036de:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036e2:	00459783          	lh	a5,4(a1)
    800036e6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036ea:	00659783          	lh	a5,6(a1)
    800036ee:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036f2:	459c                	lw	a5,8(a1)
    800036f4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036f6:	03400613          	li	a2,52
    800036fa:	05b1                	addi	a1,a1,12
    800036fc:	05048513          	addi	a0,s1,80
    80003700:	ffffd097          	auipc	ra,0xffffd
    80003704:	73e080e7          	jalr	1854(ra) # 80000e3e <memmove>
    brelse(bp);
    80003708:	854a                	mv	a0,s2
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	896080e7          	jalr	-1898(ra) # 80002fa0 <brelse>
    ip->valid = 1;
    80003712:	4785                	li	a5,1
    80003714:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003716:	04449783          	lh	a5,68(s1)
    8000371a:	fbb5                	bnez	a5,8000368e <ilock+0x24>
      panic("ilock: no type");
    8000371c:	00005517          	auipc	a0,0x5
    80003720:	e8c50513          	addi	a0,a0,-372 # 800085a8 <syscalls+0x188>
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	e24080e7          	jalr	-476(ra) # 80000548 <panic>

000000008000372c <iunlock>:
{
    8000372c:	1101                	addi	sp,sp,-32
    8000372e:	ec06                	sd	ra,24(sp)
    80003730:	e822                	sd	s0,16(sp)
    80003732:	e426                	sd	s1,8(sp)
    80003734:	e04a                	sd	s2,0(sp)
    80003736:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003738:	c905                	beqz	a0,80003768 <iunlock+0x3c>
    8000373a:	84aa                	mv	s1,a0
    8000373c:	01050913          	addi	s2,a0,16
    80003740:	854a                	mv	a0,s2
    80003742:	00001097          	auipc	ra,0x1
    80003746:	c6e080e7          	jalr	-914(ra) # 800043b0 <holdingsleep>
    8000374a:	cd19                	beqz	a0,80003768 <iunlock+0x3c>
    8000374c:	449c                	lw	a5,8(s1)
    8000374e:	00f05d63          	blez	a5,80003768 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003752:	854a                	mv	a0,s2
    80003754:	00001097          	auipc	ra,0x1
    80003758:	c18080e7          	jalr	-1000(ra) # 8000436c <releasesleep>
}
    8000375c:	60e2                	ld	ra,24(sp)
    8000375e:	6442                	ld	s0,16(sp)
    80003760:	64a2                	ld	s1,8(sp)
    80003762:	6902                	ld	s2,0(sp)
    80003764:	6105                	addi	sp,sp,32
    80003766:	8082                	ret
    panic("iunlock");
    80003768:	00005517          	auipc	a0,0x5
    8000376c:	e5050513          	addi	a0,a0,-432 # 800085b8 <syscalls+0x198>
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	dd8080e7          	jalr	-552(ra) # 80000548 <panic>

0000000080003778 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003778:	7179                	addi	sp,sp,-48
    8000377a:	f406                	sd	ra,40(sp)
    8000377c:	f022                	sd	s0,32(sp)
    8000377e:	ec26                	sd	s1,24(sp)
    80003780:	e84a                	sd	s2,16(sp)
    80003782:	e44e                	sd	s3,8(sp)
    80003784:	e052                	sd	s4,0(sp)
    80003786:	1800                	addi	s0,sp,48
    80003788:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000378a:	05050493          	addi	s1,a0,80
    8000378e:	08050913          	addi	s2,a0,128
    80003792:	a021                	j	8000379a <itrunc+0x22>
    80003794:	0491                	addi	s1,s1,4
    80003796:	01248d63          	beq	s1,s2,800037b0 <itrunc+0x38>
    if(ip->addrs[i]){
    8000379a:	408c                	lw	a1,0(s1)
    8000379c:	dde5                	beqz	a1,80003794 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000379e:	0009a503          	lw	a0,0(s3)
    800037a2:	00000097          	auipc	ra,0x0
    800037a6:	912080e7          	jalr	-1774(ra) # 800030b4 <bfree>
      ip->addrs[i] = 0;
    800037aa:	0004a023          	sw	zero,0(s1)
    800037ae:	b7dd                	j	80003794 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037b0:	0809a583          	lw	a1,128(s3)
    800037b4:	e185                	bnez	a1,800037d4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037b6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037ba:	854e                	mv	a0,s3
    800037bc:	00000097          	auipc	ra,0x0
    800037c0:	de2080e7          	jalr	-542(ra) # 8000359e <iupdate>
}
    800037c4:	70a2                	ld	ra,40(sp)
    800037c6:	7402                	ld	s0,32(sp)
    800037c8:	64e2                	ld	s1,24(sp)
    800037ca:	6942                	ld	s2,16(sp)
    800037cc:	69a2                	ld	s3,8(sp)
    800037ce:	6a02                	ld	s4,0(sp)
    800037d0:	6145                	addi	sp,sp,48
    800037d2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037d4:	0009a503          	lw	a0,0(s3)
    800037d8:	fffff097          	auipc	ra,0xfffff
    800037dc:	698080e7          	jalr	1688(ra) # 80002e70 <bread>
    800037e0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037e2:	05850493          	addi	s1,a0,88
    800037e6:	45850913          	addi	s2,a0,1112
    800037ea:	a021                	j	800037f2 <itrunc+0x7a>
    800037ec:	0491                	addi	s1,s1,4
    800037ee:	01248b63          	beq	s1,s2,80003804 <itrunc+0x8c>
      if(a[j])
    800037f2:	408c                	lw	a1,0(s1)
    800037f4:	dde5                	beqz	a1,800037ec <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800037f6:	0009a503          	lw	a0,0(s3)
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	8ba080e7          	jalr	-1862(ra) # 800030b4 <bfree>
    80003802:	b7ed                	j	800037ec <itrunc+0x74>
    brelse(bp);
    80003804:	8552                	mv	a0,s4
    80003806:	fffff097          	auipc	ra,0xfffff
    8000380a:	79a080e7          	jalr	1946(ra) # 80002fa0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000380e:	0809a583          	lw	a1,128(s3)
    80003812:	0009a503          	lw	a0,0(s3)
    80003816:	00000097          	auipc	ra,0x0
    8000381a:	89e080e7          	jalr	-1890(ra) # 800030b4 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000381e:	0809a023          	sw	zero,128(s3)
    80003822:	bf51                	j	800037b6 <itrunc+0x3e>

0000000080003824 <iput>:
{
    80003824:	1101                	addi	sp,sp,-32
    80003826:	ec06                	sd	ra,24(sp)
    80003828:	e822                	sd	s0,16(sp)
    8000382a:	e426                	sd	s1,8(sp)
    8000382c:	e04a                	sd	s2,0(sp)
    8000382e:	1000                	addi	s0,sp,32
    80003830:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003832:	0001c517          	auipc	a0,0x1c
    80003836:	f6e50513          	addi	a0,a0,-146 # 8001f7a0 <icache>
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	4ac080e7          	jalr	1196(ra) # 80000ce6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003842:	4498                	lw	a4,8(s1)
    80003844:	4785                	li	a5,1
    80003846:	02f70363          	beq	a4,a5,8000386c <iput+0x48>
  ip->ref--;
    8000384a:	449c                	lw	a5,8(s1)
    8000384c:	37fd                	addiw	a5,a5,-1
    8000384e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003850:	0001c517          	auipc	a0,0x1c
    80003854:	f5050513          	addi	a0,a0,-176 # 8001f7a0 <icache>
    80003858:	ffffd097          	auipc	ra,0xffffd
    8000385c:	542080e7          	jalr	1346(ra) # 80000d9a <release>
}
    80003860:	60e2                	ld	ra,24(sp)
    80003862:	6442                	ld	s0,16(sp)
    80003864:	64a2                	ld	s1,8(sp)
    80003866:	6902                	ld	s2,0(sp)
    80003868:	6105                	addi	sp,sp,32
    8000386a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000386c:	40bc                	lw	a5,64(s1)
    8000386e:	dff1                	beqz	a5,8000384a <iput+0x26>
    80003870:	04a49783          	lh	a5,74(s1)
    80003874:	fbf9                	bnez	a5,8000384a <iput+0x26>
    acquiresleep(&ip->lock);
    80003876:	01048913          	addi	s2,s1,16
    8000387a:	854a                	mv	a0,s2
    8000387c:	00001097          	auipc	ra,0x1
    80003880:	a9a080e7          	jalr	-1382(ra) # 80004316 <acquiresleep>
    release(&icache.lock);
    80003884:	0001c517          	auipc	a0,0x1c
    80003888:	f1c50513          	addi	a0,a0,-228 # 8001f7a0 <icache>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	50e080e7          	jalr	1294(ra) # 80000d9a <release>
    itrunc(ip);
    80003894:	8526                	mv	a0,s1
    80003896:	00000097          	auipc	ra,0x0
    8000389a:	ee2080e7          	jalr	-286(ra) # 80003778 <itrunc>
    ip->type = 0;
    8000389e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038a2:	8526                	mv	a0,s1
    800038a4:	00000097          	auipc	ra,0x0
    800038a8:	cfa080e7          	jalr	-774(ra) # 8000359e <iupdate>
    ip->valid = 0;
    800038ac:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038b0:	854a                	mv	a0,s2
    800038b2:	00001097          	auipc	ra,0x1
    800038b6:	aba080e7          	jalr	-1350(ra) # 8000436c <releasesleep>
    acquire(&icache.lock);
    800038ba:	0001c517          	auipc	a0,0x1c
    800038be:	ee650513          	addi	a0,a0,-282 # 8001f7a0 <icache>
    800038c2:	ffffd097          	auipc	ra,0xffffd
    800038c6:	424080e7          	jalr	1060(ra) # 80000ce6 <acquire>
    800038ca:	b741                	j	8000384a <iput+0x26>

00000000800038cc <iunlockput>:
{
    800038cc:	1101                	addi	sp,sp,-32
    800038ce:	ec06                	sd	ra,24(sp)
    800038d0:	e822                	sd	s0,16(sp)
    800038d2:	e426                	sd	s1,8(sp)
    800038d4:	1000                	addi	s0,sp,32
    800038d6:	84aa                	mv	s1,a0
  iunlock(ip);
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	e54080e7          	jalr	-428(ra) # 8000372c <iunlock>
  iput(ip);
    800038e0:	8526                	mv	a0,s1
    800038e2:	00000097          	auipc	ra,0x0
    800038e6:	f42080e7          	jalr	-190(ra) # 80003824 <iput>
}
    800038ea:	60e2                	ld	ra,24(sp)
    800038ec:	6442                	ld	s0,16(sp)
    800038ee:	64a2                	ld	s1,8(sp)
    800038f0:	6105                	addi	sp,sp,32
    800038f2:	8082                	ret

00000000800038f4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038f4:	1141                	addi	sp,sp,-16
    800038f6:	e422                	sd	s0,8(sp)
    800038f8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038fa:	411c                	lw	a5,0(a0)
    800038fc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038fe:	415c                	lw	a5,4(a0)
    80003900:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003902:	04451783          	lh	a5,68(a0)
    80003906:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000390a:	04a51783          	lh	a5,74(a0)
    8000390e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003912:	04c56783          	lwu	a5,76(a0)
    80003916:	e99c                	sd	a5,16(a1)
}
    80003918:	6422                	ld	s0,8(sp)
    8000391a:	0141                	addi	sp,sp,16
    8000391c:	8082                	ret

000000008000391e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000391e:	457c                	lw	a5,76(a0)
    80003920:	0ed7e963          	bltu	a5,a3,80003a12 <readi+0xf4>
{
    80003924:	7159                	addi	sp,sp,-112
    80003926:	f486                	sd	ra,104(sp)
    80003928:	f0a2                	sd	s0,96(sp)
    8000392a:	eca6                	sd	s1,88(sp)
    8000392c:	e8ca                	sd	s2,80(sp)
    8000392e:	e4ce                	sd	s3,72(sp)
    80003930:	e0d2                	sd	s4,64(sp)
    80003932:	fc56                	sd	s5,56(sp)
    80003934:	f85a                	sd	s6,48(sp)
    80003936:	f45e                	sd	s7,40(sp)
    80003938:	f062                	sd	s8,32(sp)
    8000393a:	ec66                	sd	s9,24(sp)
    8000393c:	e86a                	sd	s10,16(sp)
    8000393e:	e46e                	sd	s11,8(sp)
    80003940:	1880                	addi	s0,sp,112
    80003942:	8baa                	mv	s7,a0
    80003944:	8c2e                	mv	s8,a1
    80003946:	8ab2                	mv	s5,a2
    80003948:	84b6                	mv	s1,a3
    8000394a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000394c:	9f35                	addw	a4,a4,a3
    return 0;
    8000394e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003950:	0ad76063          	bltu	a4,a3,800039f0 <readi+0xd2>
  if(off + n > ip->size)
    80003954:	00e7f463          	bgeu	a5,a4,8000395c <readi+0x3e>
    n = ip->size - off;
    80003958:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000395c:	0a0b0963          	beqz	s6,80003a0e <readi+0xf0>
    80003960:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003962:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003966:	5cfd                	li	s9,-1
    80003968:	a82d                	j	800039a2 <readi+0x84>
    8000396a:	020a1d93          	slli	s11,s4,0x20
    8000396e:	020ddd93          	srli	s11,s11,0x20
    80003972:	05890613          	addi	a2,s2,88
    80003976:	86ee                	mv	a3,s11
    80003978:	963a                	add	a2,a2,a4
    8000397a:	85d6                	mv	a1,s5
    8000397c:	8562                	mv	a0,s8
    8000397e:	fffff097          	auipc	ra,0xfffff
    80003982:	b30080e7          	jalr	-1232(ra) # 800024ae <either_copyout>
    80003986:	05950d63          	beq	a0,s9,800039e0 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000398a:	854a                	mv	a0,s2
    8000398c:	fffff097          	auipc	ra,0xfffff
    80003990:	614080e7          	jalr	1556(ra) # 80002fa0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003994:	013a09bb          	addw	s3,s4,s3
    80003998:	009a04bb          	addw	s1,s4,s1
    8000399c:	9aee                	add	s5,s5,s11
    8000399e:	0569f763          	bgeu	s3,s6,800039ec <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039a2:	000ba903          	lw	s2,0(s7)
    800039a6:	00a4d59b          	srliw	a1,s1,0xa
    800039aa:	855e                	mv	a0,s7
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	8b2080e7          	jalr	-1870(ra) # 8000325e <bmap>
    800039b4:	0005059b          	sext.w	a1,a0
    800039b8:	854a                	mv	a0,s2
    800039ba:	fffff097          	auipc	ra,0xfffff
    800039be:	4b6080e7          	jalr	1206(ra) # 80002e70 <bread>
    800039c2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039c4:	3ff4f713          	andi	a4,s1,1023
    800039c8:	40ed07bb          	subw	a5,s10,a4
    800039cc:	413b06bb          	subw	a3,s6,s3
    800039d0:	8a3e                	mv	s4,a5
    800039d2:	2781                	sext.w	a5,a5
    800039d4:	0006861b          	sext.w	a2,a3
    800039d8:	f8f679e3          	bgeu	a2,a5,8000396a <readi+0x4c>
    800039dc:	8a36                	mv	s4,a3
    800039de:	b771                	j	8000396a <readi+0x4c>
      brelse(bp);
    800039e0:	854a                	mv	a0,s2
    800039e2:	fffff097          	auipc	ra,0xfffff
    800039e6:	5be080e7          	jalr	1470(ra) # 80002fa0 <brelse>
      tot = -1;
    800039ea:	59fd                	li	s3,-1
  }
  return tot;
    800039ec:	0009851b          	sext.w	a0,s3
}
    800039f0:	70a6                	ld	ra,104(sp)
    800039f2:	7406                	ld	s0,96(sp)
    800039f4:	64e6                	ld	s1,88(sp)
    800039f6:	6946                	ld	s2,80(sp)
    800039f8:	69a6                	ld	s3,72(sp)
    800039fa:	6a06                	ld	s4,64(sp)
    800039fc:	7ae2                	ld	s5,56(sp)
    800039fe:	7b42                	ld	s6,48(sp)
    80003a00:	7ba2                	ld	s7,40(sp)
    80003a02:	7c02                	ld	s8,32(sp)
    80003a04:	6ce2                	ld	s9,24(sp)
    80003a06:	6d42                	ld	s10,16(sp)
    80003a08:	6da2                	ld	s11,8(sp)
    80003a0a:	6165                	addi	sp,sp,112
    80003a0c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a0e:	89da                	mv	s3,s6
    80003a10:	bff1                	j	800039ec <readi+0xce>
    return 0;
    80003a12:	4501                	li	a0,0
}
    80003a14:	8082                	ret

0000000080003a16 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a16:	457c                	lw	a5,76(a0)
    80003a18:	10d7e763          	bltu	a5,a3,80003b26 <writei+0x110>
{
    80003a1c:	7159                	addi	sp,sp,-112
    80003a1e:	f486                	sd	ra,104(sp)
    80003a20:	f0a2                	sd	s0,96(sp)
    80003a22:	eca6                	sd	s1,88(sp)
    80003a24:	e8ca                	sd	s2,80(sp)
    80003a26:	e4ce                	sd	s3,72(sp)
    80003a28:	e0d2                	sd	s4,64(sp)
    80003a2a:	fc56                	sd	s5,56(sp)
    80003a2c:	f85a                	sd	s6,48(sp)
    80003a2e:	f45e                	sd	s7,40(sp)
    80003a30:	f062                	sd	s8,32(sp)
    80003a32:	ec66                	sd	s9,24(sp)
    80003a34:	e86a                	sd	s10,16(sp)
    80003a36:	e46e                	sd	s11,8(sp)
    80003a38:	1880                	addi	s0,sp,112
    80003a3a:	8baa                	mv	s7,a0
    80003a3c:	8c2e                	mv	s8,a1
    80003a3e:	8ab2                	mv	s5,a2
    80003a40:	8936                	mv	s2,a3
    80003a42:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a44:	00e687bb          	addw	a5,a3,a4
    80003a48:	0ed7e163          	bltu	a5,a3,80003b2a <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a4c:	00043737          	lui	a4,0x43
    80003a50:	0cf76f63          	bltu	a4,a5,80003b2e <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a54:	0a0b0863          	beqz	s6,80003b04 <writei+0xee>
    80003a58:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a5a:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a5e:	5cfd                	li	s9,-1
    80003a60:	a091                	j	80003aa4 <writei+0x8e>
    80003a62:	02099d93          	slli	s11,s3,0x20
    80003a66:	020ddd93          	srli	s11,s11,0x20
    80003a6a:	05848513          	addi	a0,s1,88
    80003a6e:	86ee                	mv	a3,s11
    80003a70:	8656                	mv	a2,s5
    80003a72:	85e2                	mv	a1,s8
    80003a74:	953a                	add	a0,a0,a4
    80003a76:	fffff097          	auipc	ra,0xfffff
    80003a7a:	a8e080e7          	jalr	-1394(ra) # 80002504 <either_copyin>
    80003a7e:	07950263          	beq	a0,s9,80003ae2 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003a82:	8526                	mv	a0,s1
    80003a84:	00000097          	auipc	ra,0x0
    80003a88:	76c080e7          	jalr	1900(ra) # 800041f0 <log_write>
    brelse(bp);
    80003a8c:	8526                	mv	a0,s1
    80003a8e:	fffff097          	auipc	ra,0xfffff
    80003a92:	512080e7          	jalr	1298(ra) # 80002fa0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a96:	01498a3b          	addw	s4,s3,s4
    80003a9a:	0129893b          	addw	s2,s3,s2
    80003a9e:	9aee                	add	s5,s5,s11
    80003aa0:	056a7763          	bgeu	s4,s6,80003aee <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003aa4:	000ba483          	lw	s1,0(s7)
    80003aa8:	00a9559b          	srliw	a1,s2,0xa
    80003aac:	855e                	mv	a0,s7
    80003aae:	fffff097          	auipc	ra,0xfffff
    80003ab2:	7b0080e7          	jalr	1968(ra) # 8000325e <bmap>
    80003ab6:	0005059b          	sext.w	a1,a0
    80003aba:	8526                	mv	a0,s1
    80003abc:	fffff097          	auipc	ra,0xfffff
    80003ac0:	3b4080e7          	jalr	948(ra) # 80002e70 <bread>
    80003ac4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ac6:	3ff97713          	andi	a4,s2,1023
    80003aca:	40ed07bb          	subw	a5,s10,a4
    80003ace:	414b06bb          	subw	a3,s6,s4
    80003ad2:	89be                	mv	s3,a5
    80003ad4:	2781                	sext.w	a5,a5
    80003ad6:	0006861b          	sext.w	a2,a3
    80003ada:	f8f674e3          	bgeu	a2,a5,80003a62 <writei+0x4c>
    80003ade:	89b6                	mv	s3,a3
    80003ae0:	b749                	j	80003a62 <writei+0x4c>
      brelse(bp);
    80003ae2:	8526                	mv	a0,s1
    80003ae4:	fffff097          	auipc	ra,0xfffff
    80003ae8:	4bc080e7          	jalr	1212(ra) # 80002fa0 <brelse>
      n = -1;
    80003aec:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003aee:	04cba783          	lw	a5,76(s7)
    80003af2:	0127f463          	bgeu	a5,s2,80003afa <writei+0xe4>
      ip->size = off;
    80003af6:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003afa:	855e                	mv	a0,s7
    80003afc:	00000097          	auipc	ra,0x0
    80003b00:	aa2080e7          	jalr	-1374(ra) # 8000359e <iupdate>
  }

  return n;
    80003b04:	000b051b          	sext.w	a0,s6
}
    80003b08:	70a6                	ld	ra,104(sp)
    80003b0a:	7406                	ld	s0,96(sp)
    80003b0c:	64e6                	ld	s1,88(sp)
    80003b0e:	6946                	ld	s2,80(sp)
    80003b10:	69a6                	ld	s3,72(sp)
    80003b12:	6a06                	ld	s4,64(sp)
    80003b14:	7ae2                	ld	s5,56(sp)
    80003b16:	7b42                	ld	s6,48(sp)
    80003b18:	7ba2                	ld	s7,40(sp)
    80003b1a:	7c02                	ld	s8,32(sp)
    80003b1c:	6ce2                	ld	s9,24(sp)
    80003b1e:	6d42                	ld	s10,16(sp)
    80003b20:	6da2                	ld	s11,8(sp)
    80003b22:	6165                	addi	sp,sp,112
    80003b24:	8082                	ret
    return -1;
    80003b26:	557d                	li	a0,-1
}
    80003b28:	8082                	ret
    return -1;
    80003b2a:	557d                	li	a0,-1
    80003b2c:	bff1                	j	80003b08 <writei+0xf2>
    return -1;
    80003b2e:	557d                	li	a0,-1
    80003b30:	bfe1                	j	80003b08 <writei+0xf2>

0000000080003b32 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b32:	1141                	addi	sp,sp,-16
    80003b34:	e406                	sd	ra,8(sp)
    80003b36:	e022                	sd	s0,0(sp)
    80003b38:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b3a:	4639                	li	a2,14
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	37e080e7          	jalr	894(ra) # 80000eba <strncmp>
}
    80003b44:	60a2                	ld	ra,8(sp)
    80003b46:	6402                	ld	s0,0(sp)
    80003b48:	0141                	addi	sp,sp,16
    80003b4a:	8082                	ret

0000000080003b4c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b4c:	7139                	addi	sp,sp,-64
    80003b4e:	fc06                	sd	ra,56(sp)
    80003b50:	f822                	sd	s0,48(sp)
    80003b52:	f426                	sd	s1,40(sp)
    80003b54:	f04a                	sd	s2,32(sp)
    80003b56:	ec4e                	sd	s3,24(sp)
    80003b58:	e852                	sd	s4,16(sp)
    80003b5a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b5c:	04451703          	lh	a4,68(a0)
    80003b60:	4785                	li	a5,1
    80003b62:	00f71a63          	bne	a4,a5,80003b76 <dirlookup+0x2a>
    80003b66:	892a                	mv	s2,a0
    80003b68:	89ae                	mv	s3,a1
    80003b6a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6c:	457c                	lw	a5,76(a0)
    80003b6e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b70:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b72:	e79d                	bnez	a5,80003ba0 <dirlookup+0x54>
    80003b74:	a8a5                	j	80003bec <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b76:	00005517          	auipc	a0,0x5
    80003b7a:	a4a50513          	addi	a0,a0,-1462 # 800085c0 <syscalls+0x1a0>
    80003b7e:	ffffd097          	auipc	ra,0xffffd
    80003b82:	9ca080e7          	jalr	-1590(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003b86:	00005517          	auipc	a0,0x5
    80003b8a:	a5250513          	addi	a0,a0,-1454 # 800085d8 <syscalls+0x1b8>
    80003b8e:	ffffd097          	auipc	ra,0xffffd
    80003b92:	9ba080e7          	jalr	-1606(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b96:	24c1                	addiw	s1,s1,16
    80003b98:	04c92783          	lw	a5,76(s2)
    80003b9c:	04f4f763          	bgeu	s1,a5,80003bea <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ba0:	4741                	li	a4,16
    80003ba2:	86a6                	mv	a3,s1
    80003ba4:	fc040613          	addi	a2,s0,-64
    80003ba8:	4581                	li	a1,0
    80003baa:	854a                	mv	a0,s2
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	d72080e7          	jalr	-654(ra) # 8000391e <readi>
    80003bb4:	47c1                	li	a5,16
    80003bb6:	fcf518e3          	bne	a0,a5,80003b86 <dirlookup+0x3a>
    if(de.inum == 0)
    80003bba:	fc045783          	lhu	a5,-64(s0)
    80003bbe:	dfe1                	beqz	a5,80003b96 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bc0:	fc240593          	addi	a1,s0,-62
    80003bc4:	854e                	mv	a0,s3
    80003bc6:	00000097          	auipc	ra,0x0
    80003bca:	f6c080e7          	jalr	-148(ra) # 80003b32 <namecmp>
    80003bce:	f561                	bnez	a0,80003b96 <dirlookup+0x4a>
      if(poff)
    80003bd0:	000a0463          	beqz	s4,80003bd8 <dirlookup+0x8c>
        *poff = off;
    80003bd4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bd8:	fc045583          	lhu	a1,-64(s0)
    80003bdc:	00092503          	lw	a0,0(s2)
    80003be0:	fffff097          	auipc	ra,0xfffff
    80003be4:	75a080e7          	jalr	1882(ra) # 8000333a <iget>
    80003be8:	a011                	j	80003bec <dirlookup+0xa0>
  return 0;
    80003bea:	4501                	li	a0,0
}
    80003bec:	70e2                	ld	ra,56(sp)
    80003bee:	7442                	ld	s0,48(sp)
    80003bf0:	74a2                	ld	s1,40(sp)
    80003bf2:	7902                	ld	s2,32(sp)
    80003bf4:	69e2                	ld	s3,24(sp)
    80003bf6:	6a42                	ld	s4,16(sp)
    80003bf8:	6121                	addi	sp,sp,64
    80003bfa:	8082                	ret

0000000080003bfc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bfc:	711d                	addi	sp,sp,-96
    80003bfe:	ec86                	sd	ra,88(sp)
    80003c00:	e8a2                	sd	s0,80(sp)
    80003c02:	e4a6                	sd	s1,72(sp)
    80003c04:	e0ca                	sd	s2,64(sp)
    80003c06:	fc4e                	sd	s3,56(sp)
    80003c08:	f852                	sd	s4,48(sp)
    80003c0a:	f456                	sd	s5,40(sp)
    80003c0c:	f05a                	sd	s6,32(sp)
    80003c0e:	ec5e                	sd	s7,24(sp)
    80003c10:	e862                	sd	s8,16(sp)
    80003c12:	e466                	sd	s9,8(sp)
    80003c14:	1080                	addi	s0,sp,96
    80003c16:	84aa                	mv	s1,a0
    80003c18:	8b2e                	mv	s6,a1
    80003c1a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c1c:	00054703          	lbu	a4,0(a0)
    80003c20:	02f00793          	li	a5,47
    80003c24:	02f70263          	beq	a4,a5,80003c48 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c28:	ffffe097          	auipc	ra,0xffffe
    80003c2c:	e16080e7          	jalr	-490(ra) # 80001a3e <myproc>
    80003c30:	15053503          	ld	a0,336(a0)
    80003c34:	00000097          	auipc	ra,0x0
    80003c38:	9f8080e7          	jalr	-1544(ra) # 8000362c <idup>
    80003c3c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c3e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c42:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c44:	4b85                	li	s7,1
    80003c46:	a875                	j	80003d02 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003c48:	4585                	li	a1,1
    80003c4a:	4505                	li	a0,1
    80003c4c:	fffff097          	auipc	ra,0xfffff
    80003c50:	6ee080e7          	jalr	1774(ra) # 8000333a <iget>
    80003c54:	8a2a                	mv	s4,a0
    80003c56:	b7e5                	j	80003c3e <namex+0x42>
      iunlockput(ip);
    80003c58:	8552                	mv	a0,s4
    80003c5a:	00000097          	auipc	ra,0x0
    80003c5e:	c72080e7          	jalr	-910(ra) # 800038cc <iunlockput>
      return 0;
    80003c62:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c64:	8552                	mv	a0,s4
    80003c66:	60e6                	ld	ra,88(sp)
    80003c68:	6446                	ld	s0,80(sp)
    80003c6a:	64a6                	ld	s1,72(sp)
    80003c6c:	6906                	ld	s2,64(sp)
    80003c6e:	79e2                	ld	s3,56(sp)
    80003c70:	7a42                	ld	s4,48(sp)
    80003c72:	7aa2                	ld	s5,40(sp)
    80003c74:	7b02                	ld	s6,32(sp)
    80003c76:	6be2                	ld	s7,24(sp)
    80003c78:	6c42                	ld	s8,16(sp)
    80003c7a:	6ca2                	ld	s9,8(sp)
    80003c7c:	6125                	addi	sp,sp,96
    80003c7e:	8082                	ret
      iunlock(ip);
    80003c80:	8552                	mv	a0,s4
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	aaa080e7          	jalr	-1366(ra) # 8000372c <iunlock>
      return ip;
    80003c8a:	bfe9                	j	80003c64 <namex+0x68>
      iunlockput(ip);
    80003c8c:	8552                	mv	a0,s4
    80003c8e:	00000097          	auipc	ra,0x0
    80003c92:	c3e080e7          	jalr	-962(ra) # 800038cc <iunlockput>
      return 0;
    80003c96:	8a4e                	mv	s4,s3
    80003c98:	b7f1                	j	80003c64 <namex+0x68>
  len = path - s;
    80003c9a:	40998633          	sub	a2,s3,s1
    80003c9e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ca2:	099c5863          	bge	s8,s9,80003d32 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003ca6:	4639                	li	a2,14
    80003ca8:	85a6                	mv	a1,s1
    80003caa:	8556                	mv	a0,s5
    80003cac:	ffffd097          	auipc	ra,0xffffd
    80003cb0:	192080e7          	jalr	402(ra) # 80000e3e <memmove>
    80003cb4:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cb6:	0004c783          	lbu	a5,0(s1)
    80003cba:	01279763          	bne	a5,s2,80003cc8 <namex+0xcc>
    path++;
    80003cbe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cc0:	0004c783          	lbu	a5,0(s1)
    80003cc4:	ff278de3          	beq	a5,s2,80003cbe <namex+0xc2>
    ilock(ip);
    80003cc8:	8552                	mv	a0,s4
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	9a0080e7          	jalr	-1632(ra) # 8000366a <ilock>
    if(ip->type != T_DIR){
    80003cd2:	044a1783          	lh	a5,68(s4)
    80003cd6:	f97791e3          	bne	a5,s7,80003c58 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003cda:	000b0563          	beqz	s6,80003ce4 <namex+0xe8>
    80003cde:	0004c783          	lbu	a5,0(s1)
    80003ce2:	dfd9                	beqz	a5,80003c80 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ce4:	4601                	li	a2,0
    80003ce6:	85d6                	mv	a1,s5
    80003ce8:	8552                	mv	a0,s4
    80003cea:	00000097          	auipc	ra,0x0
    80003cee:	e62080e7          	jalr	-414(ra) # 80003b4c <dirlookup>
    80003cf2:	89aa                	mv	s3,a0
    80003cf4:	dd41                	beqz	a0,80003c8c <namex+0x90>
    iunlockput(ip);
    80003cf6:	8552                	mv	a0,s4
    80003cf8:	00000097          	auipc	ra,0x0
    80003cfc:	bd4080e7          	jalr	-1068(ra) # 800038cc <iunlockput>
    ip = next;
    80003d00:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d02:	0004c783          	lbu	a5,0(s1)
    80003d06:	01279763          	bne	a5,s2,80003d14 <namex+0x118>
    path++;
    80003d0a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d0c:	0004c783          	lbu	a5,0(s1)
    80003d10:	ff278de3          	beq	a5,s2,80003d0a <namex+0x10e>
  if(*path == 0)
    80003d14:	cb9d                	beqz	a5,80003d4a <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003d16:	0004c783          	lbu	a5,0(s1)
    80003d1a:	89a6                	mv	s3,s1
  len = path - s;
    80003d1c:	4c81                	li	s9,0
    80003d1e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003d20:	01278963          	beq	a5,s2,80003d32 <namex+0x136>
    80003d24:	dbbd                	beqz	a5,80003c9a <namex+0x9e>
    path++;
    80003d26:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d28:	0009c783          	lbu	a5,0(s3)
    80003d2c:	ff279ce3          	bne	a5,s2,80003d24 <namex+0x128>
    80003d30:	b7ad                	j	80003c9a <namex+0x9e>
    memmove(name, s, len);
    80003d32:	2601                	sext.w	a2,a2
    80003d34:	85a6                	mv	a1,s1
    80003d36:	8556                	mv	a0,s5
    80003d38:	ffffd097          	auipc	ra,0xffffd
    80003d3c:	106080e7          	jalr	262(ra) # 80000e3e <memmove>
    name[len] = 0;
    80003d40:	9cd6                	add	s9,s9,s5
    80003d42:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d46:	84ce                	mv	s1,s3
    80003d48:	b7bd                	j	80003cb6 <namex+0xba>
  if(nameiparent){
    80003d4a:	f00b0de3          	beqz	s6,80003c64 <namex+0x68>
    iput(ip);
    80003d4e:	8552                	mv	a0,s4
    80003d50:	00000097          	auipc	ra,0x0
    80003d54:	ad4080e7          	jalr	-1324(ra) # 80003824 <iput>
    return 0;
    80003d58:	4a01                	li	s4,0
    80003d5a:	b729                	j	80003c64 <namex+0x68>

0000000080003d5c <dirlink>:
{
    80003d5c:	7139                	addi	sp,sp,-64
    80003d5e:	fc06                	sd	ra,56(sp)
    80003d60:	f822                	sd	s0,48(sp)
    80003d62:	f426                	sd	s1,40(sp)
    80003d64:	f04a                	sd	s2,32(sp)
    80003d66:	ec4e                	sd	s3,24(sp)
    80003d68:	e852                	sd	s4,16(sp)
    80003d6a:	0080                	addi	s0,sp,64
    80003d6c:	892a                	mv	s2,a0
    80003d6e:	8a2e                	mv	s4,a1
    80003d70:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d72:	4601                	li	a2,0
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	dd8080e7          	jalr	-552(ra) # 80003b4c <dirlookup>
    80003d7c:	e93d                	bnez	a0,80003df2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d7e:	04c92483          	lw	s1,76(s2)
    80003d82:	c49d                	beqz	s1,80003db0 <dirlink+0x54>
    80003d84:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d86:	4741                	li	a4,16
    80003d88:	86a6                	mv	a3,s1
    80003d8a:	fc040613          	addi	a2,s0,-64
    80003d8e:	4581                	li	a1,0
    80003d90:	854a                	mv	a0,s2
    80003d92:	00000097          	auipc	ra,0x0
    80003d96:	b8c080e7          	jalr	-1140(ra) # 8000391e <readi>
    80003d9a:	47c1                	li	a5,16
    80003d9c:	06f51163          	bne	a0,a5,80003dfe <dirlink+0xa2>
    if(de.inum == 0)
    80003da0:	fc045783          	lhu	a5,-64(s0)
    80003da4:	c791                	beqz	a5,80003db0 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da6:	24c1                	addiw	s1,s1,16
    80003da8:	04c92783          	lw	a5,76(s2)
    80003dac:	fcf4ede3          	bltu	s1,a5,80003d86 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003db0:	4639                	li	a2,14
    80003db2:	85d2                	mv	a1,s4
    80003db4:	fc240513          	addi	a0,s0,-62
    80003db8:	ffffd097          	auipc	ra,0xffffd
    80003dbc:	13e080e7          	jalr	318(ra) # 80000ef6 <strncpy>
  de.inum = inum;
    80003dc0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dc4:	4741                	li	a4,16
    80003dc6:	86a6                	mv	a3,s1
    80003dc8:	fc040613          	addi	a2,s0,-64
    80003dcc:	4581                	li	a1,0
    80003dce:	854a                	mv	a0,s2
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	c46080e7          	jalr	-954(ra) # 80003a16 <writei>
    80003dd8:	872a                	mv	a4,a0
    80003dda:	47c1                	li	a5,16
  return 0;
    80003ddc:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dde:	02f71863          	bne	a4,a5,80003e0e <dirlink+0xb2>
}
    80003de2:	70e2                	ld	ra,56(sp)
    80003de4:	7442                	ld	s0,48(sp)
    80003de6:	74a2                	ld	s1,40(sp)
    80003de8:	7902                	ld	s2,32(sp)
    80003dea:	69e2                	ld	s3,24(sp)
    80003dec:	6a42                	ld	s4,16(sp)
    80003dee:	6121                	addi	sp,sp,64
    80003df0:	8082                	ret
    iput(ip);
    80003df2:	00000097          	auipc	ra,0x0
    80003df6:	a32080e7          	jalr	-1486(ra) # 80003824 <iput>
    return -1;
    80003dfa:	557d                	li	a0,-1
    80003dfc:	b7dd                	j	80003de2 <dirlink+0x86>
      panic("dirlink read");
    80003dfe:	00004517          	auipc	a0,0x4
    80003e02:	7ea50513          	addi	a0,a0,2026 # 800085e8 <syscalls+0x1c8>
    80003e06:	ffffc097          	auipc	ra,0xffffc
    80003e0a:	742080e7          	jalr	1858(ra) # 80000548 <panic>
    panic("dirlink");
    80003e0e:	00005517          	auipc	a0,0x5
    80003e12:	8fa50513          	addi	a0,a0,-1798 # 80008708 <syscalls+0x2e8>
    80003e16:	ffffc097          	auipc	ra,0xffffc
    80003e1a:	732080e7          	jalr	1842(ra) # 80000548 <panic>

0000000080003e1e <namei>:

struct inode*
namei(char *path)
{
    80003e1e:	1101                	addi	sp,sp,-32
    80003e20:	ec06                	sd	ra,24(sp)
    80003e22:	e822                	sd	s0,16(sp)
    80003e24:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e26:	fe040613          	addi	a2,s0,-32
    80003e2a:	4581                	li	a1,0
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	dd0080e7          	jalr	-560(ra) # 80003bfc <namex>
}
    80003e34:	60e2                	ld	ra,24(sp)
    80003e36:	6442                	ld	s0,16(sp)
    80003e38:	6105                	addi	sp,sp,32
    80003e3a:	8082                	ret

0000000080003e3c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e3c:	1141                	addi	sp,sp,-16
    80003e3e:	e406                	sd	ra,8(sp)
    80003e40:	e022                	sd	s0,0(sp)
    80003e42:	0800                	addi	s0,sp,16
    80003e44:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e46:	4585                	li	a1,1
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	db4080e7          	jalr	-588(ra) # 80003bfc <namex>
}
    80003e50:	60a2                	ld	ra,8(sp)
    80003e52:	6402                	ld	s0,0(sp)
    80003e54:	0141                	addi	sp,sp,16
    80003e56:	8082                	ret

0000000080003e58 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e58:	1101                	addi	sp,sp,-32
    80003e5a:	ec06                	sd	ra,24(sp)
    80003e5c:	e822                	sd	s0,16(sp)
    80003e5e:	e426                	sd	s1,8(sp)
    80003e60:	e04a                	sd	s2,0(sp)
    80003e62:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e64:	0001d917          	auipc	s2,0x1d
    80003e68:	3e490913          	addi	s2,s2,996 # 80021248 <log>
    80003e6c:	01892583          	lw	a1,24(s2)
    80003e70:	02892503          	lw	a0,40(s2)
    80003e74:	fffff097          	auipc	ra,0xfffff
    80003e78:	ffc080e7          	jalr	-4(ra) # 80002e70 <bread>
    80003e7c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e7e:	02c92603          	lw	a2,44(s2)
    80003e82:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e84:	00c05f63          	blez	a2,80003ea2 <write_head+0x4a>
    80003e88:	0001d717          	auipc	a4,0x1d
    80003e8c:	3f070713          	addi	a4,a4,1008 # 80021278 <log+0x30>
    80003e90:	87aa                	mv	a5,a0
    80003e92:	060a                	slli	a2,a2,0x2
    80003e94:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e96:	4314                	lw	a3,0(a4)
    80003e98:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e9a:	0711                	addi	a4,a4,4
    80003e9c:	0791                	addi	a5,a5,4
    80003e9e:	fec79ce3          	bne	a5,a2,80003e96 <write_head+0x3e>
  }
  bwrite(buf);
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	fffff097          	auipc	ra,0xfffff
    80003ea8:	0be080e7          	jalr	190(ra) # 80002f62 <bwrite>
  brelse(buf);
    80003eac:	8526                	mv	a0,s1
    80003eae:	fffff097          	auipc	ra,0xfffff
    80003eb2:	0f2080e7          	jalr	242(ra) # 80002fa0 <brelse>
}
    80003eb6:	60e2                	ld	ra,24(sp)
    80003eb8:	6442                	ld	s0,16(sp)
    80003eba:	64a2                	ld	s1,8(sp)
    80003ebc:	6902                	ld	s2,0(sp)
    80003ebe:	6105                	addi	sp,sp,32
    80003ec0:	8082                	ret

0000000080003ec2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ec2:	0001d797          	auipc	a5,0x1d
    80003ec6:	3b27a783          	lw	a5,946(a5) # 80021274 <log+0x2c>
    80003eca:	0af05d63          	blez	a5,80003f84 <install_trans+0xc2>
{
    80003ece:	7139                	addi	sp,sp,-64
    80003ed0:	fc06                	sd	ra,56(sp)
    80003ed2:	f822                	sd	s0,48(sp)
    80003ed4:	f426                	sd	s1,40(sp)
    80003ed6:	f04a                	sd	s2,32(sp)
    80003ed8:	ec4e                	sd	s3,24(sp)
    80003eda:	e852                	sd	s4,16(sp)
    80003edc:	e456                	sd	s5,8(sp)
    80003ede:	e05a                	sd	s6,0(sp)
    80003ee0:	0080                	addi	s0,sp,64
    80003ee2:	8b2a                	mv	s6,a0
    80003ee4:	0001da97          	auipc	s5,0x1d
    80003ee8:	394a8a93          	addi	s5,s5,916 # 80021278 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eec:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003eee:	0001d997          	auipc	s3,0x1d
    80003ef2:	35a98993          	addi	s3,s3,858 # 80021248 <log>
    80003ef6:	a00d                	j	80003f18 <install_trans+0x56>
    brelse(lbuf);
    80003ef8:	854a                	mv	a0,s2
    80003efa:	fffff097          	auipc	ra,0xfffff
    80003efe:	0a6080e7          	jalr	166(ra) # 80002fa0 <brelse>
    brelse(dbuf);
    80003f02:	8526                	mv	a0,s1
    80003f04:	fffff097          	auipc	ra,0xfffff
    80003f08:	09c080e7          	jalr	156(ra) # 80002fa0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f0c:	2a05                	addiw	s4,s4,1
    80003f0e:	0a91                	addi	s5,s5,4
    80003f10:	02c9a783          	lw	a5,44(s3)
    80003f14:	04fa5e63          	bge	s4,a5,80003f70 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f18:	0189a583          	lw	a1,24(s3)
    80003f1c:	014585bb          	addw	a1,a1,s4
    80003f20:	2585                	addiw	a1,a1,1
    80003f22:	0289a503          	lw	a0,40(s3)
    80003f26:	fffff097          	auipc	ra,0xfffff
    80003f2a:	f4a080e7          	jalr	-182(ra) # 80002e70 <bread>
    80003f2e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f30:	000aa583          	lw	a1,0(s5)
    80003f34:	0289a503          	lw	a0,40(s3)
    80003f38:	fffff097          	auipc	ra,0xfffff
    80003f3c:	f38080e7          	jalr	-200(ra) # 80002e70 <bread>
    80003f40:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f42:	40000613          	li	a2,1024
    80003f46:	05890593          	addi	a1,s2,88
    80003f4a:	05850513          	addi	a0,a0,88
    80003f4e:	ffffd097          	auipc	ra,0xffffd
    80003f52:	ef0080e7          	jalr	-272(ra) # 80000e3e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f56:	8526                	mv	a0,s1
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	00a080e7          	jalr	10(ra) # 80002f62 <bwrite>
    if(recovering == 0)
    80003f60:	f80b1ce3          	bnez	s6,80003ef8 <install_trans+0x36>
      bunpin(dbuf);
    80003f64:	8526                	mv	a0,s1
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	112080e7          	jalr	274(ra) # 80003078 <bunpin>
    80003f6e:	b769                	j	80003ef8 <install_trans+0x36>
}
    80003f70:	70e2                	ld	ra,56(sp)
    80003f72:	7442                	ld	s0,48(sp)
    80003f74:	74a2                	ld	s1,40(sp)
    80003f76:	7902                	ld	s2,32(sp)
    80003f78:	69e2                	ld	s3,24(sp)
    80003f7a:	6a42                	ld	s4,16(sp)
    80003f7c:	6aa2                	ld	s5,8(sp)
    80003f7e:	6b02                	ld	s6,0(sp)
    80003f80:	6121                	addi	sp,sp,64
    80003f82:	8082                	ret
    80003f84:	8082                	ret

0000000080003f86 <initlog>:
{
    80003f86:	7179                	addi	sp,sp,-48
    80003f88:	f406                	sd	ra,40(sp)
    80003f8a:	f022                	sd	s0,32(sp)
    80003f8c:	ec26                	sd	s1,24(sp)
    80003f8e:	e84a                	sd	s2,16(sp)
    80003f90:	e44e                	sd	s3,8(sp)
    80003f92:	1800                	addi	s0,sp,48
    80003f94:	892a                	mv	s2,a0
    80003f96:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f98:	0001d497          	auipc	s1,0x1d
    80003f9c:	2b048493          	addi	s1,s1,688 # 80021248 <log>
    80003fa0:	00004597          	auipc	a1,0x4
    80003fa4:	65858593          	addi	a1,a1,1624 # 800085f8 <syscalls+0x1d8>
    80003fa8:	8526                	mv	a0,s1
    80003faa:	ffffd097          	auipc	ra,0xffffd
    80003fae:	cac080e7          	jalr	-852(ra) # 80000c56 <initlock>
  log.start = sb->logstart;
    80003fb2:	0149a583          	lw	a1,20(s3)
    80003fb6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003fb8:	0109a783          	lw	a5,16(s3)
    80003fbc:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003fbe:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003fc2:	854a                	mv	a0,s2
    80003fc4:	fffff097          	auipc	ra,0xfffff
    80003fc8:	eac080e7          	jalr	-340(ra) # 80002e70 <bread>
  log.lh.n = lh->n;
    80003fcc:	4d30                	lw	a2,88(a0)
    80003fce:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fd0:	00c05f63          	blez	a2,80003fee <initlog+0x68>
    80003fd4:	87aa                	mv	a5,a0
    80003fd6:	0001d717          	auipc	a4,0x1d
    80003fda:	2a270713          	addi	a4,a4,674 # 80021278 <log+0x30>
    80003fde:	060a                	slli	a2,a2,0x2
    80003fe0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003fe2:	4ff4                	lw	a3,92(a5)
    80003fe4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fe6:	0791                	addi	a5,a5,4
    80003fe8:	0711                	addi	a4,a4,4
    80003fea:	fec79ce3          	bne	a5,a2,80003fe2 <initlog+0x5c>
  brelse(buf);
    80003fee:	fffff097          	auipc	ra,0xfffff
    80003ff2:	fb2080e7          	jalr	-78(ra) # 80002fa0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ff6:	4505                	li	a0,1
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	eca080e7          	jalr	-310(ra) # 80003ec2 <install_trans>
  log.lh.n = 0;
    80004000:	0001d797          	auipc	a5,0x1d
    80004004:	2607aa23          	sw	zero,628(a5) # 80021274 <log+0x2c>
  write_head(); // clear the log
    80004008:	00000097          	auipc	ra,0x0
    8000400c:	e50080e7          	jalr	-432(ra) # 80003e58 <write_head>
}
    80004010:	70a2                	ld	ra,40(sp)
    80004012:	7402                	ld	s0,32(sp)
    80004014:	64e2                	ld	s1,24(sp)
    80004016:	6942                	ld	s2,16(sp)
    80004018:	69a2                	ld	s3,8(sp)
    8000401a:	6145                	addi	sp,sp,48
    8000401c:	8082                	ret

000000008000401e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000401e:	1101                	addi	sp,sp,-32
    80004020:	ec06                	sd	ra,24(sp)
    80004022:	e822                	sd	s0,16(sp)
    80004024:	e426                	sd	s1,8(sp)
    80004026:	e04a                	sd	s2,0(sp)
    80004028:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000402a:	0001d517          	auipc	a0,0x1d
    8000402e:	21e50513          	addi	a0,a0,542 # 80021248 <log>
    80004032:	ffffd097          	auipc	ra,0xffffd
    80004036:	cb4080e7          	jalr	-844(ra) # 80000ce6 <acquire>
  while(1){
    if(log.committing){
    8000403a:	0001d497          	auipc	s1,0x1d
    8000403e:	20e48493          	addi	s1,s1,526 # 80021248 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004042:	4979                	li	s2,30
    80004044:	a039                	j	80004052 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004046:	85a6                	mv	a1,s1
    80004048:	8526                	mv	a0,s1
    8000404a:	ffffe097          	auipc	ra,0xffffe
    8000404e:	20a080e7          	jalr	522(ra) # 80002254 <sleep>
    if(log.committing){
    80004052:	50dc                	lw	a5,36(s1)
    80004054:	fbed                	bnez	a5,80004046 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004056:	5098                	lw	a4,32(s1)
    80004058:	2705                	addiw	a4,a4,1
    8000405a:	0027179b          	slliw	a5,a4,0x2
    8000405e:	9fb9                	addw	a5,a5,a4
    80004060:	0017979b          	slliw	a5,a5,0x1
    80004064:	54d4                	lw	a3,44(s1)
    80004066:	9fb5                	addw	a5,a5,a3
    80004068:	00f95963          	bge	s2,a5,8000407a <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000406c:	85a6                	mv	a1,s1
    8000406e:	8526                	mv	a0,s1
    80004070:	ffffe097          	auipc	ra,0xffffe
    80004074:	1e4080e7          	jalr	484(ra) # 80002254 <sleep>
    80004078:	bfe9                	j	80004052 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000407a:	0001d517          	auipc	a0,0x1d
    8000407e:	1ce50513          	addi	a0,a0,462 # 80021248 <log>
    80004082:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004084:	ffffd097          	auipc	ra,0xffffd
    80004088:	d16080e7          	jalr	-746(ra) # 80000d9a <release>
      break;
    }
  }
}
    8000408c:	60e2                	ld	ra,24(sp)
    8000408e:	6442                	ld	s0,16(sp)
    80004090:	64a2                	ld	s1,8(sp)
    80004092:	6902                	ld	s2,0(sp)
    80004094:	6105                	addi	sp,sp,32
    80004096:	8082                	ret

0000000080004098 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004098:	7139                	addi	sp,sp,-64
    8000409a:	fc06                	sd	ra,56(sp)
    8000409c:	f822                	sd	s0,48(sp)
    8000409e:	f426                	sd	s1,40(sp)
    800040a0:	f04a                	sd	s2,32(sp)
    800040a2:	ec4e                	sd	s3,24(sp)
    800040a4:	e852                	sd	s4,16(sp)
    800040a6:	e456                	sd	s5,8(sp)
    800040a8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040aa:	0001d497          	auipc	s1,0x1d
    800040ae:	19e48493          	addi	s1,s1,414 # 80021248 <log>
    800040b2:	8526                	mv	a0,s1
    800040b4:	ffffd097          	auipc	ra,0xffffd
    800040b8:	c32080e7          	jalr	-974(ra) # 80000ce6 <acquire>
  log.outstanding -= 1;
    800040bc:	509c                	lw	a5,32(s1)
    800040be:	37fd                	addiw	a5,a5,-1
    800040c0:	0007891b          	sext.w	s2,a5
    800040c4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040c6:	50dc                	lw	a5,36(s1)
    800040c8:	e7b9                	bnez	a5,80004116 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800040ca:	04091e63          	bnez	s2,80004126 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040ce:	0001d497          	auipc	s1,0x1d
    800040d2:	17a48493          	addi	s1,s1,378 # 80021248 <log>
    800040d6:	4785                	li	a5,1
    800040d8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040da:	8526                	mv	a0,s1
    800040dc:	ffffd097          	auipc	ra,0xffffd
    800040e0:	cbe080e7          	jalr	-834(ra) # 80000d9a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040e4:	54dc                	lw	a5,44(s1)
    800040e6:	06f04763          	bgtz	a5,80004154 <end_op+0xbc>
    acquire(&log.lock);
    800040ea:	0001d497          	auipc	s1,0x1d
    800040ee:	15e48493          	addi	s1,s1,350 # 80021248 <log>
    800040f2:	8526                	mv	a0,s1
    800040f4:	ffffd097          	auipc	ra,0xffffd
    800040f8:	bf2080e7          	jalr	-1038(ra) # 80000ce6 <acquire>
    log.committing = 0;
    800040fc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004100:	8526                	mv	a0,s1
    80004102:	ffffe097          	auipc	ra,0xffffe
    80004106:	2d2080e7          	jalr	722(ra) # 800023d4 <wakeup>
    release(&log.lock);
    8000410a:	8526                	mv	a0,s1
    8000410c:	ffffd097          	auipc	ra,0xffffd
    80004110:	c8e080e7          	jalr	-882(ra) # 80000d9a <release>
}
    80004114:	a03d                	j	80004142 <end_op+0xaa>
    panic("log.committing");
    80004116:	00004517          	auipc	a0,0x4
    8000411a:	4ea50513          	addi	a0,a0,1258 # 80008600 <syscalls+0x1e0>
    8000411e:	ffffc097          	auipc	ra,0xffffc
    80004122:	42a080e7          	jalr	1066(ra) # 80000548 <panic>
    wakeup(&log);
    80004126:	0001d497          	auipc	s1,0x1d
    8000412a:	12248493          	addi	s1,s1,290 # 80021248 <log>
    8000412e:	8526                	mv	a0,s1
    80004130:	ffffe097          	auipc	ra,0xffffe
    80004134:	2a4080e7          	jalr	676(ra) # 800023d4 <wakeup>
  release(&log.lock);
    80004138:	8526                	mv	a0,s1
    8000413a:	ffffd097          	auipc	ra,0xffffd
    8000413e:	c60080e7          	jalr	-928(ra) # 80000d9a <release>
}
    80004142:	70e2                	ld	ra,56(sp)
    80004144:	7442                	ld	s0,48(sp)
    80004146:	74a2                	ld	s1,40(sp)
    80004148:	7902                	ld	s2,32(sp)
    8000414a:	69e2                	ld	s3,24(sp)
    8000414c:	6a42                	ld	s4,16(sp)
    8000414e:	6aa2                	ld	s5,8(sp)
    80004150:	6121                	addi	sp,sp,64
    80004152:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004154:	0001da97          	auipc	s5,0x1d
    80004158:	124a8a93          	addi	s5,s5,292 # 80021278 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000415c:	0001da17          	auipc	s4,0x1d
    80004160:	0eca0a13          	addi	s4,s4,236 # 80021248 <log>
    80004164:	018a2583          	lw	a1,24(s4)
    80004168:	012585bb          	addw	a1,a1,s2
    8000416c:	2585                	addiw	a1,a1,1
    8000416e:	028a2503          	lw	a0,40(s4)
    80004172:	fffff097          	auipc	ra,0xfffff
    80004176:	cfe080e7          	jalr	-770(ra) # 80002e70 <bread>
    8000417a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000417c:	000aa583          	lw	a1,0(s5)
    80004180:	028a2503          	lw	a0,40(s4)
    80004184:	fffff097          	auipc	ra,0xfffff
    80004188:	cec080e7          	jalr	-788(ra) # 80002e70 <bread>
    8000418c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000418e:	40000613          	li	a2,1024
    80004192:	05850593          	addi	a1,a0,88
    80004196:	05848513          	addi	a0,s1,88
    8000419a:	ffffd097          	auipc	ra,0xffffd
    8000419e:	ca4080e7          	jalr	-860(ra) # 80000e3e <memmove>
    bwrite(to);  // write the log
    800041a2:	8526                	mv	a0,s1
    800041a4:	fffff097          	auipc	ra,0xfffff
    800041a8:	dbe080e7          	jalr	-578(ra) # 80002f62 <bwrite>
    brelse(from);
    800041ac:	854e                	mv	a0,s3
    800041ae:	fffff097          	auipc	ra,0xfffff
    800041b2:	df2080e7          	jalr	-526(ra) # 80002fa0 <brelse>
    brelse(to);
    800041b6:	8526                	mv	a0,s1
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	de8080e7          	jalr	-536(ra) # 80002fa0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c0:	2905                	addiw	s2,s2,1
    800041c2:	0a91                	addi	s5,s5,4
    800041c4:	02ca2783          	lw	a5,44(s4)
    800041c8:	f8f94ee3          	blt	s2,a5,80004164 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	c8c080e7          	jalr	-884(ra) # 80003e58 <write_head>
    install_trans(0); // Now install writes to home locations
    800041d4:	4501                	li	a0,0
    800041d6:	00000097          	auipc	ra,0x0
    800041da:	cec080e7          	jalr	-788(ra) # 80003ec2 <install_trans>
    log.lh.n = 0;
    800041de:	0001d797          	auipc	a5,0x1d
    800041e2:	0807ab23          	sw	zero,150(a5) # 80021274 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041e6:	00000097          	auipc	ra,0x0
    800041ea:	c72080e7          	jalr	-910(ra) # 80003e58 <write_head>
    800041ee:	bdf5                	j	800040ea <end_op+0x52>

00000000800041f0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041f0:	1101                	addi	sp,sp,-32
    800041f2:	ec06                	sd	ra,24(sp)
    800041f4:	e822                	sd	s0,16(sp)
    800041f6:	e426                	sd	s1,8(sp)
    800041f8:	e04a                	sd	s2,0(sp)
    800041fa:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800041fc:	0001d717          	auipc	a4,0x1d
    80004200:	07872703          	lw	a4,120(a4) # 80021274 <log+0x2c>
    80004204:	47f5                	li	a5,29
    80004206:	08e7c063          	blt	a5,a4,80004286 <log_write+0x96>
    8000420a:	84aa                	mv	s1,a0
    8000420c:	0001d797          	auipc	a5,0x1d
    80004210:	0587a783          	lw	a5,88(a5) # 80021264 <log+0x1c>
    80004214:	37fd                	addiw	a5,a5,-1
    80004216:	06f75863          	bge	a4,a5,80004286 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000421a:	0001d797          	auipc	a5,0x1d
    8000421e:	04e7a783          	lw	a5,78(a5) # 80021268 <log+0x20>
    80004222:	06f05a63          	blez	a5,80004296 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004226:	0001d917          	auipc	s2,0x1d
    8000422a:	02290913          	addi	s2,s2,34 # 80021248 <log>
    8000422e:	854a                	mv	a0,s2
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	ab6080e7          	jalr	-1354(ra) # 80000ce6 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004238:	02c92603          	lw	a2,44(s2)
    8000423c:	06c05563          	blez	a2,800042a6 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004240:	44cc                	lw	a1,12(s1)
    80004242:	0001d717          	auipc	a4,0x1d
    80004246:	03670713          	addi	a4,a4,54 # 80021278 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000424a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000424c:	4314                	lw	a3,0(a4)
    8000424e:	04b68d63          	beq	a3,a1,800042a8 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004252:	2785                	addiw	a5,a5,1
    80004254:	0711                	addi	a4,a4,4
    80004256:	fec79be3          	bne	a5,a2,8000424c <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000425a:	0621                	addi	a2,a2,8
    8000425c:	060a                	slli	a2,a2,0x2
    8000425e:	0001d797          	auipc	a5,0x1d
    80004262:	fea78793          	addi	a5,a5,-22 # 80021248 <log>
    80004266:	97b2                	add	a5,a5,a2
    80004268:	44d8                	lw	a4,12(s1)
    8000426a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000426c:	8526                	mv	a0,s1
    8000426e:	fffff097          	auipc	ra,0xfffff
    80004272:	dce080e7          	jalr	-562(ra) # 8000303c <bpin>
    log.lh.n++;
    80004276:	0001d717          	auipc	a4,0x1d
    8000427a:	fd270713          	addi	a4,a4,-46 # 80021248 <log>
    8000427e:	575c                	lw	a5,44(a4)
    80004280:	2785                	addiw	a5,a5,1
    80004282:	d75c                	sw	a5,44(a4)
    80004284:	a835                	j	800042c0 <log_write+0xd0>
    panic("too big a transaction");
    80004286:	00004517          	auipc	a0,0x4
    8000428a:	38a50513          	addi	a0,a0,906 # 80008610 <syscalls+0x1f0>
    8000428e:	ffffc097          	auipc	ra,0xffffc
    80004292:	2ba080e7          	jalr	698(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004296:	00004517          	auipc	a0,0x4
    8000429a:	39250513          	addi	a0,a0,914 # 80008628 <syscalls+0x208>
    8000429e:	ffffc097          	auipc	ra,0xffffc
    800042a2:	2aa080e7          	jalr	682(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800042a6:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800042a8:	00878693          	addi	a3,a5,8
    800042ac:	068a                	slli	a3,a3,0x2
    800042ae:	0001d717          	auipc	a4,0x1d
    800042b2:	f9a70713          	addi	a4,a4,-102 # 80021248 <log>
    800042b6:	9736                	add	a4,a4,a3
    800042b8:	44d4                	lw	a3,12(s1)
    800042ba:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042bc:	faf608e3          	beq	a2,a5,8000426c <log_write+0x7c>
  }
  release(&log.lock);
    800042c0:	0001d517          	auipc	a0,0x1d
    800042c4:	f8850513          	addi	a0,a0,-120 # 80021248 <log>
    800042c8:	ffffd097          	auipc	ra,0xffffd
    800042cc:	ad2080e7          	jalr	-1326(ra) # 80000d9a <release>
}
    800042d0:	60e2                	ld	ra,24(sp)
    800042d2:	6442                	ld	s0,16(sp)
    800042d4:	64a2                	ld	s1,8(sp)
    800042d6:	6902                	ld	s2,0(sp)
    800042d8:	6105                	addi	sp,sp,32
    800042da:	8082                	ret

00000000800042dc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042dc:	1101                	addi	sp,sp,-32
    800042de:	ec06                	sd	ra,24(sp)
    800042e0:	e822                	sd	s0,16(sp)
    800042e2:	e426                	sd	s1,8(sp)
    800042e4:	e04a                	sd	s2,0(sp)
    800042e6:	1000                	addi	s0,sp,32
    800042e8:	84aa                	mv	s1,a0
    800042ea:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042ec:	00004597          	auipc	a1,0x4
    800042f0:	35c58593          	addi	a1,a1,860 # 80008648 <syscalls+0x228>
    800042f4:	0521                	addi	a0,a0,8
    800042f6:	ffffd097          	auipc	ra,0xffffd
    800042fa:	960080e7          	jalr	-1696(ra) # 80000c56 <initlock>
  lk->name = name;
    800042fe:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004302:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004306:	0204a423          	sw	zero,40(s1)
}
    8000430a:	60e2                	ld	ra,24(sp)
    8000430c:	6442                	ld	s0,16(sp)
    8000430e:	64a2                	ld	s1,8(sp)
    80004310:	6902                	ld	s2,0(sp)
    80004312:	6105                	addi	sp,sp,32
    80004314:	8082                	ret

0000000080004316 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004316:	1101                	addi	sp,sp,-32
    80004318:	ec06                	sd	ra,24(sp)
    8000431a:	e822                	sd	s0,16(sp)
    8000431c:	e426                	sd	s1,8(sp)
    8000431e:	e04a                	sd	s2,0(sp)
    80004320:	1000                	addi	s0,sp,32
    80004322:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004324:	00850913          	addi	s2,a0,8
    80004328:	854a                	mv	a0,s2
    8000432a:	ffffd097          	auipc	ra,0xffffd
    8000432e:	9bc080e7          	jalr	-1604(ra) # 80000ce6 <acquire>
  while (lk->locked) {
    80004332:	409c                	lw	a5,0(s1)
    80004334:	cb89                	beqz	a5,80004346 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004336:	85ca                	mv	a1,s2
    80004338:	8526                	mv	a0,s1
    8000433a:	ffffe097          	auipc	ra,0xffffe
    8000433e:	f1a080e7          	jalr	-230(ra) # 80002254 <sleep>
  while (lk->locked) {
    80004342:	409c                	lw	a5,0(s1)
    80004344:	fbed                	bnez	a5,80004336 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004346:	4785                	li	a5,1
    80004348:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000434a:	ffffd097          	auipc	ra,0xffffd
    8000434e:	6f4080e7          	jalr	1780(ra) # 80001a3e <myproc>
    80004352:	5d1c                	lw	a5,56(a0)
    80004354:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004356:	854a                	mv	a0,s2
    80004358:	ffffd097          	auipc	ra,0xffffd
    8000435c:	a42080e7          	jalr	-1470(ra) # 80000d9a <release>
}
    80004360:	60e2                	ld	ra,24(sp)
    80004362:	6442                	ld	s0,16(sp)
    80004364:	64a2                	ld	s1,8(sp)
    80004366:	6902                	ld	s2,0(sp)
    80004368:	6105                	addi	sp,sp,32
    8000436a:	8082                	ret

000000008000436c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000436c:	1101                	addi	sp,sp,-32
    8000436e:	ec06                	sd	ra,24(sp)
    80004370:	e822                	sd	s0,16(sp)
    80004372:	e426                	sd	s1,8(sp)
    80004374:	e04a                	sd	s2,0(sp)
    80004376:	1000                	addi	s0,sp,32
    80004378:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000437a:	00850913          	addi	s2,a0,8
    8000437e:	854a                	mv	a0,s2
    80004380:	ffffd097          	auipc	ra,0xffffd
    80004384:	966080e7          	jalr	-1690(ra) # 80000ce6 <acquire>
  lk->locked = 0;
    80004388:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000438c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004390:	8526                	mv	a0,s1
    80004392:	ffffe097          	auipc	ra,0xffffe
    80004396:	042080e7          	jalr	66(ra) # 800023d4 <wakeup>
  release(&lk->lk);
    8000439a:	854a                	mv	a0,s2
    8000439c:	ffffd097          	auipc	ra,0xffffd
    800043a0:	9fe080e7          	jalr	-1538(ra) # 80000d9a <release>
}
    800043a4:	60e2                	ld	ra,24(sp)
    800043a6:	6442                	ld	s0,16(sp)
    800043a8:	64a2                	ld	s1,8(sp)
    800043aa:	6902                	ld	s2,0(sp)
    800043ac:	6105                	addi	sp,sp,32
    800043ae:	8082                	ret

00000000800043b0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043b0:	7179                	addi	sp,sp,-48
    800043b2:	f406                	sd	ra,40(sp)
    800043b4:	f022                	sd	s0,32(sp)
    800043b6:	ec26                	sd	s1,24(sp)
    800043b8:	e84a                	sd	s2,16(sp)
    800043ba:	e44e                	sd	s3,8(sp)
    800043bc:	1800                	addi	s0,sp,48
    800043be:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043c0:	00850913          	addi	s2,a0,8
    800043c4:	854a                	mv	a0,s2
    800043c6:	ffffd097          	auipc	ra,0xffffd
    800043ca:	920080e7          	jalr	-1760(ra) # 80000ce6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ce:	409c                	lw	a5,0(s1)
    800043d0:	ef99                	bnez	a5,800043ee <holdingsleep+0x3e>
    800043d2:	4481                	li	s1,0
  release(&lk->lk);
    800043d4:	854a                	mv	a0,s2
    800043d6:	ffffd097          	auipc	ra,0xffffd
    800043da:	9c4080e7          	jalr	-1596(ra) # 80000d9a <release>
  return r;
}
    800043de:	8526                	mv	a0,s1
    800043e0:	70a2                	ld	ra,40(sp)
    800043e2:	7402                	ld	s0,32(sp)
    800043e4:	64e2                	ld	s1,24(sp)
    800043e6:	6942                	ld	s2,16(sp)
    800043e8:	69a2                	ld	s3,8(sp)
    800043ea:	6145                	addi	sp,sp,48
    800043ec:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ee:	0284a983          	lw	s3,40(s1)
    800043f2:	ffffd097          	auipc	ra,0xffffd
    800043f6:	64c080e7          	jalr	1612(ra) # 80001a3e <myproc>
    800043fa:	5d04                	lw	s1,56(a0)
    800043fc:	413484b3          	sub	s1,s1,s3
    80004400:	0014b493          	seqz	s1,s1
    80004404:	bfc1                	j	800043d4 <holdingsleep+0x24>

0000000080004406 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004406:	1141                	addi	sp,sp,-16
    80004408:	e406                	sd	ra,8(sp)
    8000440a:	e022                	sd	s0,0(sp)
    8000440c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000440e:	00004597          	auipc	a1,0x4
    80004412:	24a58593          	addi	a1,a1,586 # 80008658 <syscalls+0x238>
    80004416:	0001d517          	auipc	a0,0x1d
    8000441a:	f7a50513          	addi	a0,a0,-134 # 80021390 <ftable>
    8000441e:	ffffd097          	auipc	ra,0xffffd
    80004422:	838080e7          	jalr	-1992(ra) # 80000c56 <initlock>
}
    80004426:	60a2                	ld	ra,8(sp)
    80004428:	6402                	ld	s0,0(sp)
    8000442a:	0141                	addi	sp,sp,16
    8000442c:	8082                	ret

000000008000442e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000442e:	1101                	addi	sp,sp,-32
    80004430:	ec06                	sd	ra,24(sp)
    80004432:	e822                	sd	s0,16(sp)
    80004434:	e426                	sd	s1,8(sp)
    80004436:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004438:	0001d517          	auipc	a0,0x1d
    8000443c:	f5850513          	addi	a0,a0,-168 # 80021390 <ftable>
    80004440:	ffffd097          	auipc	ra,0xffffd
    80004444:	8a6080e7          	jalr	-1882(ra) # 80000ce6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004448:	0001d497          	auipc	s1,0x1d
    8000444c:	f6048493          	addi	s1,s1,-160 # 800213a8 <ftable+0x18>
    80004450:	0001e717          	auipc	a4,0x1e
    80004454:	ef870713          	addi	a4,a4,-264 # 80022348 <ftable+0xfb8>
    if(f->ref == 0){
    80004458:	40dc                	lw	a5,4(s1)
    8000445a:	cf99                	beqz	a5,80004478 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000445c:	02848493          	addi	s1,s1,40
    80004460:	fee49ce3          	bne	s1,a4,80004458 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004464:	0001d517          	auipc	a0,0x1d
    80004468:	f2c50513          	addi	a0,a0,-212 # 80021390 <ftable>
    8000446c:	ffffd097          	auipc	ra,0xffffd
    80004470:	92e080e7          	jalr	-1746(ra) # 80000d9a <release>
  return 0;
    80004474:	4481                	li	s1,0
    80004476:	a819                	j	8000448c <filealloc+0x5e>
      f->ref = 1;
    80004478:	4785                	li	a5,1
    8000447a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000447c:	0001d517          	auipc	a0,0x1d
    80004480:	f1450513          	addi	a0,a0,-236 # 80021390 <ftable>
    80004484:	ffffd097          	auipc	ra,0xffffd
    80004488:	916080e7          	jalr	-1770(ra) # 80000d9a <release>
}
    8000448c:	8526                	mv	a0,s1
    8000448e:	60e2                	ld	ra,24(sp)
    80004490:	6442                	ld	s0,16(sp)
    80004492:	64a2                	ld	s1,8(sp)
    80004494:	6105                	addi	sp,sp,32
    80004496:	8082                	ret

0000000080004498 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004498:	1101                	addi	sp,sp,-32
    8000449a:	ec06                	sd	ra,24(sp)
    8000449c:	e822                	sd	s0,16(sp)
    8000449e:	e426                	sd	s1,8(sp)
    800044a0:	1000                	addi	s0,sp,32
    800044a2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044a4:	0001d517          	auipc	a0,0x1d
    800044a8:	eec50513          	addi	a0,a0,-276 # 80021390 <ftable>
    800044ac:	ffffd097          	auipc	ra,0xffffd
    800044b0:	83a080e7          	jalr	-1990(ra) # 80000ce6 <acquire>
  if(f->ref < 1)
    800044b4:	40dc                	lw	a5,4(s1)
    800044b6:	02f05263          	blez	a5,800044da <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044ba:	2785                	addiw	a5,a5,1
    800044bc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044be:	0001d517          	auipc	a0,0x1d
    800044c2:	ed250513          	addi	a0,a0,-302 # 80021390 <ftable>
    800044c6:	ffffd097          	auipc	ra,0xffffd
    800044ca:	8d4080e7          	jalr	-1836(ra) # 80000d9a <release>
  return f;
}
    800044ce:	8526                	mv	a0,s1
    800044d0:	60e2                	ld	ra,24(sp)
    800044d2:	6442                	ld	s0,16(sp)
    800044d4:	64a2                	ld	s1,8(sp)
    800044d6:	6105                	addi	sp,sp,32
    800044d8:	8082                	ret
    panic("filedup");
    800044da:	00004517          	auipc	a0,0x4
    800044de:	18650513          	addi	a0,a0,390 # 80008660 <syscalls+0x240>
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	066080e7          	jalr	102(ra) # 80000548 <panic>

00000000800044ea <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044ea:	7139                	addi	sp,sp,-64
    800044ec:	fc06                	sd	ra,56(sp)
    800044ee:	f822                	sd	s0,48(sp)
    800044f0:	f426                	sd	s1,40(sp)
    800044f2:	f04a                	sd	s2,32(sp)
    800044f4:	ec4e                	sd	s3,24(sp)
    800044f6:	e852                	sd	s4,16(sp)
    800044f8:	e456                	sd	s5,8(sp)
    800044fa:	0080                	addi	s0,sp,64
    800044fc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044fe:	0001d517          	auipc	a0,0x1d
    80004502:	e9250513          	addi	a0,a0,-366 # 80021390 <ftable>
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	7e0080e7          	jalr	2016(ra) # 80000ce6 <acquire>
  if(f->ref < 1)
    8000450e:	40dc                	lw	a5,4(s1)
    80004510:	06f05163          	blez	a5,80004572 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004514:	37fd                	addiw	a5,a5,-1
    80004516:	0007871b          	sext.w	a4,a5
    8000451a:	c0dc                	sw	a5,4(s1)
    8000451c:	06e04363          	bgtz	a4,80004582 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004520:	0004a903          	lw	s2,0(s1)
    80004524:	0094ca83          	lbu	s5,9(s1)
    80004528:	0104ba03          	ld	s4,16(s1)
    8000452c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004530:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004534:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004538:	0001d517          	auipc	a0,0x1d
    8000453c:	e5850513          	addi	a0,a0,-424 # 80021390 <ftable>
    80004540:	ffffd097          	auipc	ra,0xffffd
    80004544:	85a080e7          	jalr	-1958(ra) # 80000d9a <release>

  if(ff.type == FD_PIPE){
    80004548:	4785                	li	a5,1
    8000454a:	04f90d63          	beq	s2,a5,800045a4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000454e:	3979                	addiw	s2,s2,-2
    80004550:	4785                	li	a5,1
    80004552:	0527e063          	bltu	a5,s2,80004592 <fileclose+0xa8>
    begin_op();
    80004556:	00000097          	auipc	ra,0x0
    8000455a:	ac8080e7          	jalr	-1336(ra) # 8000401e <begin_op>
    iput(ff.ip);
    8000455e:	854e                	mv	a0,s3
    80004560:	fffff097          	auipc	ra,0xfffff
    80004564:	2c4080e7          	jalr	708(ra) # 80003824 <iput>
    end_op();
    80004568:	00000097          	auipc	ra,0x0
    8000456c:	b30080e7          	jalr	-1232(ra) # 80004098 <end_op>
    80004570:	a00d                	j	80004592 <fileclose+0xa8>
    panic("fileclose");
    80004572:	00004517          	auipc	a0,0x4
    80004576:	0f650513          	addi	a0,a0,246 # 80008668 <syscalls+0x248>
    8000457a:	ffffc097          	auipc	ra,0xffffc
    8000457e:	fce080e7          	jalr	-50(ra) # 80000548 <panic>
    release(&ftable.lock);
    80004582:	0001d517          	auipc	a0,0x1d
    80004586:	e0e50513          	addi	a0,a0,-498 # 80021390 <ftable>
    8000458a:	ffffd097          	auipc	ra,0xffffd
    8000458e:	810080e7          	jalr	-2032(ra) # 80000d9a <release>
  }
}
    80004592:	70e2                	ld	ra,56(sp)
    80004594:	7442                	ld	s0,48(sp)
    80004596:	74a2                	ld	s1,40(sp)
    80004598:	7902                	ld	s2,32(sp)
    8000459a:	69e2                	ld	s3,24(sp)
    8000459c:	6a42                	ld	s4,16(sp)
    8000459e:	6aa2                	ld	s5,8(sp)
    800045a0:	6121                	addi	sp,sp,64
    800045a2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045a4:	85d6                	mv	a1,s5
    800045a6:	8552                	mv	a0,s4
    800045a8:	00000097          	auipc	ra,0x0
    800045ac:	372080e7          	jalr	882(ra) # 8000491a <pipeclose>
    800045b0:	b7cd                	j	80004592 <fileclose+0xa8>

00000000800045b2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045b2:	715d                	addi	sp,sp,-80
    800045b4:	e486                	sd	ra,72(sp)
    800045b6:	e0a2                	sd	s0,64(sp)
    800045b8:	fc26                	sd	s1,56(sp)
    800045ba:	f84a                	sd	s2,48(sp)
    800045bc:	f44e                	sd	s3,40(sp)
    800045be:	0880                	addi	s0,sp,80
    800045c0:	84aa                	mv	s1,a0
    800045c2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800045c4:	ffffd097          	auipc	ra,0xffffd
    800045c8:	47a080e7          	jalr	1146(ra) # 80001a3e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045cc:	409c                	lw	a5,0(s1)
    800045ce:	37f9                	addiw	a5,a5,-2
    800045d0:	4705                	li	a4,1
    800045d2:	04f76763          	bltu	a4,a5,80004620 <filestat+0x6e>
    800045d6:	892a                	mv	s2,a0
    ilock(f->ip);
    800045d8:	6c88                	ld	a0,24(s1)
    800045da:	fffff097          	auipc	ra,0xfffff
    800045de:	090080e7          	jalr	144(ra) # 8000366a <ilock>
    stati(f->ip, &st);
    800045e2:	fb840593          	addi	a1,s0,-72
    800045e6:	6c88                	ld	a0,24(s1)
    800045e8:	fffff097          	auipc	ra,0xfffff
    800045ec:	30c080e7          	jalr	780(ra) # 800038f4 <stati>
    iunlock(f->ip);
    800045f0:	6c88                	ld	a0,24(s1)
    800045f2:	fffff097          	auipc	ra,0xfffff
    800045f6:	13a080e7          	jalr	314(ra) # 8000372c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045fa:	46e1                	li	a3,24
    800045fc:	fb840613          	addi	a2,s0,-72
    80004600:	85ce                	mv	a1,s3
    80004602:	05093503          	ld	a0,80(s2)
    80004606:	ffffd097          	auipc	ra,0xffffd
    8000460a:	12e080e7          	jalr	302(ra) # 80001734 <copyout>
    8000460e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004612:	60a6                	ld	ra,72(sp)
    80004614:	6406                	ld	s0,64(sp)
    80004616:	74e2                	ld	s1,56(sp)
    80004618:	7942                	ld	s2,48(sp)
    8000461a:	79a2                	ld	s3,40(sp)
    8000461c:	6161                	addi	sp,sp,80
    8000461e:	8082                	ret
  return -1;
    80004620:	557d                	li	a0,-1
    80004622:	bfc5                	j	80004612 <filestat+0x60>

0000000080004624 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004624:	7179                	addi	sp,sp,-48
    80004626:	f406                	sd	ra,40(sp)
    80004628:	f022                	sd	s0,32(sp)
    8000462a:	ec26                	sd	s1,24(sp)
    8000462c:	e84a                	sd	s2,16(sp)
    8000462e:	e44e                	sd	s3,8(sp)
    80004630:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004632:	00854783          	lbu	a5,8(a0)
    80004636:	c3d5                	beqz	a5,800046da <fileread+0xb6>
    80004638:	84aa                	mv	s1,a0
    8000463a:	89ae                	mv	s3,a1
    8000463c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000463e:	411c                	lw	a5,0(a0)
    80004640:	4705                	li	a4,1
    80004642:	04e78963          	beq	a5,a4,80004694 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004646:	470d                	li	a4,3
    80004648:	04e78d63          	beq	a5,a4,800046a2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000464c:	4709                	li	a4,2
    8000464e:	06e79e63          	bne	a5,a4,800046ca <fileread+0xa6>
    ilock(f->ip);
    80004652:	6d08                	ld	a0,24(a0)
    80004654:	fffff097          	auipc	ra,0xfffff
    80004658:	016080e7          	jalr	22(ra) # 8000366a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000465c:	874a                	mv	a4,s2
    8000465e:	5094                	lw	a3,32(s1)
    80004660:	864e                	mv	a2,s3
    80004662:	4585                	li	a1,1
    80004664:	6c88                	ld	a0,24(s1)
    80004666:	fffff097          	auipc	ra,0xfffff
    8000466a:	2b8080e7          	jalr	696(ra) # 8000391e <readi>
    8000466e:	892a                	mv	s2,a0
    80004670:	00a05563          	blez	a0,8000467a <fileread+0x56>
      f->off += r;
    80004674:	509c                	lw	a5,32(s1)
    80004676:	9fa9                	addw	a5,a5,a0
    80004678:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000467a:	6c88                	ld	a0,24(s1)
    8000467c:	fffff097          	auipc	ra,0xfffff
    80004680:	0b0080e7          	jalr	176(ra) # 8000372c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004684:	854a                	mv	a0,s2
    80004686:	70a2                	ld	ra,40(sp)
    80004688:	7402                	ld	s0,32(sp)
    8000468a:	64e2                	ld	s1,24(sp)
    8000468c:	6942                	ld	s2,16(sp)
    8000468e:	69a2                	ld	s3,8(sp)
    80004690:	6145                	addi	sp,sp,48
    80004692:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004694:	6908                	ld	a0,16(a0)
    80004696:	00000097          	auipc	ra,0x0
    8000469a:	3ee080e7          	jalr	1006(ra) # 80004a84 <piperead>
    8000469e:	892a                	mv	s2,a0
    800046a0:	b7d5                	j	80004684 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046a2:	02451783          	lh	a5,36(a0)
    800046a6:	03079693          	slli	a3,a5,0x30
    800046aa:	92c1                	srli	a3,a3,0x30
    800046ac:	4725                	li	a4,9
    800046ae:	02d76863          	bltu	a4,a3,800046de <fileread+0xba>
    800046b2:	0792                	slli	a5,a5,0x4
    800046b4:	0001d717          	auipc	a4,0x1d
    800046b8:	c3c70713          	addi	a4,a4,-964 # 800212f0 <devsw>
    800046bc:	97ba                	add	a5,a5,a4
    800046be:	639c                	ld	a5,0(a5)
    800046c0:	c38d                	beqz	a5,800046e2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800046c2:	4505                	li	a0,1
    800046c4:	9782                	jalr	a5
    800046c6:	892a                	mv	s2,a0
    800046c8:	bf75                	j	80004684 <fileread+0x60>
    panic("fileread");
    800046ca:	00004517          	auipc	a0,0x4
    800046ce:	fae50513          	addi	a0,a0,-82 # 80008678 <syscalls+0x258>
    800046d2:	ffffc097          	auipc	ra,0xffffc
    800046d6:	e76080e7          	jalr	-394(ra) # 80000548 <panic>
    return -1;
    800046da:	597d                	li	s2,-1
    800046dc:	b765                	j	80004684 <fileread+0x60>
      return -1;
    800046de:	597d                	li	s2,-1
    800046e0:	b755                	j	80004684 <fileread+0x60>
    800046e2:	597d                	li	s2,-1
    800046e4:	b745                	j	80004684 <fileread+0x60>

00000000800046e6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800046e6:	00954783          	lbu	a5,9(a0)
    800046ea:	14078363          	beqz	a5,80004830 <filewrite+0x14a>
{
    800046ee:	715d                	addi	sp,sp,-80
    800046f0:	e486                	sd	ra,72(sp)
    800046f2:	e0a2                	sd	s0,64(sp)
    800046f4:	fc26                	sd	s1,56(sp)
    800046f6:	f84a                	sd	s2,48(sp)
    800046f8:	f44e                	sd	s3,40(sp)
    800046fa:	f052                	sd	s4,32(sp)
    800046fc:	ec56                	sd	s5,24(sp)
    800046fe:	e85a                	sd	s6,16(sp)
    80004700:	e45e                	sd	s7,8(sp)
    80004702:	e062                	sd	s8,0(sp)
    80004704:	0880                	addi	s0,sp,80
    80004706:	892a                	mv	s2,a0
    80004708:	8b2e                	mv	s6,a1
    8000470a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000470c:	411c                	lw	a5,0(a0)
    8000470e:	4705                	li	a4,1
    80004710:	02e78263          	beq	a5,a4,80004734 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004714:	470d                	li	a4,3
    80004716:	02e78563          	beq	a5,a4,80004740 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000471a:	4709                	li	a4,2
    8000471c:	10e79263          	bne	a5,a4,80004820 <filewrite+0x13a>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004720:	0ec05e63          	blez	a2,8000481c <filewrite+0x136>
    int i = 0;
    80004724:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004726:	6b85                	lui	s7,0x1
    80004728:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000472c:	6c05                	lui	s8,0x1
    8000472e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004732:	a851                	j	800047c6 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004734:	6908                	ld	a0,16(a0)
    80004736:	00000097          	auipc	ra,0x0
    8000473a:	254080e7          	jalr	596(ra) # 8000498a <pipewrite>
    8000473e:	a85d                	j	800047f4 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004740:	02451783          	lh	a5,36(a0)
    80004744:	03079693          	slli	a3,a5,0x30
    80004748:	92c1                	srli	a3,a3,0x30
    8000474a:	4725                	li	a4,9
    8000474c:	0ed76463          	bltu	a4,a3,80004834 <filewrite+0x14e>
    80004750:	0792                	slli	a5,a5,0x4
    80004752:	0001d717          	auipc	a4,0x1d
    80004756:	b9e70713          	addi	a4,a4,-1122 # 800212f0 <devsw>
    8000475a:	97ba                	add	a5,a5,a4
    8000475c:	679c                	ld	a5,8(a5)
    8000475e:	cfe9                	beqz	a5,80004838 <filewrite+0x152>
    ret = devsw[f->major].write(1, addr, n);
    80004760:	4505                	li	a0,1
    80004762:	9782                	jalr	a5
    80004764:	a841                	j	800047f4 <filewrite+0x10e>
      if(n1 > max)
    80004766:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000476a:	00000097          	auipc	ra,0x0
    8000476e:	8b4080e7          	jalr	-1868(ra) # 8000401e <begin_op>
      ilock(f->ip);
    80004772:	01893503          	ld	a0,24(s2)
    80004776:	fffff097          	auipc	ra,0xfffff
    8000477a:	ef4080e7          	jalr	-268(ra) # 8000366a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000477e:	8756                	mv	a4,s5
    80004780:	02092683          	lw	a3,32(s2)
    80004784:	01698633          	add	a2,s3,s6
    80004788:	4585                	li	a1,1
    8000478a:	01893503          	ld	a0,24(s2)
    8000478e:	fffff097          	auipc	ra,0xfffff
    80004792:	288080e7          	jalr	648(ra) # 80003a16 <writei>
    80004796:	84aa                	mv	s1,a0
    80004798:	02a05f63          	blez	a0,800047d6 <filewrite+0xf0>
        f->off += r;
    8000479c:	02092783          	lw	a5,32(s2)
    800047a0:	9fa9                	addw	a5,a5,a0
    800047a2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047a6:	01893503          	ld	a0,24(s2)
    800047aa:	fffff097          	auipc	ra,0xfffff
    800047ae:	f82080e7          	jalr	-126(ra) # 8000372c <iunlock>
      end_op();
    800047b2:	00000097          	auipc	ra,0x0
    800047b6:	8e6080e7          	jalr	-1818(ra) # 80004098 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800047ba:	049a9963          	bne	s5,s1,8000480c <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800047be:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800047c2:	0349d663          	bge	s3,s4,800047ee <filewrite+0x108>
      int n1 = n - i;
    800047c6:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800047ca:	0004879b          	sext.w	a5,s1
    800047ce:	f8fbdce3          	bge	s7,a5,80004766 <filewrite+0x80>
    800047d2:	84e2                	mv	s1,s8
    800047d4:	bf49                	j	80004766 <filewrite+0x80>
      iunlock(f->ip);
    800047d6:	01893503          	ld	a0,24(s2)
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	f52080e7          	jalr	-174(ra) # 8000372c <iunlock>
      end_op();
    800047e2:	00000097          	auipc	ra,0x0
    800047e6:	8b6080e7          	jalr	-1866(ra) # 80004098 <end_op>
      if(r < 0)
    800047ea:	fc04d8e3          	bgez	s1,800047ba <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800047ee:	053a1763          	bne	s4,s3,8000483c <filewrite+0x156>
    800047f2:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047f4:	60a6                	ld	ra,72(sp)
    800047f6:	6406                	ld	s0,64(sp)
    800047f8:	74e2                	ld	s1,56(sp)
    800047fa:	7942                	ld	s2,48(sp)
    800047fc:	79a2                	ld	s3,40(sp)
    800047fe:	7a02                	ld	s4,32(sp)
    80004800:	6ae2                	ld	s5,24(sp)
    80004802:	6b42                	ld	s6,16(sp)
    80004804:	6ba2                	ld	s7,8(sp)
    80004806:	6c02                	ld	s8,0(sp)
    80004808:	6161                	addi	sp,sp,80
    8000480a:	8082                	ret
        panic("short filewrite");
    8000480c:	00004517          	auipc	a0,0x4
    80004810:	e7c50513          	addi	a0,a0,-388 # 80008688 <syscalls+0x268>
    80004814:	ffffc097          	auipc	ra,0xffffc
    80004818:	d34080e7          	jalr	-716(ra) # 80000548 <panic>
    int i = 0;
    8000481c:	4981                	li	s3,0
    8000481e:	bfc1                	j	800047ee <filewrite+0x108>
    panic("filewrite");
    80004820:	00004517          	auipc	a0,0x4
    80004824:	e7850513          	addi	a0,a0,-392 # 80008698 <syscalls+0x278>
    80004828:	ffffc097          	auipc	ra,0xffffc
    8000482c:	d20080e7          	jalr	-736(ra) # 80000548 <panic>
    return -1;
    80004830:	557d                	li	a0,-1
}
    80004832:	8082                	ret
      return -1;
    80004834:	557d                	li	a0,-1
    80004836:	bf7d                	j	800047f4 <filewrite+0x10e>
    80004838:	557d                	li	a0,-1
    8000483a:	bf6d                	j	800047f4 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    8000483c:	557d                	li	a0,-1
    8000483e:	bf5d                	j	800047f4 <filewrite+0x10e>

0000000080004840 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004840:	7179                	addi	sp,sp,-48
    80004842:	f406                	sd	ra,40(sp)
    80004844:	f022                	sd	s0,32(sp)
    80004846:	ec26                	sd	s1,24(sp)
    80004848:	e84a                	sd	s2,16(sp)
    8000484a:	e44e                	sd	s3,8(sp)
    8000484c:	e052                	sd	s4,0(sp)
    8000484e:	1800                	addi	s0,sp,48
    80004850:	84aa                	mv	s1,a0
    80004852:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004854:	0005b023          	sd	zero,0(a1)
    80004858:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000485c:	00000097          	auipc	ra,0x0
    80004860:	bd2080e7          	jalr	-1070(ra) # 8000442e <filealloc>
    80004864:	e088                	sd	a0,0(s1)
    80004866:	c551                	beqz	a0,800048f2 <pipealloc+0xb2>
    80004868:	00000097          	auipc	ra,0x0
    8000486c:	bc6080e7          	jalr	-1082(ra) # 8000442e <filealloc>
    80004870:	00aa3023          	sd	a0,0(s4)
    80004874:	c92d                	beqz	a0,800048e6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	380080e7          	jalr	896(ra) # 80000bf6 <kalloc>
    8000487e:	892a                	mv	s2,a0
    80004880:	c125                	beqz	a0,800048e0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004882:	4985                	li	s3,1
    80004884:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004888:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000488c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004890:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004894:	00004597          	auipc	a1,0x4
    80004898:	e1458593          	addi	a1,a1,-492 # 800086a8 <syscalls+0x288>
    8000489c:	ffffc097          	auipc	ra,0xffffc
    800048a0:	3ba080e7          	jalr	954(ra) # 80000c56 <initlock>
  (*f0)->type = FD_PIPE;
    800048a4:	609c                	ld	a5,0(s1)
    800048a6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048aa:	609c                	ld	a5,0(s1)
    800048ac:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048b0:	609c                	ld	a5,0(s1)
    800048b2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048b6:	609c                	ld	a5,0(s1)
    800048b8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048bc:	000a3783          	ld	a5,0(s4)
    800048c0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048c4:	000a3783          	ld	a5,0(s4)
    800048c8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048cc:	000a3783          	ld	a5,0(s4)
    800048d0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048d4:	000a3783          	ld	a5,0(s4)
    800048d8:	0127b823          	sd	s2,16(a5)
  return 0;
    800048dc:	4501                	li	a0,0
    800048de:	a025                	j	80004906 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048e0:	6088                	ld	a0,0(s1)
    800048e2:	e501                	bnez	a0,800048ea <pipealloc+0xaa>
    800048e4:	a039                	j	800048f2 <pipealloc+0xb2>
    800048e6:	6088                	ld	a0,0(s1)
    800048e8:	c51d                	beqz	a0,80004916 <pipealloc+0xd6>
    fileclose(*f0);
    800048ea:	00000097          	auipc	ra,0x0
    800048ee:	c00080e7          	jalr	-1024(ra) # 800044ea <fileclose>
  if(*f1)
    800048f2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048f6:	557d                	li	a0,-1
  if(*f1)
    800048f8:	c799                	beqz	a5,80004906 <pipealloc+0xc6>
    fileclose(*f1);
    800048fa:	853e                	mv	a0,a5
    800048fc:	00000097          	auipc	ra,0x0
    80004900:	bee080e7          	jalr	-1042(ra) # 800044ea <fileclose>
  return -1;
    80004904:	557d                	li	a0,-1
}
    80004906:	70a2                	ld	ra,40(sp)
    80004908:	7402                	ld	s0,32(sp)
    8000490a:	64e2                	ld	s1,24(sp)
    8000490c:	6942                	ld	s2,16(sp)
    8000490e:	69a2                	ld	s3,8(sp)
    80004910:	6a02                	ld	s4,0(sp)
    80004912:	6145                	addi	sp,sp,48
    80004914:	8082                	ret
  return -1;
    80004916:	557d                	li	a0,-1
    80004918:	b7fd                	j	80004906 <pipealloc+0xc6>

000000008000491a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000491a:	1101                	addi	sp,sp,-32
    8000491c:	ec06                	sd	ra,24(sp)
    8000491e:	e822                	sd	s0,16(sp)
    80004920:	e426                	sd	s1,8(sp)
    80004922:	e04a                	sd	s2,0(sp)
    80004924:	1000                	addi	s0,sp,32
    80004926:	84aa                	mv	s1,a0
    80004928:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	3bc080e7          	jalr	956(ra) # 80000ce6 <acquire>
  if(writable){
    80004932:	02090d63          	beqz	s2,8000496c <pipeclose+0x52>
    pi->writeopen = 0;
    80004936:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000493a:	21848513          	addi	a0,s1,536
    8000493e:	ffffe097          	auipc	ra,0xffffe
    80004942:	a96080e7          	jalr	-1386(ra) # 800023d4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004946:	2204b783          	ld	a5,544(s1)
    8000494a:	eb95                	bnez	a5,8000497e <pipeclose+0x64>
    release(&pi->lock);
    8000494c:	8526                	mv	a0,s1
    8000494e:	ffffc097          	auipc	ra,0xffffc
    80004952:	44c080e7          	jalr	1100(ra) # 80000d9a <release>
    kfree((char*)pi);
    80004956:	8526                	mv	a0,s1
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	1a0080e7          	jalr	416(ra) # 80000af8 <kfree>
  } else
    release(&pi->lock);
}
    80004960:	60e2                	ld	ra,24(sp)
    80004962:	6442                	ld	s0,16(sp)
    80004964:	64a2                	ld	s1,8(sp)
    80004966:	6902                	ld	s2,0(sp)
    80004968:	6105                	addi	sp,sp,32
    8000496a:	8082                	ret
    pi->readopen = 0;
    8000496c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004970:	21c48513          	addi	a0,s1,540
    80004974:	ffffe097          	auipc	ra,0xffffe
    80004978:	a60080e7          	jalr	-1440(ra) # 800023d4 <wakeup>
    8000497c:	b7e9                	j	80004946 <pipeclose+0x2c>
    release(&pi->lock);
    8000497e:	8526                	mv	a0,s1
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	41a080e7          	jalr	1050(ra) # 80000d9a <release>
}
    80004988:	bfe1                	j	80004960 <pipeclose+0x46>

000000008000498a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000498a:	711d                	addi	sp,sp,-96
    8000498c:	ec86                	sd	ra,88(sp)
    8000498e:	e8a2                	sd	s0,80(sp)
    80004990:	e4a6                	sd	s1,72(sp)
    80004992:	e0ca                	sd	s2,64(sp)
    80004994:	fc4e                	sd	s3,56(sp)
    80004996:	f852                	sd	s4,48(sp)
    80004998:	f456                	sd	s5,40(sp)
    8000499a:	f05a                	sd	s6,32(sp)
    8000499c:	ec5e                	sd	s7,24(sp)
    8000499e:	1080                	addi	s0,sp,96
    800049a0:	84aa                	mv	s1,a0
    800049a2:	8b2e                	mv	s6,a1
    800049a4:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    800049a6:	ffffd097          	auipc	ra,0xffffd
    800049aa:	098080e7          	jalr	152(ra) # 80001a3e <myproc>
    800049ae:	892a                	mv	s2,a0

  acquire(&pi->lock);
    800049b0:	8526                	mv	a0,s1
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	334080e7          	jalr	820(ra) # 80000ce6 <acquire>
  for(i = 0; i < n; i++){
    800049ba:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    800049bc:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049c0:	21c48993          	addi	s3,s1,540
  for(i = 0; i < n; i++){
    800049c4:	09505263          	blez	s5,80004a48 <pipewrite+0xbe>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800049c8:	2184a783          	lw	a5,536(s1)
    800049cc:	21c4a703          	lw	a4,540(s1)
    800049d0:	2007879b          	addiw	a5,a5,512
    800049d4:	02f71b63          	bne	a4,a5,80004a0a <pipewrite+0x80>
      if(pi->readopen == 0 || pr->killed){
    800049d8:	2204a783          	lw	a5,544(s1)
    800049dc:	c3d1                	beqz	a5,80004a60 <pipewrite+0xd6>
    800049de:	03092783          	lw	a5,48(s2)
    800049e2:	efbd                	bnez	a5,80004a60 <pipewrite+0xd6>
      wakeup(&pi->nread);
    800049e4:	8552                	mv	a0,s4
    800049e6:	ffffe097          	auipc	ra,0xffffe
    800049ea:	9ee080e7          	jalr	-1554(ra) # 800023d4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049ee:	85a6                	mv	a1,s1
    800049f0:	854e                	mv	a0,s3
    800049f2:	ffffe097          	auipc	ra,0xffffe
    800049f6:	862080e7          	jalr	-1950(ra) # 80002254 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800049fa:	2184a783          	lw	a5,536(s1)
    800049fe:	21c4a703          	lw	a4,540(s1)
    80004a02:	2007879b          	addiw	a5,a5,512
    80004a06:	fcf709e3          	beq	a4,a5,800049d8 <pipewrite+0x4e>
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a0a:	4685                	li	a3,1
    80004a0c:	865a                	mv	a2,s6
    80004a0e:	faf40593          	addi	a1,s0,-81
    80004a12:	05093503          	ld	a0,80(s2)
    80004a16:	ffffd097          	auipc	ra,0xffffd
    80004a1a:	daa080e7          	jalr	-598(ra) # 800017c0 <copyin>
    80004a1e:	57fd                	li	a5,-1
    80004a20:	02f50463          	beq	a0,a5,80004a48 <pipewrite+0xbe>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a24:	21c4a783          	lw	a5,540(s1)
    80004a28:	0017871b          	addiw	a4,a5,1
    80004a2c:	20e4ae23          	sw	a4,540(s1)
    80004a30:	1ff7f793          	andi	a5,a5,511
    80004a34:	97a6                	add	a5,a5,s1
    80004a36:	faf44703          	lbu	a4,-81(s0)
    80004a3a:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004a3e:	2b85                	addiw	s7,s7,1
    80004a40:	0b05                	addi	s6,s6,1
    80004a42:	f97a93e3          	bne	s5,s7,800049c8 <pipewrite+0x3e>
    80004a46:	8bd6                	mv	s7,s5
  }
  wakeup(&pi->nread);
    80004a48:	21848513          	addi	a0,s1,536
    80004a4c:	ffffe097          	auipc	ra,0xffffe
    80004a50:	988080e7          	jalr	-1656(ra) # 800023d4 <wakeup>
  release(&pi->lock);
    80004a54:	8526                	mv	a0,s1
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	344080e7          	jalr	836(ra) # 80000d9a <release>
  return i;
    80004a5e:	a039                	j	80004a6c <pipewrite+0xe2>
        release(&pi->lock);
    80004a60:	8526                	mv	a0,s1
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	338080e7          	jalr	824(ra) # 80000d9a <release>
        return -1;
    80004a6a:	5bfd                	li	s7,-1
}
    80004a6c:	855e                	mv	a0,s7
    80004a6e:	60e6                	ld	ra,88(sp)
    80004a70:	6446                	ld	s0,80(sp)
    80004a72:	64a6                	ld	s1,72(sp)
    80004a74:	6906                	ld	s2,64(sp)
    80004a76:	79e2                	ld	s3,56(sp)
    80004a78:	7a42                	ld	s4,48(sp)
    80004a7a:	7aa2                	ld	s5,40(sp)
    80004a7c:	7b02                	ld	s6,32(sp)
    80004a7e:	6be2                	ld	s7,24(sp)
    80004a80:	6125                	addi	sp,sp,96
    80004a82:	8082                	ret

0000000080004a84 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a84:	715d                	addi	sp,sp,-80
    80004a86:	e486                	sd	ra,72(sp)
    80004a88:	e0a2                	sd	s0,64(sp)
    80004a8a:	fc26                	sd	s1,56(sp)
    80004a8c:	f84a                	sd	s2,48(sp)
    80004a8e:	f44e                	sd	s3,40(sp)
    80004a90:	f052                	sd	s4,32(sp)
    80004a92:	ec56                	sd	s5,24(sp)
    80004a94:	e85a                	sd	s6,16(sp)
    80004a96:	0880                	addi	s0,sp,80
    80004a98:	84aa                	mv	s1,a0
    80004a9a:	892e                	mv	s2,a1
    80004a9c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a9e:	ffffd097          	auipc	ra,0xffffd
    80004aa2:	fa0080e7          	jalr	-96(ra) # 80001a3e <myproc>
    80004aa6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	23c080e7          	jalr	572(ra) # 80000ce6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ab2:	2184a703          	lw	a4,536(s1)
    80004ab6:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004aba:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004abe:	02f71463          	bne	a4,a5,80004ae6 <piperead+0x62>
    80004ac2:	2244a783          	lw	a5,548(s1)
    80004ac6:	c385                	beqz	a5,80004ae6 <piperead+0x62>
    if(pr->killed){
    80004ac8:	030a2783          	lw	a5,48(s4)
    80004acc:	ebc9                	bnez	a5,80004b5e <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ace:	85a6                	mv	a1,s1
    80004ad0:	854e                	mv	a0,s3
    80004ad2:	ffffd097          	auipc	ra,0xffffd
    80004ad6:	782080e7          	jalr	1922(ra) # 80002254 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ada:	2184a703          	lw	a4,536(s1)
    80004ade:	21c4a783          	lw	a5,540(s1)
    80004ae2:	fef700e3          	beq	a4,a5,80004ac2 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ae6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ae8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aea:	05505463          	blez	s5,80004b32 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004aee:	2184a783          	lw	a5,536(s1)
    80004af2:	21c4a703          	lw	a4,540(s1)
    80004af6:	02f70e63          	beq	a4,a5,80004b32 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004afa:	0017871b          	addiw	a4,a5,1
    80004afe:	20e4ac23          	sw	a4,536(s1)
    80004b02:	1ff7f793          	andi	a5,a5,511
    80004b06:	97a6                	add	a5,a5,s1
    80004b08:	0187c783          	lbu	a5,24(a5)
    80004b0c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b10:	4685                	li	a3,1
    80004b12:	fbf40613          	addi	a2,s0,-65
    80004b16:	85ca                	mv	a1,s2
    80004b18:	050a3503          	ld	a0,80(s4)
    80004b1c:	ffffd097          	auipc	ra,0xffffd
    80004b20:	c18080e7          	jalr	-1000(ra) # 80001734 <copyout>
    80004b24:	01650763          	beq	a0,s6,80004b32 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b28:	2985                	addiw	s3,s3,1
    80004b2a:	0905                	addi	s2,s2,1
    80004b2c:	fd3a91e3          	bne	s5,s3,80004aee <piperead+0x6a>
    80004b30:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b32:	21c48513          	addi	a0,s1,540
    80004b36:	ffffe097          	auipc	ra,0xffffe
    80004b3a:	89e080e7          	jalr	-1890(ra) # 800023d4 <wakeup>
  release(&pi->lock);
    80004b3e:	8526                	mv	a0,s1
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	25a080e7          	jalr	602(ra) # 80000d9a <release>
  return i;
}
    80004b48:	854e                	mv	a0,s3
    80004b4a:	60a6                	ld	ra,72(sp)
    80004b4c:	6406                	ld	s0,64(sp)
    80004b4e:	74e2                	ld	s1,56(sp)
    80004b50:	7942                	ld	s2,48(sp)
    80004b52:	79a2                	ld	s3,40(sp)
    80004b54:	7a02                	ld	s4,32(sp)
    80004b56:	6ae2                	ld	s5,24(sp)
    80004b58:	6b42                	ld	s6,16(sp)
    80004b5a:	6161                	addi	sp,sp,80
    80004b5c:	8082                	ret
      release(&pi->lock);
    80004b5e:	8526                	mv	a0,s1
    80004b60:	ffffc097          	auipc	ra,0xffffc
    80004b64:	23a080e7          	jalr	570(ra) # 80000d9a <release>
      return -1;
    80004b68:	59fd                	li	s3,-1
    80004b6a:	bff9                	j	80004b48 <piperead+0xc4>

0000000080004b6c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004b6c:	df010113          	addi	sp,sp,-528
    80004b70:	20113423          	sd	ra,520(sp)
    80004b74:	20813023          	sd	s0,512(sp)
    80004b78:	ffa6                	sd	s1,504(sp)
    80004b7a:	fbca                	sd	s2,496(sp)
    80004b7c:	f7ce                	sd	s3,488(sp)
    80004b7e:	f3d2                	sd	s4,480(sp)
    80004b80:	efd6                	sd	s5,472(sp)
    80004b82:	ebda                	sd	s6,464(sp)
    80004b84:	e7de                	sd	s7,456(sp)
    80004b86:	e3e2                	sd	s8,448(sp)
    80004b88:	ff66                	sd	s9,440(sp)
    80004b8a:	fb6a                	sd	s10,432(sp)
    80004b8c:	f76e                	sd	s11,424(sp)
    80004b8e:	0c00                	addi	s0,sp,528
    80004b90:	892a                	mv	s2,a0
    80004b92:	dea43c23          	sd	a0,-520(s0)
    80004b96:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b9a:	ffffd097          	auipc	ra,0xffffd
    80004b9e:	ea4080e7          	jalr	-348(ra) # 80001a3e <myproc>
    80004ba2:	84aa                	mv	s1,a0

  begin_op();
    80004ba4:	fffff097          	auipc	ra,0xfffff
    80004ba8:	47a080e7          	jalr	1146(ra) # 8000401e <begin_op>

  if((ip = namei(path)) == 0){
    80004bac:	854a                	mv	a0,s2
    80004bae:	fffff097          	auipc	ra,0xfffff
    80004bb2:	270080e7          	jalr	624(ra) # 80003e1e <namei>
    80004bb6:	c92d                	beqz	a0,80004c28 <exec+0xbc>
    80004bb8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bba:	fffff097          	auipc	ra,0xfffff
    80004bbe:	ab0080e7          	jalr	-1360(ra) # 8000366a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bc2:	04000713          	li	a4,64
    80004bc6:	4681                	li	a3,0
    80004bc8:	e4840613          	addi	a2,s0,-440
    80004bcc:	4581                	li	a1,0
    80004bce:	8552                	mv	a0,s4
    80004bd0:	fffff097          	auipc	ra,0xfffff
    80004bd4:	d4e080e7          	jalr	-690(ra) # 8000391e <readi>
    80004bd8:	04000793          	li	a5,64
    80004bdc:	00f51a63          	bne	a0,a5,80004bf0 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004be0:	e4842703          	lw	a4,-440(s0)
    80004be4:	464c47b7          	lui	a5,0x464c4
    80004be8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004bec:	04f70463          	beq	a4,a5,80004c34 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bf0:	8552                	mv	a0,s4
    80004bf2:	fffff097          	auipc	ra,0xfffff
    80004bf6:	cda080e7          	jalr	-806(ra) # 800038cc <iunlockput>
    end_op();
    80004bfa:	fffff097          	auipc	ra,0xfffff
    80004bfe:	49e080e7          	jalr	1182(ra) # 80004098 <end_op>
  }
  return -1;
    80004c02:	557d                	li	a0,-1
}
    80004c04:	20813083          	ld	ra,520(sp)
    80004c08:	20013403          	ld	s0,512(sp)
    80004c0c:	74fe                	ld	s1,504(sp)
    80004c0e:	795e                	ld	s2,496(sp)
    80004c10:	79be                	ld	s3,488(sp)
    80004c12:	7a1e                	ld	s4,480(sp)
    80004c14:	6afe                	ld	s5,472(sp)
    80004c16:	6b5e                	ld	s6,464(sp)
    80004c18:	6bbe                	ld	s7,456(sp)
    80004c1a:	6c1e                	ld	s8,448(sp)
    80004c1c:	7cfa                	ld	s9,440(sp)
    80004c1e:	7d5a                	ld	s10,432(sp)
    80004c20:	7dba                	ld	s11,424(sp)
    80004c22:	21010113          	addi	sp,sp,528
    80004c26:	8082                	ret
    end_op();
    80004c28:	fffff097          	auipc	ra,0xfffff
    80004c2c:	470080e7          	jalr	1136(ra) # 80004098 <end_op>
    return -1;
    80004c30:	557d                	li	a0,-1
    80004c32:	bfc9                	j	80004c04 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c34:	8526                	mv	a0,s1
    80004c36:	ffffd097          	auipc	ra,0xffffd
    80004c3a:	ecc080e7          	jalr	-308(ra) # 80001b02 <proc_pagetable>
    80004c3e:	8b2a                	mv	s6,a0
    80004c40:	d945                	beqz	a0,80004bf0 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c42:	e6842d03          	lw	s10,-408(s0)
    80004c46:	e8045783          	lhu	a5,-384(s0)
    80004c4a:	cfe5                	beqz	a5,80004d42 <exec+0x1d6>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c4c:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c4e:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004c50:	6c85                	lui	s9,0x1
    80004c52:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c56:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004c5a:	6a85                	lui	s5,0x1
    80004c5c:	a0b5                	j	80004cc8 <exec+0x15c>
      panic("loadseg: address should exist");
    80004c5e:	00004517          	auipc	a0,0x4
    80004c62:	a5250513          	addi	a0,a0,-1454 # 800086b0 <syscalls+0x290>
    80004c66:	ffffc097          	auipc	ra,0xffffc
    80004c6a:	8e2080e7          	jalr	-1822(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
    80004c6e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c70:	8726                	mv	a4,s1
    80004c72:	012c06bb          	addw	a3,s8,s2
    80004c76:	4581                	li	a1,0
    80004c78:	8552                	mv	a0,s4
    80004c7a:	fffff097          	auipc	ra,0xfffff
    80004c7e:	ca4080e7          	jalr	-860(ra) # 8000391e <readi>
    80004c82:	2501                	sext.w	a0,a0
    80004c84:	24a49063          	bne	s1,a0,80004ec4 <exec+0x358>
  for(i = 0; i < sz; i += PGSIZE){
    80004c88:	012a893b          	addw	s2,s5,s2
    80004c8c:	03397563          	bgeu	s2,s3,80004cb6 <exec+0x14a>
    pa = walkaddr(pagetable, va + i);
    80004c90:	02091593          	slli	a1,s2,0x20
    80004c94:	9181                	srli	a1,a1,0x20
    80004c96:	95de                	add	a1,a1,s7
    80004c98:	855a                	mv	a0,s6
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	4d4080e7          	jalr	1236(ra) # 8000116e <walkaddr>
    80004ca2:	862a                	mv	a2,a0
    if(pa == 0)
    80004ca4:	dd4d                	beqz	a0,80004c5e <exec+0xf2>
    if(sz - i < PGSIZE)
    80004ca6:	412984bb          	subw	s1,s3,s2
    80004caa:	0004879b          	sext.w	a5,s1
    80004cae:	fcfcf0e3          	bgeu	s9,a5,80004c6e <exec+0x102>
    80004cb2:	84d6                	mv	s1,s5
    80004cb4:	bf6d                	j	80004c6e <exec+0x102>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004cb6:	e0843483          	ld	s1,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cba:	2d85                	addiw	s11,s11,1
    80004cbc:	038d0d1b          	addiw	s10,s10,56
    80004cc0:	e8045783          	lhu	a5,-384(s0)
    80004cc4:	08fdd063          	bge	s11,a5,80004d44 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004cc8:	2d01                	sext.w	s10,s10
    80004cca:	03800713          	li	a4,56
    80004cce:	86ea                	mv	a3,s10
    80004cd0:	e1040613          	addi	a2,s0,-496
    80004cd4:	4581                	li	a1,0
    80004cd6:	8552                	mv	a0,s4
    80004cd8:	fffff097          	auipc	ra,0xfffff
    80004cdc:	c46080e7          	jalr	-954(ra) # 8000391e <readi>
    80004ce0:	03800793          	li	a5,56
    80004ce4:	1cf51e63          	bne	a0,a5,80004ec0 <exec+0x354>
    if(ph.type != ELF_PROG_LOAD)
    80004ce8:	e1042783          	lw	a5,-496(s0)
    80004cec:	4705                	li	a4,1
    80004cee:	fce796e3          	bne	a5,a4,80004cba <exec+0x14e>
    if(ph.memsz < ph.filesz)
    80004cf2:	e3843603          	ld	a2,-456(s0)
    80004cf6:	e3043783          	ld	a5,-464(s0)
    80004cfa:	1ef66063          	bltu	a2,a5,80004eda <exec+0x36e>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004cfe:	e2043783          	ld	a5,-480(s0)
    80004d02:	963e                	add	a2,a2,a5
    80004d04:	1cf66e63          	bltu	a2,a5,80004ee0 <exec+0x374>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004d08:	85a6                	mv	a1,s1
    80004d0a:	855a                	mv	a0,s6
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	7d4080e7          	jalr	2004(ra) # 800014e0 <uvmalloc>
    80004d14:	e0a43423          	sd	a0,-504(s0)
    80004d18:	1c050763          	beqz	a0,80004ee6 <exec+0x37a>
    if(ph.vaddr % PGSIZE != 0)
    80004d1c:	e2043b83          	ld	s7,-480(s0)
    80004d20:	df043783          	ld	a5,-528(s0)
    80004d24:	00fbf7b3          	and	a5,s7,a5
    80004d28:	18079e63          	bnez	a5,80004ec4 <exec+0x358>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d2c:	e1842c03          	lw	s8,-488(s0)
    80004d30:	e3042983          	lw	s3,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d34:	00098463          	beqz	s3,80004d3c <exec+0x1d0>
    80004d38:	4901                	li	s2,0
    80004d3a:	bf99                	j	80004c90 <exec+0x124>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004d3c:	e0843483          	ld	s1,-504(s0)
    80004d40:	bfad                	j	80004cba <exec+0x14e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d42:	4481                	li	s1,0
  iunlockput(ip);
    80004d44:	8552                	mv	a0,s4
    80004d46:	fffff097          	auipc	ra,0xfffff
    80004d4a:	b86080e7          	jalr	-1146(ra) # 800038cc <iunlockput>
  end_op();
    80004d4e:	fffff097          	auipc	ra,0xfffff
    80004d52:	34a080e7          	jalr	842(ra) # 80004098 <end_op>
  p = myproc();
    80004d56:	ffffd097          	auipc	ra,0xffffd
    80004d5a:	ce8080e7          	jalr	-792(ra) # 80001a3e <myproc>
    80004d5e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d60:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004d64:	6985                	lui	s3,0x1
    80004d66:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004d68:	99a6                	add	s3,s3,s1
    80004d6a:	77fd                	lui	a5,0xfffff
    80004d6c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d70:	6609                	lui	a2,0x2
    80004d72:	964e                	add	a2,a2,s3
    80004d74:	85ce                	mv	a1,s3
    80004d76:	855a                	mv	a0,s6
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	768080e7          	jalr	1896(ra) # 800014e0 <uvmalloc>
    80004d80:	892a                	mv	s2,a0
    80004d82:	e0a43423          	sd	a0,-504(s0)
    80004d86:	e509                	bnez	a0,80004d90 <exec+0x224>
  if(pagetable)
    80004d88:	e1343423          	sd	s3,-504(s0)
    80004d8c:	4a01                	li	s4,0
    80004d8e:	aa1d                	j	80004ec4 <exec+0x358>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d90:	75f9                	lui	a1,0xffffe
    80004d92:	95aa                	add	a1,a1,a0
    80004d94:	855a                	mv	a0,s6
    80004d96:	ffffd097          	auipc	ra,0xffffd
    80004d9a:	96c080e7          	jalr	-1684(ra) # 80001702 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d9e:	7bfd                	lui	s7,0xfffff
    80004da0:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004da2:	e0043783          	ld	a5,-512(s0)
    80004da6:	6388                	ld	a0,0(a5)
    80004da8:	c52d                	beqz	a0,80004e12 <exec+0x2a6>
    80004daa:	e8840993          	addi	s3,s0,-376
    80004dae:	f8840c13          	addi	s8,s0,-120
    80004db2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004db4:	ffffc097          	auipc	ra,0xffffc
    80004db8:	1b0080e7          	jalr	432(ra) # 80000f64 <strlen>
    80004dbc:	0015079b          	addiw	a5,a0,1
    80004dc0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dc4:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004dc8:	13796263          	bltu	s2,s7,80004eec <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dcc:	e0043d03          	ld	s10,-512(s0)
    80004dd0:	000d3a03          	ld	s4,0(s10)
    80004dd4:	8552                	mv	a0,s4
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	18e080e7          	jalr	398(ra) # 80000f64 <strlen>
    80004dde:	0015069b          	addiw	a3,a0,1
    80004de2:	8652                	mv	a2,s4
    80004de4:	85ca                	mv	a1,s2
    80004de6:	855a                	mv	a0,s6
    80004de8:	ffffd097          	auipc	ra,0xffffd
    80004dec:	94c080e7          	jalr	-1716(ra) # 80001734 <copyout>
    80004df0:	10054063          	bltz	a0,80004ef0 <exec+0x384>
    ustack[argc] = sp;
    80004df4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004df8:	0485                	addi	s1,s1,1
    80004dfa:	008d0793          	addi	a5,s10,8
    80004dfe:	e0f43023          	sd	a5,-512(s0)
    80004e02:	008d3503          	ld	a0,8(s10)
    80004e06:	c909                	beqz	a0,80004e18 <exec+0x2ac>
    if(argc >= MAXARG)
    80004e08:	09a1                	addi	s3,s3,8
    80004e0a:	fb8995e3          	bne	s3,s8,80004db4 <exec+0x248>
  ip = 0;
    80004e0e:	4a01                	li	s4,0
    80004e10:	a855                	j	80004ec4 <exec+0x358>
  sp = sz;
    80004e12:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004e16:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e18:	00349793          	slli	a5,s1,0x3
    80004e1c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd8f90>
    80004e20:	97a2                	add	a5,a5,s0
    80004e22:	ee07bc23          	sd	zero,-264(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e26:	00148693          	addi	a3,s1,1
    80004e2a:	068e                	slli	a3,a3,0x3
    80004e2c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e30:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004e34:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004e38:	f57968e3          	bltu	s2,s7,80004d88 <exec+0x21c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e3c:	e8840613          	addi	a2,s0,-376
    80004e40:	85ca                	mv	a1,s2
    80004e42:	855a                	mv	a0,s6
    80004e44:	ffffd097          	auipc	ra,0xffffd
    80004e48:	8f0080e7          	jalr	-1808(ra) # 80001734 <copyout>
    80004e4c:	0a054463          	bltz	a0,80004ef4 <exec+0x388>
  p->trapframe->a1 = sp;
    80004e50:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004e54:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e58:	df843783          	ld	a5,-520(s0)
    80004e5c:	0007c703          	lbu	a4,0(a5)
    80004e60:	cf11                	beqz	a4,80004e7c <exec+0x310>
    80004e62:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e64:	02f00693          	li	a3,47
    80004e68:	a039                	j	80004e76 <exec+0x30a>
      last = s+1;
    80004e6a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004e6e:	0785                	addi	a5,a5,1
    80004e70:	fff7c703          	lbu	a4,-1(a5)
    80004e74:	c701                	beqz	a4,80004e7c <exec+0x310>
    if(*s == '/')
    80004e76:	fed71ce3          	bne	a4,a3,80004e6e <exec+0x302>
    80004e7a:	bfc5                	j	80004e6a <exec+0x2fe>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e7c:	4641                	li	a2,16
    80004e7e:	df843583          	ld	a1,-520(s0)
    80004e82:	158a8513          	addi	a0,s5,344
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	0ac080e7          	jalr	172(ra) # 80000f32 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e8e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004e92:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004e96:	e0843783          	ld	a5,-504(s0)
    80004e9a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e9e:	058ab783          	ld	a5,88(s5)
    80004ea2:	e6043703          	ld	a4,-416(s0)
    80004ea6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ea8:	058ab783          	ld	a5,88(s5)
    80004eac:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eb0:	85e6                	mv	a1,s9
    80004eb2:	ffffd097          	auipc	ra,0xffffd
    80004eb6:	cec080e7          	jalr	-788(ra) # 80001b9e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004eba:	0004851b          	sext.w	a0,s1
    80004ebe:	b399                	j	80004c04 <exec+0x98>
    80004ec0:	e0943423          	sd	s1,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004ec4:	e0843583          	ld	a1,-504(s0)
    80004ec8:	855a                	mv	a0,s6
    80004eca:	ffffd097          	auipc	ra,0xffffd
    80004ece:	cd4080e7          	jalr	-812(ra) # 80001b9e <proc_freepagetable>
  return -1;
    80004ed2:	557d                	li	a0,-1
  if(ip){
    80004ed4:	d20a08e3          	beqz	s4,80004c04 <exec+0x98>
    80004ed8:	bb21                	j	80004bf0 <exec+0x84>
    80004eda:	e0943423          	sd	s1,-504(s0)
    80004ede:	b7dd                	j	80004ec4 <exec+0x358>
    80004ee0:	e0943423          	sd	s1,-504(s0)
    80004ee4:	b7c5                	j	80004ec4 <exec+0x358>
    80004ee6:	e0943423          	sd	s1,-504(s0)
    80004eea:	bfe9                	j	80004ec4 <exec+0x358>
  ip = 0;
    80004eec:	4a01                	li	s4,0
    80004eee:	bfd9                	j	80004ec4 <exec+0x358>
    80004ef0:	4a01                	li	s4,0
  if(pagetable)
    80004ef2:	bfc9                	j	80004ec4 <exec+0x358>
  sz = sz1;
    80004ef4:	e0843983          	ld	s3,-504(s0)
    80004ef8:	bd41                	j	80004d88 <exec+0x21c>

0000000080004efa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004efa:	7179                	addi	sp,sp,-48
    80004efc:	f406                	sd	ra,40(sp)
    80004efe:	f022                	sd	s0,32(sp)
    80004f00:	ec26                	sd	s1,24(sp)
    80004f02:	e84a                	sd	s2,16(sp)
    80004f04:	1800                	addi	s0,sp,48
    80004f06:	892e                	mv	s2,a1
    80004f08:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f0a:	fdc40593          	addi	a1,s0,-36
    80004f0e:	ffffe097          	auipc	ra,0xffffe
    80004f12:	bf2080e7          	jalr	-1038(ra) # 80002b00 <argint>
    80004f16:	04054063          	bltz	a0,80004f56 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f1a:	fdc42703          	lw	a4,-36(s0)
    80004f1e:	47bd                	li	a5,15
    80004f20:	02e7ed63          	bltu	a5,a4,80004f5a <argfd+0x60>
    80004f24:	ffffd097          	auipc	ra,0xffffd
    80004f28:	b1a080e7          	jalr	-1254(ra) # 80001a3e <myproc>
    80004f2c:	fdc42703          	lw	a4,-36(s0)
    80004f30:	01a70793          	addi	a5,a4,26
    80004f34:	078e                	slli	a5,a5,0x3
    80004f36:	953e                	add	a0,a0,a5
    80004f38:	611c                	ld	a5,0(a0)
    80004f3a:	c395                	beqz	a5,80004f5e <argfd+0x64>
    return -1;
  if(pfd)
    80004f3c:	00090463          	beqz	s2,80004f44 <argfd+0x4a>
    *pfd = fd;
    80004f40:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f44:	4501                	li	a0,0
  if(pf)
    80004f46:	c091                	beqz	s1,80004f4a <argfd+0x50>
    *pf = f;
    80004f48:	e09c                	sd	a5,0(s1)
}
    80004f4a:	70a2                	ld	ra,40(sp)
    80004f4c:	7402                	ld	s0,32(sp)
    80004f4e:	64e2                	ld	s1,24(sp)
    80004f50:	6942                	ld	s2,16(sp)
    80004f52:	6145                	addi	sp,sp,48
    80004f54:	8082                	ret
    return -1;
    80004f56:	557d                	li	a0,-1
    80004f58:	bfcd                	j	80004f4a <argfd+0x50>
    return -1;
    80004f5a:	557d                	li	a0,-1
    80004f5c:	b7fd                	j	80004f4a <argfd+0x50>
    80004f5e:	557d                	li	a0,-1
    80004f60:	b7ed                	j	80004f4a <argfd+0x50>

0000000080004f62 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f62:	1101                	addi	sp,sp,-32
    80004f64:	ec06                	sd	ra,24(sp)
    80004f66:	e822                	sd	s0,16(sp)
    80004f68:	e426                	sd	s1,8(sp)
    80004f6a:	1000                	addi	s0,sp,32
    80004f6c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f6e:	ffffd097          	auipc	ra,0xffffd
    80004f72:	ad0080e7          	jalr	-1328(ra) # 80001a3e <myproc>
    80004f76:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f78:	0d050793          	addi	a5,a0,208
    80004f7c:	4501                	li	a0,0
    80004f7e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f80:	6398                	ld	a4,0(a5)
    80004f82:	cb19                	beqz	a4,80004f98 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f84:	2505                	addiw	a0,a0,1
    80004f86:	07a1                	addi	a5,a5,8
    80004f88:	fed51ce3          	bne	a0,a3,80004f80 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f8c:	557d                	li	a0,-1
}
    80004f8e:	60e2                	ld	ra,24(sp)
    80004f90:	6442                	ld	s0,16(sp)
    80004f92:	64a2                	ld	s1,8(sp)
    80004f94:	6105                	addi	sp,sp,32
    80004f96:	8082                	ret
      p->ofile[fd] = f;
    80004f98:	01a50793          	addi	a5,a0,26
    80004f9c:	078e                	slli	a5,a5,0x3
    80004f9e:	963e                	add	a2,a2,a5
    80004fa0:	e204                	sd	s1,0(a2)
      return fd;
    80004fa2:	b7f5                	j	80004f8e <fdalloc+0x2c>

0000000080004fa4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fa4:	715d                	addi	sp,sp,-80
    80004fa6:	e486                	sd	ra,72(sp)
    80004fa8:	e0a2                	sd	s0,64(sp)
    80004faa:	fc26                	sd	s1,56(sp)
    80004fac:	f84a                	sd	s2,48(sp)
    80004fae:	f44e                	sd	s3,40(sp)
    80004fb0:	f052                	sd	s4,32(sp)
    80004fb2:	ec56                	sd	s5,24(sp)
    80004fb4:	0880                	addi	s0,sp,80
    80004fb6:	8aae                	mv	s5,a1
    80004fb8:	8a32                	mv	s4,a2
    80004fba:	89b6                	mv	s3,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fbc:	fb040593          	addi	a1,s0,-80
    80004fc0:	fffff097          	auipc	ra,0xfffff
    80004fc4:	e7c080e7          	jalr	-388(ra) # 80003e3c <nameiparent>
    80004fc8:	892a                	mv	s2,a0
    80004fca:	12050c63          	beqz	a0,80005102 <create+0x15e>
    return 0;

  ilock(dp);
    80004fce:	ffffe097          	auipc	ra,0xffffe
    80004fd2:	69c080e7          	jalr	1692(ra) # 8000366a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fd6:	4601                	li	a2,0
    80004fd8:	fb040593          	addi	a1,s0,-80
    80004fdc:	854a                	mv	a0,s2
    80004fde:	fffff097          	auipc	ra,0xfffff
    80004fe2:	b6e080e7          	jalr	-1170(ra) # 80003b4c <dirlookup>
    80004fe6:	84aa                	mv	s1,a0
    80004fe8:	c539                	beqz	a0,80005036 <create+0x92>
    iunlockput(dp);
    80004fea:	854a                	mv	a0,s2
    80004fec:	fffff097          	auipc	ra,0xfffff
    80004ff0:	8e0080e7          	jalr	-1824(ra) # 800038cc <iunlockput>
    ilock(ip);
    80004ff4:	8526                	mv	a0,s1
    80004ff6:	ffffe097          	auipc	ra,0xffffe
    80004ffa:	674080e7          	jalr	1652(ra) # 8000366a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ffe:	4789                	li	a5,2
    80005000:	02fa9463          	bne	s5,a5,80005028 <create+0x84>
    80005004:	0444d783          	lhu	a5,68(s1)
    80005008:	37f9                	addiw	a5,a5,-2
    8000500a:	17c2                	slli	a5,a5,0x30
    8000500c:	93c1                	srli	a5,a5,0x30
    8000500e:	4705                	li	a4,1
    80005010:	00f76c63          	bltu	a4,a5,80005028 <create+0x84>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005014:	8526                	mv	a0,s1
    80005016:	60a6                	ld	ra,72(sp)
    80005018:	6406                	ld	s0,64(sp)
    8000501a:	74e2                	ld	s1,56(sp)
    8000501c:	7942                	ld	s2,48(sp)
    8000501e:	79a2                	ld	s3,40(sp)
    80005020:	7a02                	ld	s4,32(sp)
    80005022:	6ae2                	ld	s5,24(sp)
    80005024:	6161                	addi	sp,sp,80
    80005026:	8082                	ret
    iunlockput(ip);
    80005028:	8526                	mv	a0,s1
    8000502a:	fffff097          	auipc	ra,0xfffff
    8000502e:	8a2080e7          	jalr	-1886(ra) # 800038cc <iunlockput>
    return 0;
    80005032:	4481                	li	s1,0
    80005034:	b7c5                	j	80005014 <create+0x70>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005036:	85d6                	mv	a1,s5
    80005038:	00092503          	lw	a0,0(s2)
    8000503c:	ffffe097          	auipc	ra,0xffffe
    80005040:	49a080e7          	jalr	1178(ra) # 800034d6 <ialloc>
    80005044:	84aa                	mv	s1,a0
    80005046:	c139                	beqz	a0,8000508c <create+0xe8>
  ilock(ip);
    80005048:	ffffe097          	auipc	ra,0xffffe
    8000504c:	622080e7          	jalr	1570(ra) # 8000366a <ilock>
  ip->major = major;
    80005050:	05449323          	sh	s4,70(s1)
  ip->minor = minor;
    80005054:	05349423          	sh	s3,72(s1)
  ip->nlink = 1;
    80005058:	4985                	li	s3,1
    8000505a:	05349523          	sh	s3,74(s1)
  iupdate(ip);
    8000505e:	8526                	mv	a0,s1
    80005060:	ffffe097          	auipc	ra,0xffffe
    80005064:	53e080e7          	jalr	1342(ra) # 8000359e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005068:	033a8a63          	beq	s5,s3,8000509c <create+0xf8>
  if(dirlink(dp, name, ip->inum) < 0)
    8000506c:	40d0                	lw	a2,4(s1)
    8000506e:	fb040593          	addi	a1,s0,-80
    80005072:	854a                	mv	a0,s2
    80005074:	fffff097          	auipc	ra,0xfffff
    80005078:	ce8080e7          	jalr	-792(ra) # 80003d5c <dirlink>
    8000507c:	06054b63          	bltz	a0,800050f2 <create+0x14e>
  iunlockput(dp);
    80005080:	854a                	mv	a0,s2
    80005082:	fffff097          	auipc	ra,0xfffff
    80005086:	84a080e7          	jalr	-1974(ra) # 800038cc <iunlockput>
  return ip;
    8000508a:	b769                	j	80005014 <create+0x70>
    panic("create: ialloc");
    8000508c:	00003517          	auipc	a0,0x3
    80005090:	64450513          	addi	a0,a0,1604 # 800086d0 <syscalls+0x2b0>
    80005094:	ffffb097          	auipc	ra,0xffffb
    80005098:	4b4080e7          	jalr	1204(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    8000509c:	04a95783          	lhu	a5,74(s2)
    800050a0:	2785                	addiw	a5,a5,1
    800050a2:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800050a6:	854a                	mv	a0,s2
    800050a8:	ffffe097          	auipc	ra,0xffffe
    800050ac:	4f6080e7          	jalr	1270(ra) # 8000359e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050b0:	40d0                	lw	a2,4(s1)
    800050b2:	00003597          	auipc	a1,0x3
    800050b6:	62e58593          	addi	a1,a1,1582 # 800086e0 <syscalls+0x2c0>
    800050ba:	8526                	mv	a0,s1
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	ca0080e7          	jalr	-864(ra) # 80003d5c <dirlink>
    800050c4:	00054f63          	bltz	a0,800050e2 <create+0x13e>
    800050c8:	00492603          	lw	a2,4(s2)
    800050cc:	00003597          	auipc	a1,0x3
    800050d0:	61c58593          	addi	a1,a1,1564 # 800086e8 <syscalls+0x2c8>
    800050d4:	8526                	mv	a0,s1
    800050d6:	fffff097          	auipc	ra,0xfffff
    800050da:	c86080e7          	jalr	-890(ra) # 80003d5c <dirlink>
    800050de:	f80557e3          	bgez	a0,8000506c <create+0xc8>
      panic("create dots");
    800050e2:	00003517          	auipc	a0,0x3
    800050e6:	60e50513          	addi	a0,a0,1550 # 800086f0 <syscalls+0x2d0>
    800050ea:	ffffb097          	auipc	ra,0xffffb
    800050ee:	45e080e7          	jalr	1118(ra) # 80000548 <panic>
    panic("create: dirlink");
    800050f2:	00003517          	auipc	a0,0x3
    800050f6:	60e50513          	addi	a0,a0,1550 # 80008700 <syscalls+0x2e0>
    800050fa:	ffffb097          	auipc	ra,0xffffb
    800050fe:	44e080e7          	jalr	1102(ra) # 80000548 <panic>
    return 0;
    80005102:	84aa                	mv	s1,a0
    80005104:	bf01                	j	80005014 <create+0x70>

0000000080005106 <sys_dup>:
{
    80005106:	7179                	addi	sp,sp,-48
    80005108:	f406                	sd	ra,40(sp)
    8000510a:	f022                	sd	s0,32(sp)
    8000510c:	ec26                	sd	s1,24(sp)
    8000510e:	e84a                	sd	s2,16(sp)
    80005110:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005112:	fd840613          	addi	a2,s0,-40
    80005116:	4581                	li	a1,0
    80005118:	4501                	li	a0,0
    8000511a:	00000097          	auipc	ra,0x0
    8000511e:	de0080e7          	jalr	-544(ra) # 80004efa <argfd>
    return -1;
    80005122:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005124:	02054363          	bltz	a0,8000514a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005128:	fd843903          	ld	s2,-40(s0)
    8000512c:	854a                	mv	a0,s2
    8000512e:	00000097          	auipc	ra,0x0
    80005132:	e34080e7          	jalr	-460(ra) # 80004f62 <fdalloc>
    80005136:	84aa                	mv	s1,a0
    return -1;
    80005138:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000513a:	00054863          	bltz	a0,8000514a <sys_dup+0x44>
  filedup(f);
    8000513e:	854a                	mv	a0,s2
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	358080e7          	jalr	856(ra) # 80004498 <filedup>
  return fd;
    80005148:	87a6                	mv	a5,s1
}
    8000514a:	853e                	mv	a0,a5
    8000514c:	70a2                	ld	ra,40(sp)
    8000514e:	7402                	ld	s0,32(sp)
    80005150:	64e2                	ld	s1,24(sp)
    80005152:	6942                	ld	s2,16(sp)
    80005154:	6145                	addi	sp,sp,48
    80005156:	8082                	ret

0000000080005158 <sys_read>:
{
    80005158:	7179                	addi	sp,sp,-48
    8000515a:	f406                	sd	ra,40(sp)
    8000515c:	f022                	sd	s0,32(sp)
    8000515e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005160:	fe840613          	addi	a2,s0,-24
    80005164:	4581                	li	a1,0
    80005166:	4501                	li	a0,0
    80005168:	00000097          	auipc	ra,0x0
    8000516c:	d92080e7          	jalr	-622(ra) # 80004efa <argfd>
    return -1;
    80005170:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005172:	04054163          	bltz	a0,800051b4 <sys_read+0x5c>
    80005176:	fe440593          	addi	a1,s0,-28
    8000517a:	4509                	li	a0,2
    8000517c:	ffffe097          	auipc	ra,0xffffe
    80005180:	984080e7          	jalr	-1660(ra) # 80002b00 <argint>
    return -1;
    80005184:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005186:	02054763          	bltz	a0,800051b4 <sys_read+0x5c>
    8000518a:	fd840593          	addi	a1,s0,-40
    8000518e:	4505                	li	a0,1
    80005190:	ffffe097          	auipc	ra,0xffffe
    80005194:	992080e7          	jalr	-1646(ra) # 80002b22 <argaddr>
    return -1;
    80005198:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000519a:	00054d63          	bltz	a0,800051b4 <sys_read+0x5c>
  return fileread(f, p, n);
    8000519e:	fe442603          	lw	a2,-28(s0)
    800051a2:	fd843583          	ld	a1,-40(s0)
    800051a6:	fe843503          	ld	a0,-24(s0)
    800051aa:	fffff097          	auipc	ra,0xfffff
    800051ae:	47a080e7          	jalr	1146(ra) # 80004624 <fileread>
    800051b2:	87aa                	mv	a5,a0
}
    800051b4:	853e                	mv	a0,a5
    800051b6:	70a2                	ld	ra,40(sp)
    800051b8:	7402                	ld	s0,32(sp)
    800051ba:	6145                	addi	sp,sp,48
    800051bc:	8082                	ret

00000000800051be <sys_write>:
{
    800051be:	7179                	addi	sp,sp,-48
    800051c0:	f406                	sd	ra,40(sp)
    800051c2:	f022                	sd	s0,32(sp)
    800051c4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051c6:	fe840613          	addi	a2,s0,-24
    800051ca:	4581                	li	a1,0
    800051cc:	4501                	li	a0,0
    800051ce:	00000097          	auipc	ra,0x0
    800051d2:	d2c080e7          	jalr	-724(ra) # 80004efa <argfd>
    return -1;
    800051d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051d8:	04054163          	bltz	a0,8000521a <sys_write+0x5c>
    800051dc:	fe440593          	addi	a1,s0,-28
    800051e0:	4509                	li	a0,2
    800051e2:	ffffe097          	auipc	ra,0xffffe
    800051e6:	91e080e7          	jalr	-1762(ra) # 80002b00 <argint>
    return -1;
    800051ea:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051ec:	02054763          	bltz	a0,8000521a <sys_write+0x5c>
    800051f0:	fd840593          	addi	a1,s0,-40
    800051f4:	4505                	li	a0,1
    800051f6:	ffffe097          	auipc	ra,0xffffe
    800051fa:	92c080e7          	jalr	-1748(ra) # 80002b22 <argaddr>
    return -1;
    800051fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005200:	00054d63          	bltz	a0,8000521a <sys_write+0x5c>
  return filewrite(f, p, n);
    80005204:	fe442603          	lw	a2,-28(s0)
    80005208:	fd843583          	ld	a1,-40(s0)
    8000520c:	fe843503          	ld	a0,-24(s0)
    80005210:	fffff097          	auipc	ra,0xfffff
    80005214:	4d6080e7          	jalr	1238(ra) # 800046e6 <filewrite>
    80005218:	87aa                	mv	a5,a0
}
    8000521a:	853e                	mv	a0,a5
    8000521c:	70a2                	ld	ra,40(sp)
    8000521e:	7402                	ld	s0,32(sp)
    80005220:	6145                	addi	sp,sp,48
    80005222:	8082                	ret

0000000080005224 <sys_close>:
{
    80005224:	1101                	addi	sp,sp,-32
    80005226:	ec06                	sd	ra,24(sp)
    80005228:	e822                	sd	s0,16(sp)
    8000522a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000522c:	fe040613          	addi	a2,s0,-32
    80005230:	fec40593          	addi	a1,s0,-20
    80005234:	4501                	li	a0,0
    80005236:	00000097          	auipc	ra,0x0
    8000523a:	cc4080e7          	jalr	-828(ra) # 80004efa <argfd>
    return -1;
    8000523e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005240:	02054463          	bltz	a0,80005268 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005244:	ffffc097          	auipc	ra,0xffffc
    80005248:	7fa080e7          	jalr	2042(ra) # 80001a3e <myproc>
    8000524c:	fec42783          	lw	a5,-20(s0)
    80005250:	07e9                	addi	a5,a5,26
    80005252:	078e                	slli	a5,a5,0x3
    80005254:	953e                	add	a0,a0,a5
    80005256:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000525a:	fe043503          	ld	a0,-32(s0)
    8000525e:	fffff097          	auipc	ra,0xfffff
    80005262:	28c080e7          	jalr	652(ra) # 800044ea <fileclose>
  return 0;
    80005266:	4781                	li	a5,0
}
    80005268:	853e                	mv	a0,a5
    8000526a:	60e2                	ld	ra,24(sp)
    8000526c:	6442                	ld	s0,16(sp)
    8000526e:	6105                	addi	sp,sp,32
    80005270:	8082                	ret

0000000080005272 <sys_fstat>:
{
    80005272:	1101                	addi	sp,sp,-32
    80005274:	ec06                	sd	ra,24(sp)
    80005276:	e822                	sd	s0,16(sp)
    80005278:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000527a:	fe840613          	addi	a2,s0,-24
    8000527e:	4581                	li	a1,0
    80005280:	4501                	li	a0,0
    80005282:	00000097          	auipc	ra,0x0
    80005286:	c78080e7          	jalr	-904(ra) # 80004efa <argfd>
    return -1;
    8000528a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000528c:	02054563          	bltz	a0,800052b6 <sys_fstat+0x44>
    80005290:	fe040593          	addi	a1,s0,-32
    80005294:	4505                	li	a0,1
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	88c080e7          	jalr	-1908(ra) # 80002b22 <argaddr>
    return -1;
    8000529e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052a0:	00054b63          	bltz	a0,800052b6 <sys_fstat+0x44>
  return filestat(f, st);
    800052a4:	fe043583          	ld	a1,-32(s0)
    800052a8:	fe843503          	ld	a0,-24(s0)
    800052ac:	fffff097          	auipc	ra,0xfffff
    800052b0:	306080e7          	jalr	774(ra) # 800045b2 <filestat>
    800052b4:	87aa                	mv	a5,a0
}
    800052b6:	853e                	mv	a0,a5
    800052b8:	60e2                	ld	ra,24(sp)
    800052ba:	6442                	ld	s0,16(sp)
    800052bc:	6105                	addi	sp,sp,32
    800052be:	8082                	ret

00000000800052c0 <sys_link>:
{
    800052c0:	7169                	addi	sp,sp,-304
    800052c2:	f606                	sd	ra,296(sp)
    800052c4:	f222                	sd	s0,288(sp)
    800052c6:	ee26                	sd	s1,280(sp)
    800052c8:	ea4a                	sd	s2,272(sp)
    800052ca:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052cc:	08000613          	li	a2,128
    800052d0:	ed040593          	addi	a1,s0,-304
    800052d4:	4501                	li	a0,0
    800052d6:	ffffe097          	auipc	ra,0xffffe
    800052da:	86e080e7          	jalr	-1938(ra) # 80002b44 <argstr>
    return -1;
    800052de:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052e0:	10054e63          	bltz	a0,800053fc <sys_link+0x13c>
    800052e4:	08000613          	li	a2,128
    800052e8:	f5040593          	addi	a1,s0,-176
    800052ec:	4505                	li	a0,1
    800052ee:	ffffe097          	auipc	ra,0xffffe
    800052f2:	856080e7          	jalr	-1962(ra) # 80002b44 <argstr>
    return -1;
    800052f6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052f8:	10054263          	bltz	a0,800053fc <sys_link+0x13c>
  begin_op();
    800052fc:	fffff097          	auipc	ra,0xfffff
    80005300:	d22080e7          	jalr	-734(ra) # 8000401e <begin_op>
  if((ip = namei(old)) == 0){
    80005304:	ed040513          	addi	a0,s0,-304
    80005308:	fffff097          	auipc	ra,0xfffff
    8000530c:	b16080e7          	jalr	-1258(ra) # 80003e1e <namei>
    80005310:	84aa                	mv	s1,a0
    80005312:	c551                	beqz	a0,8000539e <sys_link+0xde>
  ilock(ip);
    80005314:	ffffe097          	auipc	ra,0xffffe
    80005318:	356080e7          	jalr	854(ra) # 8000366a <ilock>
  if(ip->type == T_DIR){
    8000531c:	04449703          	lh	a4,68(s1)
    80005320:	4785                	li	a5,1
    80005322:	08f70463          	beq	a4,a5,800053aa <sys_link+0xea>
  ip->nlink++;
    80005326:	04a4d783          	lhu	a5,74(s1)
    8000532a:	2785                	addiw	a5,a5,1
    8000532c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005330:	8526                	mv	a0,s1
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	26c080e7          	jalr	620(ra) # 8000359e <iupdate>
  iunlock(ip);
    8000533a:	8526                	mv	a0,s1
    8000533c:	ffffe097          	auipc	ra,0xffffe
    80005340:	3f0080e7          	jalr	1008(ra) # 8000372c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005344:	fd040593          	addi	a1,s0,-48
    80005348:	f5040513          	addi	a0,s0,-176
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	af0080e7          	jalr	-1296(ra) # 80003e3c <nameiparent>
    80005354:	892a                	mv	s2,a0
    80005356:	c935                	beqz	a0,800053ca <sys_link+0x10a>
  ilock(dp);
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	312080e7          	jalr	786(ra) # 8000366a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005360:	00092703          	lw	a4,0(s2)
    80005364:	409c                	lw	a5,0(s1)
    80005366:	04f71d63          	bne	a4,a5,800053c0 <sys_link+0x100>
    8000536a:	40d0                	lw	a2,4(s1)
    8000536c:	fd040593          	addi	a1,s0,-48
    80005370:	854a                	mv	a0,s2
    80005372:	fffff097          	auipc	ra,0xfffff
    80005376:	9ea080e7          	jalr	-1558(ra) # 80003d5c <dirlink>
    8000537a:	04054363          	bltz	a0,800053c0 <sys_link+0x100>
  iunlockput(dp);
    8000537e:	854a                	mv	a0,s2
    80005380:	ffffe097          	auipc	ra,0xffffe
    80005384:	54c080e7          	jalr	1356(ra) # 800038cc <iunlockput>
  iput(ip);
    80005388:	8526                	mv	a0,s1
    8000538a:	ffffe097          	auipc	ra,0xffffe
    8000538e:	49a080e7          	jalr	1178(ra) # 80003824 <iput>
  end_op();
    80005392:	fffff097          	auipc	ra,0xfffff
    80005396:	d06080e7          	jalr	-762(ra) # 80004098 <end_op>
  return 0;
    8000539a:	4781                	li	a5,0
    8000539c:	a085                	j	800053fc <sys_link+0x13c>
    end_op();
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	cfa080e7          	jalr	-774(ra) # 80004098 <end_op>
    return -1;
    800053a6:	57fd                	li	a5,-1
    800053a8:	a891                	j	800053fc <sys_link+0x13c>
    iunlockput(ip);
    800053aa:	8526                	mv	a0,s1
    800053ac:	ffffe097          	auipc	ra,0xffffe
    800053b0:	520080e7          	jalr	1312(ra) # 800038cc <iunlockput>
    end_op();
    800053b4:	fffff097          	auipc	ra,0xfffff
    800053b8:	ce4080e7          	jalr	-796(ra) # 80004098 <end_op>
    return -1;
    800053bc:	57fd                	li	a5,-1
    800053be:	a83d                	j	800053fc <sys_link+0x13c>
    iunlockput(dp);
    800053c0:	854a                	mv	a0,s2
    800053c2:	ffffe097          	auipc	ra,0xffffe
    800053c6:	50a080e7          	jalr	1290(ra) # 800038cc <iunlockput>
  ilock(ip);
    800053ca:	8526                	mv	a0,s1
    800053cc:	ffffe097          	auipc	ra,0xffffe
    800053d0:	29e080e7          	jalr	670(ra) # 8000366a <ilock>
  ip->nlink--;
    800053d4:	04a4d783          	lhu	a5,74(s1)
    800053d8:	37fd                	addiw	a5,a5,-1
    800053da:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053de:	8526                	mv	a0,s1
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	1be080e7          	jalr	446(ra) # 8000359e <iupdate>
  iunlockput(ip);
    800053e8:	8526                	mv	a0,s1
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	4e2080e7          	jalr	1250(ra) # 800038cc <iunlockput>
  end_op();
    800053f2:	fffff097          	auipc	ra,0xfffff
    800053f6:	ca6080e7          	jalr	-858(ra) # 80004098 <end_op>
  return -1;
    800053fa:	57fd                	li	a5,-1
}
    800053fc:	853e                	mv	a0,a5
    800053fe:	70b2                	ld	ra,296(sp)
    80005400:	7412                	ld	s0,288(sp)
    80005402:	64f2                	ld	s1,280(sp)
    80005404:	6952                	ld	s2,272(sp)
    80005406:	6155                	addi	sp,sp,304
    80005408:	8082                	ret

000000008000540a <sys_unlink>:
{
    8000540a:	7151                	addi	sp,sp,-240
    8000540c:	f586                	sd	ra,232(sp)
    8000540e:	f1a2                	sd	s0,224(sp)
    80005410:	eda6                	sd	s1,216(sp)
    80005412:	e9ca                	sd	s2,208(sp)
    80005414:	e5ce                	sd	s3,200(sp)
    80005416:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005418:	08000613          	li	a2,128
    8000541c:	f3040593          	addi	a1,s0,-208
    80005420:	4501                	li	a0,0
    80005422:	ffffd097          	auipc	ra,0xffffd
    80005426:	722080e7          	jalr	1826(ra) # 80002b44 <argstr>
    8000542a:	18054163          	bltz	a0,800055ac <sys_unlink+0x1a2>
  begin_op();
    8000542e:	fffff097          	auipc	ra,0xfffff
    80005432:	bf0080e7          	jalr	-1040(ra) # 8000401e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005436:	fb040593          	addi	a1,s0,-80
    8000543a:	f3040513          	addi	a0,s0,-208
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	9fe080e7          	jalr	-1538(ra) # 80003e3c <nameiparent>
    80005446:	84aa                	mv	s1,a0
    80005448:	c979                	beqz	a0,8000551e <sys_unlink+0x114>
  ilock(dp);
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	220080e7          	jalr	544(ra) # 8000366a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005452:	00003597          	auipc	a1,0x3
    80005456:	28e58593          	addi	a1,a1,654 # 800086e0 <syscalls+0x2c0>
    8000545a:	fb040513          	addi	a0,s0,-80
    8000545e:	ffffe097          	auipc	ra,0xffffe
    80005462:	6d4080e7          	jalr	1748(ra) # 80003b32 <namecmp>
    80005466:	14050a63          	beqz	a0,800055ba <sys_unlink+0x1b0>
    8000546a:	00003597          	auipc	a1,0x3
    8000546e:	27e58593          	addi	a1,a1,638 # 800086e8 <syscalls+0x2c8>
    80005472:	fb040513          	addi	a0,s0,-80
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	6bc080e7          	jalr	1724(ra) # 80003b32 <namecmp>
    8000547e:	12050e63          	beqz	a0,800055ba <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005482:	f2c40613          	addi	a2,s0,-212
    80005486:	fb040593          	addi	a1,s0,-80
    8000548a:	8526                	mv	a0,s1
    8000548c:	ffffe097          	auipc	ra,0xffffe
    80005490:	6c0080e7          	jalr	1728(ra) # 80003b4c <dirlookup>
    80005494:	892a                	mv	s2,a0
    80005496:	12050263          	beqz	a0,800055ba <sys_unlink+0x1b0>
  ilock(ip);
    8000549a:	ffffe097          	auipc	ra,0xffffe
    8000549e:	1d0080e7          	jalr	464(ra) # 8000366a <ilock>
  if(ip->nlink < 1)
    800054a2:	04a91783          	lh	a5,74(s2)
    800054a6:	08f05263          	blez	a5,8000552a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054aa:	04491703          	lh	a4,68(s2)
    800054ae:	4785                	li	a5,1
    800054b0:	08f70563          	beq	a4,a5,8000553a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054b4:	4641                	li	a2,16
    800054b6:	4581                	li	a1,0
    800054b8:	fc040513          	addi	a0,s0,-64
    800054bc:	ffffc097          	auipc	ra,0xffffc
    800054c0:	926080e7          	jalr	-1754(ra) # 80000de2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054c4:	4741                	li	a4,16
    800054c6:	f2c42683          	lw	a3,-212(s0)
    800054ca:	fc040613          	addi	a2,s0,-64
    800054ce:	4581                	li	a1,0
    800054d0:	8526                	mv	a0,s1
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	544080e7          	jalr	1348(ra) # 80003a16 <writei>
    800054da:	47c1                	li	a5,16
    800054dc:	0af51563          	bne	a0,a5,80005586 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054e0:	04491703          	lh	a4,68(s2)
    800054e4:	4785                	li	a5,1
    800054e6:	0af70863          	beq	a4,a5,80005596 <sys_unlink+0x18c>
  iunlockput(dp);
    800054ea:	8526                	mv	a0,s1
    800054ec:	ffffe097          	auipc	ra,0xffffe
    800054f0:	3e0080e7          	jalr	992(ra) # 800038cc <iunlockput>
  ip->nlink--;
    800054f4:	04a95783          	lhu	a5,74(s2)
    800054f8:	37fd                	addiw	a5,a5,-1
    800054fa:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054fe:	854a                	mv	a0,s2
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	09e080e7          	jalr	158(ra) # 8000359e <iupdate>
  iunlockput(ip);
    80005508:	854a                	mv	a0,s2
    8000550a:	ffffe097          	auipc	ra,0xffffe
    8000550e:	3c2080e7          	jalr	962(ra) # 800038cc <iunlockput>
  end_op();
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	b86080e7          	jalr	-1146(ra) # 80004098 <end_op>
  return 0;
    8000551a:	4501                	li	a0,0
    8000551c:	a84d                	j	800055ce <sys_unlink+0x1c4>
    end_op();
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	b7a080e7          	jalr	-1158(ra) # 80004098 <end_op>
    return -1;
    80005526:	557d                	li	a0,-1
    80005528:	a05d                	j	800055ce <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000552a:	00003517          	auipc	a0,0x3
    8000552e:	1e650513          	addi	a0,a0,486 # 80008710 <syscalls+0x2f0>
    80005532:	ffffb097          	auipc	ra,0xffffb
    80005536:	016080e7          	jalr	22(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000553a:	04c92703          	lw	a4,76(s2)
    8000553e:	02000793          	li	a5,32
    80005542:	f6e7f9e3          	bgeu	a5,a4,800054b4 <sys_unlink+0xaa>
    80005546:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000554a:	4741                	li	a4,16
    8000554c:	86ce                	mv	a3,s3
    8000554e:	f1840613          	addi	a2,s0,-232
    80005552:	4581                	li	a1,0
    80005554:	854a                	mv	a0,s2
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	3c8080e7          	jalr	968(ra) # 8000391e <readi>
    8000555e:	47c1                	li	a5,16
    80005560:	00f51b63          	bne	a0,a5,80005576 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005564:	f1845783          	lhu	a5,-232(s0)
    80005568:	e7a1                	bnez	a5,800055b0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000556a:	29c1                	addiw	s3,s3,16
    8000556c:	04c92783          	lw	a5,76(s2)
    80005570:	fcf9ede3          	bltu	s3,a5,8000554a <sys_unlink+0x140>
    80005574:	b781                	j	800054b4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005576:	00003517          	auipc	a0,0x3
    8000557a:	1b250513          	addi	a0,a0,434 # 80008728 <syscalls+0x308>
    8000557e:	ffffb097          	auipc	ra,0xffffb
    80005582:	fca080e7          	jalr	-54(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005586:	00003517          	auipc	a0,0x3
    8000558a:	1ba50513          	addi	a0,a0,442 # 80008740 <syscalls+0x320>
    8000558e:	ffffb097          	auipc	ra,0xffffb
    80005592:	fba080e7          	jalr	-70(ra) # 80000548 <panic>
    dp->nlink--;
    80005596:	04a4d783          	lhu	a5,74(s1)
    8000559a:	37fd                	addiw	a5,a5,-1
    8000559c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055a0:	8526                	mv	a0,s1
    800055a2:	ffffe097          	auipc	ra,0xffffe
    800055a6:	ffc080e7          	jalr	-4(ra) # 8000359e <iupdate>
    800055aa:	b781                	j	800054ea <sys_unlink+0xe0>
    return -1;
    800055ac:	557d                	li	a0,-1
    800055ae:	a005                	j	800055ce <sys_unlink+0x1c4>
    iunlockput(ip);
    800055b0:	854a                	mv	a0,s2
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	31a080e7          	jalr	794(ra) # 800038cc <iunlockput>
  iunlockput(dp);
    800055ba:	8526                	mv	a0,s1
    800055bc:	ffffe097          	auipc	ra,0xffffe
    800055c0:	310080e7          	jalr	784(ra) # 800038cc <iunlockput>
  end_op();
    800055c4:	fffff097          	auipc	ra,0xfffff
    800055c8:	ad4080e7          	jalr	-1324(ra) # 80004098 <end_op>
  return -1;
    800055cc:	557d                	li	a0,-1
}
    800055ce:	70ae                	ld	ra,232(sp)
    800055d0:	740e                	ld	s0,224(sp)
    800055d2:	64ee                	ld	s1,216(sp)
    800055d4:	694e                	ld	s2,208(sp)
    800055d6:	69ae                	ld	s3,200(sp)
    800055d8:	616d                	addi	sp,sp,240
    800055da:	8082                	ret

00000000800055dc <sys_open>:

uint64
sys_open(void)
{
    800055dc:	7131                	addi	sp,sp,-192
    800055de:	fd06                	sd	ra,184(sp)
    800055e0:	f922                	sd	s0,176(sp)
    800055e2:	f526                	sd	s1,168(sp)
    800055e4:	f14a                	sd	s2,160(sp)
    800055e6:	ed4e                	sd	s3,152(sp)
    800055e8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055ea:	08000613          	li	a2,128
    800055ee:	f5040593          	addi	a1,s0,-176
    800055f2:	4501                	li	a0,0
    800055f4:	ffffd097          	auipc	ra,0xffffd
    800055f8:	550080e7          	jalr	1360(ra) # 80002b44 <argstr>
    return -1;
    800055fc:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055fe:	0c054063          	bltz	a0,800056be <sys_open+0xe2>
    80005602:	f4c40593          	addi	a1,s0,-180
    80005606:	4505                	li	a0,1
    80005608:	ffffd097          	auipc	ra,0xffffd
    8000560c:	4f8080e7          	jalr	1272(ra) # 80002b00 <argint>
    80005610:	0a054763          	bltz	a0,800056be <sys_open+0xe2>

  begin_op();
    80005614:	fffff097          	auipc	ra,0xfffff
    80005618:	a0a080e7          	jalr	-1526(ra) # 8000401e <begin_op>

  if(omode & O_CREATE){
    8000561c:	f4c42783          	lw	a5,-180(s0)
    80005620:	2007f793          	andi	a5,a5,512
    80005624:	cbd5                	beqz	a5,800056d8 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005626:	4681                	li	a3,0
    80005628:	4601                	li	a2,0
    8000562a:	4589                	li	a1,2
    8000562c:	f5040513          	addi	a0,s0,-176
    80005630:	00000097          	auipc	ra,0x0
    80005634:	974080e7          	jalr	-1676(ra) # 80004fa4 <create>
    80005638:	892a                	mv	s2,a0
    if(ip == 0){
    8000563a:	c951                	beqz	a0,800056ce <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000563c:	04491703          	lh	a4,68(s2)
    80005640:	478d                	li	a5,3
    80005642:	00f71763          	bne	a4,a5,80005650 <sys_open+0x74>
    80005646:	04695703          	lhu	a4,70(s2)
    8000564a:	47a5                	li	a5,9
    8000564c:	0ce7eb63          	bltu	a5,a4,80005722 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	dde080e7          	jalr	-546(ra) # 8000442e <filealloc>
    80005658:	89aa                	mv	s3,a0
    8000565a:	c565                	beqz	a0,80005742 <sys_open+0x166>
    8000565c:	00000097          	auipc	ra,0x0
    80005660:	906080e7          	jalr	-1786(ra) # 80004f62 <fdalloc>
    80005664:	84aa                	mv	s1,a0
    80005666:	0c054963          	bltz	a0,80005738 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000566a:	04491703          	lh	a4,68(s2)
    8000566e:	478d                	li	a5,3
    80005670:	0ef70463          	beq	a4,a5,80005758 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005674:	4789                	li	a5,2
    80005676:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000567a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000567e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005682:	f4c42783          	lw	a5,-180(s0)
    80005686:	0017c713          	xori	a4,a5,1
    8000568a:	8b05                	andi	a4,a4,1
    8000568c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005690:	0037f713          	andi	a4,a5,3
    80005694:	00e03733          	snez	a4,a4
    80005698:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000569c:	4007f793          	andi	a5,a5,1024
    800056a0:	c791                	beqz	a5,800056ac <sys_open+0xd0>
    800056a2:	04491703          	lh	a4,68(s2)
    800056a6:	4789                	li	a5,2
    800056a8:	0af70f63          	beq	a4,a5,80005766 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800056ac:	854a                	mv	a0,s2
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	07e080e7          	jalr	126(ra) # 8000372c <iunlock>
  end_op();
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	9e2080e7          	jalr	-1566(ra) # 80004098 <end_op>

  return fd;
}
    800056be:	8526                	mv	a0,s1
    800056c0:	70ea                	ld	ra,184(sp)
    800056c2:	744a                	ld	s0,176(sp)
    800056c4:	74aa                	ld	s1,168(sp)
    800056c6:	790a                	ld	s2,160(sp)
    800056c8:	69ea                	ld	s3,152(sp)
    800056ca:	6129                	addi	sp,sp,192
    800056cc:	8082                	ret
      end_op();
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	9ca080e7          	jalr	-1590(ra) # 80004098 <end_op>
      return -1;
    800056d6:	b7e5                	j	800056be <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800056d8:	f5040513          	addi	a0,s0,-176
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	742080e7          	jalr	1858(ra) # 80003e1e <namei>
    800056e4:	892a                	mv	s2,a0
    800056e6:	c905                	beqz	a0,80005716 <sys_open+0x13a>
    ilock(ip);
    800056e8:	ffffe097          	auipc	ra,0xffffe
    800056ec:	f82080e7          	jalr	-126(ra) # 8000366a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056f0:	04491703          	lh	a4,68(s2)
    800056f4:	4785                	li	a5,1
    800056f6:	f4f713e3          	bne	a4,a5,8000563c <sys_open+0x60>
    800056fa:	f4c42783          	lw	a5,-180(s0)
    800056fe:	dba9                	beqz	a5,80005650 <sys_open+0x74>
      iunlockput(ip);
    80005700:	854a                	mv	a0,s2
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	1ca080e7          	jalr	458(ra) # 800038cc <iunlockput>
      end_op();
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	98e080e7          	jalr	-1650(ra) # 80004098 <end_op>
      return -1;
    80005712:	54fd                	li	s1,-1
    80005714:	b76d                	j	800056be <sys_open+0xe2>
      end_op();
    80005716:	fffff097          	auipc	ra,0xfffff
    8000571a:	982080e7          	jalr	-1662(ra) # 80004098 <end_op>
      return -1;
    8000571e:	54fd                	li	s1,-1
    80005720:	bf79                	j	800056be <sys_open+0xe2>
    iunlockput(ip);
    80005722:	854a                	mv	a0,s2
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	1a8080e7          	jalr	424(ra) # 800038cc <iunlockput>
    end_op();
    8000572c:	fffff097          	auipc	ra,0xfffff
    80005730:	96c080e7          	jalr	-1684(ra) # 80004098 <end_op>
    return -1;
    80005734:	54fd                	li	s1,-1
    80005736:	b761                	j	800056be <sys_open+0xe2>
      fileclose(f);
    80005738:	854e                	mv	a0,s3
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	db0080e7          	jalr	-592(ra) # 800044ea <fileclose>
    iunlockput(ip);
    80005742:	854a                	mv	a0,s2
    80005744:	ffffe097          	auipc	ra,0xffffe
    80005748:	188080e7          	jalr	392(ra) # 800038cc <iunlockput>
    end_op();
    8000574c:	fffff097          	auipc	ra,0xfffff
    80005750:	94c080e7          	jalr	-1716(ra) # 80004098 <end_op>
    return -1;
    80005754:	54fd                	li	s1,-1
    80005756:	b7a5                	j	800056be <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005758:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000575c:	04691783          	lh	a5,70(s2)
    80005760:	02f99223          	sh	a5,36(s3)
    80005764:	bf29                	j	8000567e <sys_open+0xa2>
    itrunc(ip);
    80005766:	854a                	mv	a0,s2
    80005768:	ffffe097          	auipc	ra,0xffffe
    8000576c:	010080e7          	jalr	16(ra) # 80003778 <itrunc>
    80005770:	bf35                	j	800056ac <sys_open+0xd0>

0000000080005772 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005772:	7175                	addi	sp,sp,-144
    80005774:	e506                	sd	ra,136(sp)
    80005776:	e122                	sd	s0,128(sp)
    80005778:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000577a:	fffff097          	auipc	ra,0xfffff
    8000577e:	8a4080e7          	jalr	-1884(ra) # 8000401e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005782:	08000613          	li	a2,128
    80005786:	f7040593          	addi	a1,s0,-144
    8000578a:	4501                	li	a0,0
    8000578c:	ffffd097          	auipc	ra,0xffffd
    80005790:	3b8080e7          	jalr	952(ra) # 80002b44 <argstr>
    80005794:	02054963          	bltz	a0,800057c6 <sys_mkdir+0x54>
    80005798:	4681                	li	a3,0
    8000579a:	4601                	li	a2,0
    8000579c:	4585                	li	a1,1
    8000579e:	f7040513          	addi	a0,s0,-144
    800057a2:	00000097          	auipc	ra,0x0
    800057a6:	802080e7          	jalr	-2046(ra) # 80004fa4 <create>
    800057aa:	cd11                	beqz	a0,800057c6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	120080e7          	jalr	288(ra) # 800038cc <iunlockput>
  end_op();
    800057b4:	fffff097          	auipc	ra,0xfffff
    800057b8:	8e4080e7          	jalr	-1820(ra) # 80004098 <end_op>
  return 0;
    800057bc:	4501                	li	a0,0
}
    800057be:	60aa                	ld	ra,136(sp)
    800057c0:	640a                	ld	s0,128(sp)
    800057c2:	6149                	addi	sp,sp,144
    800057c4:	8082                	ret
    end_op();
    800057c6:	fffff097          	auipc	ra,0xfffff
    800057ca:	8d2080e7          	jalr	-1838(ra) # 80004098 <end_op>
    return -1;
    800057ce:	557d                	li	a0,-1
    800057d0:	b7fd                	j	800057be <sys_mkdir+0x4c>

00000000800057d2 <sys_mknod>:

uint64
sys_mknod(void)
{
    800057d2:	7135                	addi	sp,sp,-160
    800057d4:	ed06                	sd	ra,152(sp)
    800057d6:	e922                	sd	s0,144(sp)
    800057d8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	844080e7          	jalr	-1980(ra) # 8000401e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057e2:	08000613          	li	a2,128
    800057e6:	f7040593          	addi	a1,s0,-144
    800057ea:	4501                	li	a0,0
    800057ec:	ffffd097          	auipc	ra,0xffffd
    800057f0:	358080e7          	jalr	856(ra) # 80002b44 <argstr>
    800057f4:	04054a63          	bltz	a0,80005848 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800057f8:	f6c40593          	addi	a1,s0,-148
    800057fc:	4505                	li	a0,1
    800057fe:	ffffd097          	auipc	ra,0xffffd
    80005802:	302080e7          	jalr	770(ra) # 80002b00 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005806:	04054163          	bltz	a0,80005848 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000580a:	f6840593          	addi	a1,s0,-152
    8000580e:	4509                	li	a0,2
    80005810:	ffffd097          	auipc	ra,0xffffd
    80005814:	2f0080e7          	jalr	752(ra) # 80002b00 <argint>
     argint(1, &major) < 0 ||
    80005818:	02054863          	bltz	a0,80005848 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000581c:	f6841683          	lh	a3,-152(s0)
    80005820:	f6c41603          	lh	a2,-148(s0)
    80005824:	458d                	li	a1,3
    80005826:	f7040513          	addi	a0,s0,-144
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	77a080e7          	jalr	1914(ra) # 80004fa4 <create>
     argint(2, &minor) < 0 ||
    80005832:	c919                	beqz	a0,80005848 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	098080e7          	jalr	152(ra) # 800038cc <iunlockput>
  end_op();
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	85c080e7          	jalr	-1956(ra) # 80004098 <end_op>
  return 0;
    80005844:	4501                	li	a0,0
    80005846:	a031                	j	80005852 <sys_mknod+0x80>
    end_op();
    80005848:	fffff097          	auipc	ra,0xfffff
    8000584c:	850080e7          	jalr	-1968(ra) # 80004098 <end_op>
    return -1;
    80005850:	557d                	li	a0,-1
}
    80005852:	60ea                	ld	ra,152(sp)
    80005854:	644a                	ld	s0,144(sp)
    80005856:	610d                	addi	sp,sp,160
    80005858:	8082                	ret

000000008000585a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000585a:	7135                	addi	sp,sp,-160
    8000585c:	ed06                	sd	ra,152(sp)
    8000585e:	e922                	sd	s0,144(sp)
    80005860:	e526                	sd	s1,136(sp)
    80005862:	e14a                	sd	s2,128(sp)
    80005864:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005866:	ffffc097          	auipc	ra,0xffffc
    8000586a:	1d8080e7          	jalr	472(ra) # 80001a3e <myproc>
    8000586e:	892a                	mv	s2,a0
  
  begin_op();
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	7ae080e7          	jalr	1966(ra) # 8000401e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005878:	08000613          	li	a2,128
    8000587c:	f6040593          	addi	a1,s0,-160
    80005880:	4501                	li	a0,0
    80005882:	ffffd097          	auipc	ra,0xffffd
    80005886:	2c2080e7          	jalr	706(ra) # 80002b44 <argstr>
    8000588a:	04054b63          	bltz	a0,800058e0 <sys_chdir+0x86>
    8000588e:	f6040513          	addi	a0,s0,-160
    80005892:	ffffe097          	auipc	ra,0xffffe
    80005896:	58c080e7          	jalr	1420(ra) # 80003e1e <namei>
    8000589a:	84aa                	mv	s1,a0
    8000589c:	c131                	beqz	a0,800058e0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	dcc080e7          	jalr	-564(ra) # 8000366a <ilock>
  if(ip->type != T_DIR){
    800058a6:	04449703          	lh	a4,68(s1)
    800058aa:	4785                	li	a5,1
    800058ac:	04f71063          	bne	a4,a5,800058ec <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058b0:	8526                	mv	a0,s1
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	e7a080e7          	jalr	-390(ra) # 8000372c <iunlock>
  iput(p->cwd);
    800058ba:	15093503          	ld	a0,336(s2)
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	f66080e7          	jalr	-154(ra) # 80003824 <iput>
  end_op();
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	7d2080e7          	jalr	2002(ra) # 80004098 <end_op>
  p->cwd = ip;
    800058ce:	14993823          	sd	s1,336(s2)
  return 0;
    800058d2:	4501                	li	a0,0
}
    800058d4:	60ea                	ld	ra,152(sp)
    800058d6:	644a                	ld	s0,144(sp)
    800058d8:	64aa                	ld	s1,136(sp)
    800058da:	690a                	ld	s2,128(sp)
    800058dc:	610d                	addi	sp,sp,160
    800058de:	8082                	ret
    end_op();
    800058e0:	ffffe097          	auipc	ra,0xffffe
    800058e4:	7b8080e7          	jalr	1976(ra) # 80004098 <end_op>
    return -1;
    800058e8:	557d                	li	a0,-1
    800058ea:	b7ed                	j	800058d4 <sys_chdir+0x7a>
    iunlockput(ip);
    800058ec:	8526                	mv	a0,s1
    800058ee:	ffffe097          	auipc	ra,0xffffe
    800058f2:	fde080e7          	jalr	-34(ra) # 800038cc <iunlockput>
    end_op();
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	7a2080e7          	jalr	1954(ra) # 80004098 <end_op>
    return -1;
    800058fe:	557d                	li	a0,-1
    80005900:	bfd1                	j	800058d4 <sys_chdir+0x7a>

0000000080005902 <sys_exec>:

uint64
sys_exec(void)
{
    80005902:	7121                	addi	sp,sp,-448
    80005904:	ff06                	sd	ra,440(sp)
    80005906:	fb22                	sd	s0,432(sp)
    80005908:	f726                	sd	s1,424(sp)
    8000590a:	f34a                	sd	s2,416(sp)
    8000590c:	ef4e                	sd	s3,408(sp)
    8000590e:	eb52                	sd	s4,400(sp)
    80005910:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005912:	08000613          	li	a2,128
    80005916:	f5040593          	addi	a1,s0,-176
    8000591a:	4501                	li	a0,0
    8000591c:	ffffd097          	auipc	ra,0xffffd
    80005920:	228080e7          	jalr	552(ra) # 80002b44 <argstr>
    return -1;
    80005924:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005926:	0c054a63          	bltz	a0,800059fa <sys_exec+0xf8>
    8000592a:	e4840593          	addi	a1,s0,-440
    8000592e:	4505                	li	a0,1
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	1f2080e7          	jalr	498(ra) # 80002b22 <argaddr>
    80005938:	0c054163          	bltz	a0,800059fa <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    8000593c:	10000613          	li	a2,256
    80005940:	4581                	li	a1,0
    80005942:	e5040513          	addi	a0,s0,-432
    80005946:	ffffb097          	auipc	ra,0xffffb
    8000594a:	49c080e7          	jalr	1180(ra) # 80000de2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000594e:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005952:	89a6                	mv	s3,s1
    80005954:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005956:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000595a:	00391513          	slli	a0,s2,0x3
    8000595e:	e4040593          	addi	a1,s0,-448
    80005962:	e4843783          	ld	a5,-440(s0)
    80005966:	953e                	add	a0,a0,a5
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	0fe080e7          	jalr	254(ra) # 80002a66 <fetchaddr>
    80005970:	02054a63          	bltz	a0,800059a4 <sys_exec+0xa2>
      goto bad;
    }
    if(uarg == 0){
    80005974:	e4043783          	ld	a5,-448(s0)
    80005978:	c3b9                	beqz	a5,800059be <sys_exec+0xbc>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000597a:	ffffb097          	auipc	ra,0xffffb
    8000597e:	27c080e7          	jalr	636(ra) # 80000bf6 <kalloc>
    80005982:	85aa                	mv	a1,a0
    80005984:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005988:	cd11                	beqz	a0,800059a4 <sys_exec+0xa2>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000598a:	6605                	lui	a2,0x1
    8000598c:	e4043503          	ld	a0,-448(s0)
    80005990:	ffffd097          	auipc	ra,0xffffd
    80005994:	128080e7          	jalr	296(ra) # 80002ab8 <fetchstr>
    80005998:	00054663          	bltz	a0,800059a4 <sys_exec+0xa2>
    if(i >= NELEM(argv)){
    8000599c:	0905                	addi	s2,s2,1
    8000599e:	09a1                	addi	s3,s3,8
    800059a0:	fb491de3          	bne	s2,s4,8000595a <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059a4:	f5040913          	addi	s2,s0,-176
    800059a8:	6088                	ld	a0,0(s1)
    800059aa:	c539                	beqz	a0,800059f8 <sys_exec+0xf6>
    kfree(argv[i]);
    800059ac:	ffffb097          	auipc	ra,0xffffb
    800059b0:	14c080e7          	jalr	332(ra) # 80000af8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059b4:	04a1                	addi	s1,s1,8
    800059b6:	ff2499e3          	bne	s1,s2,800059a8 <sys_exec+0xa6>
  return -1;
    800059ba:	597d                	li	s2,-1
    800059bc:	a83d                	j	800059fa <sys_exec+0xf8>
      argv[i] = 0;
    800059be:	0009079b          	sext.w	a5,s2
    800059c2:	078e                	slli	a5,a5,0x3
    800059c4:	fd078793          	addi	a5,a5,-48
    800059c8:	97a2                	add	a5,a5,s0
    800059ca:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800059ce:	e5040593          	addi	a1,s0,-432
    800059d2:	f5040513          	addi	a0,s0,-176
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	196080e7          	jalr	406(ra) # 80004b6c <exec>
    800059de:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059e0:	f5040993          	addi	s3,s0,-176
    800059e4:	6088                	ld	a0,0(s1)
    800059e6:	c911                	beqz	a0,800059fa <sys_exec+0xf8>
    kfree(argv[i]);
    800059e8:	ffffb097          	auipc	ra,0xffffb
    800059ec:	110080e7          	jalr	272(ra) # 80000af8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059f0:	04a1                	addi	s1,s1,8
    800059f2:	ff3499e3          	bne	s1,s3,800059e4 <sys_exec+0xe2>
    800059f6:	a011                	j	800059fa <sys_exec+0xf8>
  return -1;
    800059f8:	597d                	li	s2,-1
}
    800059fa:	854a                	mv	a0,s2
    800059fc:	70fa                	ld	ra,440(sp)
    800059fe:	745a                	ld	s0,432(sp)
    80005a00:	74ba                	ld	s1,424(sp)
    80005a02:	791a                	ld	s2,416(sp)
    80005a04:	69fa                	ld	s3,408(sp)
    80005a06:	6a5a                	ld	s4,400(sp)
    80005a08:	6139                	addi	sp,sp,448
    80005a0a:	8082                	ret

0000000080005a0c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a0c:	7139                	addi	sp,sp,-64
    80005a0e:	fc06                	sd	ra,56(sp)
    80005a10:	f822                	sd	s0,48(sp)
    80005a12:	f426                	sd	s1,40(sp)
    80005a14:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a16:	ffffc097          	auipc	ra,0xffffc
    80005a1a:	028080e7          	jalr	40(ra) # 80001a3e <myproc>
    80005a1e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005a20:	fd840593          	addi	a1,s0,-40
    80005a24:	4501                	li	a0,0
    80005a26:	ffffd097          	auipc	ra,0xffffd
    80005a2a:	0fc080e7          	jalr	252(ra) # 80002b22 <argaddr>
    return -1;
    80005a2e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005a30:	0e054063          	bltz	a0,80005b10 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005a34:	fc840593          	addi	a1,s0,-56
    80005a38:	fd040513          	addi	a0,s0,-48
    80005a3c:	fffff097          	auipc	ra,0xfffff
    80005a40:	e04080e7          	jalr	-508(ra) # 80004840 <pipealloc>
    return -1;
    80005a44:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a46:	0c054563          	bltz	a0,80005b10 <sys_pipe+0x104>
  fd0 = -1;
    80005a4a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a4e:	fd043503          	ld	a0,-48(s0)
    80005a52:	fffff097          	auipc	ra,0xfffff
    80005a56:	510080e7          	jalr	1296(ra) # 80004f62 <fdalloc>
    80005a5a:	fca42223          	sw	a0,-60(s0)
    80005a5e:	08054c63          	bltz	a0,80005af6 <sys_pipe+0xea>
    80005a62:	fc843503          	ld	a0,-56(s0)
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	4fc080e7          	jalr	1276(ra) # 80004f62 <fdalloc>
    80005a6e:	fca42023          	sw	a0,-64(s0)
    80005a72:	06054963          	bltz	a0,80005ae4 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a76:	4691                	li	a3,4
    80005a78:	fc440613          	addi	a2,s0,-60
    80005a7c:	fd843583          	ld	a1,-40(s0)
    80005a80:	68a8                	ld	a0,80(s1)
    80005a82:	ffffc097          	auipc	ra,0xffffc
    80005a86:	cb2080e7          	jalr	-846(ra) # 80001734 <copyout>
    80005a8a:	02054063          	bltz	a0,80005aaa <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a8e:	4691                	li	a3,4
    80005a90:	fc040613          	addi	a2,s0,-64
    80005a94:	fd843583          	ld	a1,-40(s0)
    80005a98:	0591                	addi	a1,a1,4
    80005a9a:	68a8                	ld	a0,80(s1)
    80005a9c:	ffffc097          	auipc	ra,0xffffc
    80005aa0:	c98080e7          	jalr	-872(ra) # 80001734 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005aa4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005aa6:	06055563          	bgez	a0,80005b10 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005aaa:	fc442783          	lw	a5,-60(s0)
    80005aae:	07e9                	addi	a5,a5,26
    80005ab0:	078e                	slli	a5,a5,0x3
    80005ab2:	97a6                	add	a5,a5,s1
    80005ab4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ab8:	fc042783          	lw	a5,-64(s0)
    80005abc:	07e9                	addi	a5,a5,26
    80005abe:	078e                	slli	a5,a5,0x3
    80005ac0:	00f48533          	add	a0,s1,a5
    80005ac4:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005ac8:	fd043503          	ld	a0,-48(s0)
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	a1e080e7          	jalr	-1506(ra) # 800044ea <fileclose>
    fileclose(wf);
    80005ad4:	fc843503          	ld	a0,-56(s0)
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	a12080e7          	jalr	-1518(ra) # 800044ea <fileclose>
    return -1;
    80005ae0:	57fd                	li	a5,-1
    80005ae2:	a03d                	j	80005b10 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005ae4:	fc442783          	lw	a5,-60(s0)
    80005ae8:	0007c763          	bltz	a5,80005af6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005aec:	07e9                	addi	a5,a5,26
    80005aee:	078e                	slli	a5,a5,0x3
    80005af0:	97a6                	add	a5,a5,s1
    80005af2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005af6:	fd043503          	ld	a0,-48(s0)
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	9f0080e7          	jalr	-1552(ra) # 800044ea <fileclose>
    fileclose(wf);
    80005b02:	fc843503          	ld	a0,-56(s0)
    80005b06:	fffff097          	auipc	ra,0xfffff
    80005b0a:	9e4080e7          	jalr	-1564(ra) # 800044ea <fileclose>
    return -1;
    80005b0e:	57fd                	li	a5,-1
}
    80005b10:	853e                	mv	a0,a5
    80005b12:	70e2                	ld	ra,56(sp)
    80005b14:	7442                	ld	s0,48(sp)
    80005b16:	74a2                	ld	s1,40(sp)
    80005b18:	6121                	addi	sp,sp,64
    80005b1a:	8082                	ret
    80005b1c:	0000                	unimp
	...

0000000080005b20 <kernelvec>:
    80005b20:	7111                	addi	sp,sp,-256
    80005b22:	e006                	sd	ra,0(sp)
    80005b24:	e40a                	sd	sp,8(sp)
    80005b26:	e80e                	sd	gp,16(sp)
    80005b28:	ec12                	sd	tp,24(sp)
    80005b2a:	f016                	sd	t0,32(sp)
    80005b2c:	f41a                	sd	t1,40(sp)
    80005b2e:	f81e                	sd	t2,48(sp)
    80005b30:	fc22                	sd	s0,56(sp)
    80005b32:	e0a6                	sd	s1,64(sp)
    80005b34:	e4aa                	sd	a0,72(sp)
    80005b36:	e8ae                	sd	a1,80(sp)
    80005b38:	ecb2                	sd	a2,88(sp)
    80005b3a:	f0b6                	sd	a3,96(sp)
    80005b3c:	f4ba                	sd	a4,104(sp)
    80005b3e:	f8be                	sd	a5,112(sp)
    80005b40:	fcc2                	sd	a6,120(sp)
    80005b42:	e146                	sd	a7,128(sp)
    80005b44:	e54a                	sd	s2,136(sp)
    80005b46:	e94e                	sd	s3,144(sp)
    80005b48:	ed52                	sd	s4,152(sp)
    80005b4a:	f156                	sd	s5,160(sp)
    80005b4c:	f55a                	sd	s6,168(sp)
    80005b4e:	f95e                	sd	s7,176(sp)
    80005b50:	fd62                	sd	s8,184(sp)
    80005b52:	e1e6                	sd	s9,192(sp)
    80005b54:	e5ea                	sd	s10,200(sp)
    80005b56:	e9ee                	sd	s11,208(sp)
    80005b58:	edf2                	sd	t3,216(sp)
    80005b5a:	f1f6                	sd	t4,224(sp)
    80005b5c:	f5fa                	sd	t5,232(sp)
    80005b5e:	f9fe                	sd	t6,240(sp)
    80005b60:	dd3fc0ef          	jal	ra,80002932 <kerneltrap>
    80005b64:	6082                	ld	ra,0(sp)
    80005b66:	6122                	ld	sp,8(sp)
    80005b68:	61c2                	ld	gp,16(sp)
    80005b6a:	7282                	ld	t0,32(sp)
    80005b6c:	7322                	ld	t1,40(sp)
    80005b6e:	73c2                	ld	t2,48(sp)
    80005b70:	7462                	ld	s0,56(sp)
    80005b72:	6486                	ld	s1,64(sp)
    80005b74:	6526                	ld	a0,72(sp)
    80005b76:	65c6                	ld	a1,80(sp)
    80005b78:	6666                	ld	a2,88(sp)
    80005b7a:	7686                	ld	a3,96(sp)
    80005b7c:	7726                	ld	a4,104(sp)
    80005b7e:	77c6                	ld	a5,112(sp)
    80005b80:	7866                	ld	a6,120(sp)
    80005b82:	688a                	ld	a7,128(sp)
    80005b84:	692a                	ld	s2,136(sp)
    80005b86:	69ca                	ld	s3,144(sp)
    80005b88:	6a6a                	ld	s4,152(sp)
    80005b8a:	7a8a                	ld	s5,160(sp)
    80005b8c:	7b2a                	ld	s6,168(sp)
    80005b8e:	7bca                	ld	s7,176(sp)
    80005b90:	7c6a                	ld	s8,184(sp)
    80005b92:	6c8e                	ld	s9,192(sp)
    80005b94:	6d2e                	ld	s10,200(sp)
    80005b96:	6dce                	ld	s11,208(sp)
    80005b98:	6e6e                	ld	t3,216(sp)
    80005b9a:	7e8e                	ld	t4,224(sp)
    80005b9c:	7f2e                	ld	t5,232(sp)
    80005b9e:	7fce                	ld	t6,240(sp)
    80005ba0:	6111                	addi	sp,sp,256
    80005ba2:	10200073          	sret
    80005ba6:	00000013          	nop
    80005baa:	00000013          	nop
    80005bae:	0001                	nop

0000000080005bb0 <timervec>:
    80005bb0:	34051573          	csrrw	a0,mscratch,a0
    80005bb4:	e10c                	sd	a1,0(a0)
    80005bb6:	e510                	sd	a2,8(a0)
    80005bb8:	e914                	sd	a3,16(a0)
    80005bba:	6d0c                	ld	a1,24(a0)
    80005bbc:	7110                	ld	a2,32(a0)
    80005bbe:	6194                	ld	a3,0(a1)
    80005bc0:	96b2                	add	a3,a3,a2
    80005bc2:	e194                	sd	a3,0(a1)
    80005bc4:	4589                	li	a1,2
    80005bc6:	14459073          	csrw	sip,a1
    80005bca:	6914                	ld	a3,16(a0)
    80005bcc:	6510                	ld	a2,8(a0)
    80005bce:	610c                	ld	a1,0(a0)
    80005bd0:	34051573          	csrrw	a0,mscratch,a0
    80005bd4:	30200073          	mret
	...

0000000080005bda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bda:	1141                	addi	sp,sp,-16
    80005bdc:	e422                	sd	s0,8(sp)
    80005bde:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005be0:	0c0007b7          	lui	a5,0xc000
    80005be4:	4705                	li	a4,1
    80005be6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005be8:	c3d8                	sw	a4,4(a5)
}
    80005bea:	6422                	ld	s0,8(sp)
    80005bec:	0141                	addi	sp,sp,16
    80005bee:	8082                	ret

0000000080005bf0 <plicinithart>:

void
plicinithart(void)
{
    80005bf0:	1141                	addi	sp,sp,-16
    80005bf2:	e406                	sd	ra,8(sp)
    80005bf4:	e022                	sd	s0,0(sp)
    80005bf6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bf8:	ffffc097          	auipc	ra,0xffffc
    80005bfc:	e1a080e7          	jalr	-486(ra) # 80001a12 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c00:	0085171b          	slliw	a4,a0,0x8
    80005c04:	0c0027b7          	lui	a5,0xc002
    80005c08:	97ba                	add	a5,a5,a4
    80005c0a:	40200713          	li	a4,1026
    80005c0e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c12:	00d5151b          	slliw	a0,a0,0xd
    80005c16:	0c2017b7          	lui	a5,0xc201
    80005c1a:	97aa                	add	a5,a5,a0
    80005c1c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c20:	60a2                	ld	ra,8(sp)
    80005c22:	6402                	ld	s0,0(sp)
    80005c24:	0141                	addi	sp,sp,16
    80005c26:	8082                	ret

0000000080005c28 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c28:	1141                	addi	sp,sp,-16
    80005c2a:	e406                	sd	ra,8(sp)
    80005c2c:	e022                	sd	s0,0(sp)
    80005c2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c30:	ffffc097          	auipc	ra,0xffffc
    80005c34:	de2080e7          	jalr	-542(ra) # 80001a12 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c38:	00d5151b          	slliw	a0,a0,0xd
    80005c3c:	0c2017b7          	lui	a5,0xc201
    80005c40:	97aa                	add	a5,a5,a0
  return irq;
}
    80005c42:	43c8                	lw	a0,4(a5)
    80005c44:	60a2                	ld	ra,8(sp)
    80005c46:	6402                	ld	s0,0(sp)
    80005c48:	0141                	addi	sp,sp,16
    80005c4a:	8082                	ret

0000000080005c4c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c4c:	1101                	addi	sp,sp,-32
    80005c4e:	ec06                	sd	ra,24(sp)
    80005c50:	e822                	sd	s0,16(sp)
    80005c52:	e426                	sd	s1,8(sp)
    80005c54:	1000                	addi	s0,sp,32
    80005c56:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c58:	ffffc097          	auipc	ra,0xffffc
    80005c5c:	dba080e7          	jalr	-582(ra) # 80001a12 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c60:	00d5151b          	slliw	a0,a0,0xd
    80005c64:	0c2017b7          	lui	a5,0xc201
    80005c68:	97aa                	add	a5,a5,a0
    80005c6a:	c3c4                	sw	s1,4(a5)
}
    80005c6c:	60e2                	ld	ra,24(sp)
    80005c6e:	6442                	ld	s0,16(sp)
    80005c70:	64a2                	ld	s1,8(sp)
    80005c72:	6105                	addi	sp,sp,32
    80005c74:	8082                	ret

0000000080005c76 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c76:	1141                	addi	sp,sp,-16
    80005c78:	e406                	sd	ra,8(sp)
    80005c7a:	e022                	sd	s0,0(sp)
    80005c7c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c7e:	479d                	li	a5,7
    80005c80:	06a7c863          	blt	a5,a0,80005cf0 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005c84:	0001d717          	auipc	a4,0x1d
    80005c88:	37c70713          	addi	a4,a4,892 # 80023000 <disk>
    80005c8c:	972a                	add	a4,a4,a0
    80005c8e:	6789                	lui	a5,0x2
    80005c90:	97ba                	add	a5,a5,a4
    80005c92:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005c96:	e7ad                	bnez	a5,80005d00 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c98:	00451793          	slli	a5,a0,0x4
    80005c9c:	0001f717          	auipc	a4,0x1f
    80005ca0:	36470713          	addi	a4,a4,868 # 80025000 <disk+0x2000>
    80005ca4:	6314                	ld	a3,0(a4)
    80005ca6:	96be                	add	a3,a3,a5
    80005ca8:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005cac:	6314                	ld	a3,0(a4)
    80005cae:	96be                	add	a3,a3,a5
    80005cb0:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005cb4:	6314                	ld	a3,0(a4)
    80005cb6:	96be                	add	a3,a3,a5
    80005cb8:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005cbc:	6318                	ld	a4,0(a4)
    80005cbe:	97ba                	add	a5,a5,a4
    80005cc0:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005cc4:	0001d717          	auipc	a4,0x1d
    80005cc8:	33c70713          	addi	a4,a4,828 # 80023000 <disk>
    80005ccc:	972a                	add	a4,a4,a0
    80005cce:	6789                	lui	a5,0x2
    80005cd0:	97ba                	add	a5,a5,a4
    80005cd2:	4705                	li	a4,1
    80005cd4:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005cd8:	0001f517          	auipc	a0,0x1f
    80005cdc:	34050513          	addi	a0,a0,832 # 80025018 <disk+0x2018>
    80005ce0:	ffffc097          	auipc	ra,0xffffc
    80005ce4:	6f4080e7          	jalr	1780(ra) # 800023d4 <wakeup>
}
    80005ce8:	60a2                	ld	ra,8(sp)
    80005cea:	6402                	ld	s0,0(sp)
    80005cec:	0141                	addi	sp,sp,16
    80005cee:	8082                	ret
    panic("free_desc 1");
    80005cf0:	00003517          	auipc	a0,0x3
    80005cf4:	a6050513          	addi	a0,a0,-1440 # 80008750 <syscalls+0x330>
    80005cf8:	ffffb097          	auipc	ra,0xffffb
    80005cfc:	850080e7          	jalr	-1968(ra) # 80000548 <panic>
    panic("free_desc 2");
    80005d00:	00003517          	auipc	a0,0x3
    80005d04:	a6050513          	addi	a0,a0,-1440 # 80008760 <syscalls+0x340>
    80005d08:	ffffb097          	auipc	ra,0xffffb
    80005d0c:	840080e7          	jalr	-1984(ra) # 80000548 <panic>

0000000080005d10 <virtio_disk_init>:
{
    80005d10:	1101                	addi	sp,sp,-32
    80005d12:	ec06                	sd	ra,24(sp)
    80005d14:	e822                	sd	s0,16(sp)
    80005d16:	e426                	sd	s1,8(sp)
    80005d18:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d1a:	00003597          	auipc	a1,0x3
    80005d1e:	a5658593          	addi	a1,a1,-1450 # 80008770 <syscalls+0x350>
    80005d22:	0001f517          	auipc	a0,0x1f
    80005d26:	40650513          	addi	a0,a0,1030 # 80025128 <disk+0x2128>
    80005d2a:	ffffb097          	auipc	ra,0xffffb
    80005d2e:	f2c080e7          	jalr	-212(ra) # 80000c56 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d32:	100017b7          	lui	a5,0x10001
    80005d36:	4398                	lw	a4,0(a5)
    80005d38:	2701                	sext.w	a4,a4
    80005d3a:	747277b7          	lui	a5,0x74727
    80005d3e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d42:	0ef71063          	bne	a4,a5,80005e22 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d46:	100017b7          	lui	a5,0x10001
    80005d4a:	43dc                	lw	a5,4(a5)
    80005d4c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d4e:	4705                	li	a4,1
    80005d50:	0ce79963          	bne	a5,a4,80005e22 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d54:	100017b7          	lui	a5,0x10001
    80005d58:	479c                	lw	a5,8(a5)
    80005d5a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d5c:	4709                	li	a4,2
    80005d5e:	0ce79263          	bne	a5,a4,80005e22 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d62:	100017b7          	lui	a5,0x10001
    80005d66:	47d8                	lw	a4,12(a5)
    80005d68:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d6a:	554d47b7          	lui	a5,0x554d4
    80005d6e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d72:	0af71863          	bne	a4,a5,80005e22 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d76:	100017b7          	lui	a5,0x10001
    80005d7a:	4705                	li	a4,1
    80005d7c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d7e:	470d                	li	a4,3
    80005d80:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d82:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d84:	c7ffe6b7          	lui	a3,0xc7ffe
    80005d88:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005d8c:	8f75                	and	a4,a4,a3
    80005d8e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d90:	472d                	li	a4,11
    80005d92:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d94:	473d                	li	a4,15
    80005d96:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005d98:	6705                	lui	a4,0x1
    80005d9a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d9c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005da0:	5bdc                	lw	a5,52(a5)
    80005da2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005da4:	c7d9                	beqz	a5,80005e32 <virtio_disk_init+0x122>
  if(max < NUM)
    80005da6:	471d                	li	a4,7
    80005da8:	08f77d63          	bgeu	a4,a5,80005e42 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005dac:	100014b7          	lui	s1,0x10001
    80005db0:	47a1                	li	a5,8
    80005db2:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005db4:	6609                	lui	a2,0x2
    80005db6:	4581                	li	a1,0
    80005db8:	0001d517          	auipc	a0,0x1d
    80005dbc:	24850513          	addi	a0,a0,584 # 80023000 <disk>
    80005dc0:	ffffb097          	auipc	ra,0xffffb
    80005dc4:	022080e7          	jalr	34(ra) # 80000de2 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005dc8:	0001d717          	auipc	a4,0x1d
    80005dcc:	23870713          	addi	a4,a4,568 # 80023000 <disk>
    80005dd0:	00c75793          	srli	a5,a4,0xc
    80005dd4:	2781                	sext.w	a5,a5
    80005dd6:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005dd8:	0001f797          	auipc	a5,0x1f
    80005ddc:	22878793          	addi	a5,a5,552 # 80025000 <disk+0x2000>
    80005de0:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005de2:	0001d717          	auipc	a4,0x1d
    80005de6:	29e70713          	addi	a4,a4,670 # 80023080 <disk+0x80>
    80005dea:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005dec:	0001e717          	auipc	a4,0x1e
    80005df0:	21470713          	addi	a4,a4,532 # 80024000 <disk+0x1000>
    80005df4:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005df6:	4705                	li	a4,1
    80005df8:	00e78c23          	sb	a4,24(a5)
    80005dfc:	00e78ca3          	sb	a4,25(a5)
    80005e00:	00e78d23          	sb	a4,26(a5)
    80005e04:	00e78da3          	sb	a4,27(a5)
    80005e08:	00e78e23          	sb	a4,28(a5)
    80005e0c:	00e78ea3          	sb	a4,29(a5)
    80005e10:	00e78f23          	sb	a4,30(a5)
    80005e14:	00e78fa3          	sb	a4,31(a5)
}
    80005e18:	60e2                	ld	ra,24(sp)
    80005e1a:	6442                	ld	s0,16(sp)
    80005e1c:	64a2                	ld	s1,8(sp)
    80005e1e:	6105                	addi	sp,sp,32
    80005e20:	8082                	ret
    panic("could not find virtio disk");
    80005e22:	00003517          	auipc	a0,0x3
    80005e26:	95e50513          	addi	a0,a0,-1698 # 80008780 <syscalls+0x360>
    80005e2a:	ffffa097          	auipc	ra,0xffffa
    80005e2e:	71e080e7          	jalr	1822(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    80005e32:	00003517          	auipc	a0,0x3
    80005e36:	96e50513          	addi	a0,a0,-1682 # 800087a0 <syscalls+0x380>
    80005e3a:	ffffa097          	auipc	ra,0xffffa
    80005e3e:	70e080e7          	jalr	1806(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    80005e42:	00003517          	auipc	a0,0x3
    80005e46:	97e50513          	addi	a0,a0,-1666 # 800087c0 <syscalls+0x3a0>
    80005e4a:	ffffa097          	auipc	ra,0xffffa
    80005e4e:	6fe080e7          	jalr	1790(ra) # 80000548 <panic>

0000000080005e52 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005e52:	7159                	addi	sp,sp,-112
    80005e54:	f486                	sd	ra,104(sp)
    80005e56:	f0a2                	sd	s0,96(sp)
    80005e58:	eca6                	sd	s1,88(sp)
    80005e5a:	e8ca                	sd	s2,80(sp)
    80005e5c:	e4ce                	sd	s3,72(sp)
    80005e5e:	e0d2                	sd	s4,64(sp)
    80005e60:	fc56                	sd	s5,56(sp)
    80005e62:	f85a                	sd	s6,48(sp)
    80005e64:	f45e                	sd	s7,40(sp)
    80005e66:	f062                	sd	s8,32(sp)
    80005e68:	ec66                	sd	s9,24(sp)
    80005e6a:	e86a                	sd	s10,16(sp)
    80005e6c:	1880                	addi	s0,sp,112
    80005e6e:	8a2a                	mv	s4,a0
    80005e70:	8cae                	mv	s9,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e72:	00c52c03          	lw	s8,12(a0)
    80005e76:	001c1c1b          	slliw	s8,s8,0x1
    80005e7a:	1c02                	slli	s8,s8,0x20
    80005e7c:	020c5c13          	srli	s8,s8,0x20

  acquire(&disk.vdisk_lock);
    80005e80:	0001f517          	auipc	a0,0x1f
    80005e84:	2a850513          	addi	a0,a0,680 # 80025128 <disk+0x2128>
    80005e88:	ffffb097          	auipc	ra,0xffffb
    80005e8c:	e5e080e7          	jalr	-418(ra) # 80000ce6 <acquire>
  for(int i = 0; i < 3; i++){
    80005e90:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80005e92:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005e94:	0001db97          	auipc	s7,0x1d
    80005e98:	16cb8b93          	addi	s7,s7,364 # 80023000 <disk>
    80005e9c:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005e9e:	4a8d                	li	s5,3
    80005ea0:	a0b5                	j	80005f0c <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005ea2:	00fb8733          	add	a4,s7,a5
    80005ea6:	975a                	add	a4,a4,s6
    80005ea8:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005eac:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80005eae:	0207c563          	bltz	a5,80005ed8 <virtio_disk_rw+0x86>
  for(int i = 0; i < 3; i++){
    80005eb2:	2605                	addiw	a2,a2,1 # 2001 <_entry-0x7fffdfff>
    80005eb4:	0591                	addi	a1,a1,4
    80005eb6:	19560c63          	beq	a2,s5,8000604e <virtio_disk_rw+0x1fc>
    idx[i] = alloc_desc();
    80005eba:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80005ebc:	0001f717          	auipc	a4,0x1f
    80005ec0:	15c70713          	addi	a4,a4,348 # 80025018 <disk+0x2018>
    80005ec4:	87ca                	mv	a5,s2
    if(disk.free[i]){
    80005ec6:	00074683          	lbu	a3,0(a4)
    80005eca:	fee1                	bnez	a3,80005ea2 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005ecc:	2785                	addiw	a5,a5,1
    80005ece:	0705                	addi	a4,a4,1
    80005ed0:	fe979be3          	bne	a5,s1,80005ec6 <virtio_disk_rw+0x74>
    idx[i] = alloc_desc();
    80005ed4:	57fd                	li	a5,-1
    80005ed6:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    80005ed8:	00c05e63          	blez	a2,80005ef4 <virtio_disk_rw+0xa2>
    80005edc:	060a                	slli	a2,a2,0x2
    80005ede:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80005ee2:	0009a503          	lw	a0,0(s3)
    80005ee6:	00000097          	auipc	ra,0x0
    80005eea:	d90080e7          	jalr	-624(ra) # 80005c76 <free_desc>
      for(int j = 0; j < i; j++)
    80005eee:	0991                	addi	s3,s3,4
    80005ef0:	ffa999e3          	bne	s3,s10,80005ee2 <virtio_disk_rw+0x90>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ef4:	0001f597          	auipc	a1,0x1f
    80005ef8:	23458593          	addi	a1,a1,564 # 80025128 <disk+0x2128>
    80005efc:	0001f517          	auipc	a0,0x1f
    80005f00:	11c50513          	addi	a0,a0,284 # 80025018 <disk+0x2018>
    80005f04:	ffffc097          	auipc	ra,0xffffc
    80005f08:	350080e7          	jalr	848(ra) # 80002254 <sleep>
  for(int i = 0; i < 3; i++){
    80005f0c:	f9040993          	addi	s3,s0,-112
{
    80005f10:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80005f12:	864a                	mv	a2,s2
    80005f14:	b75d                	j	80005eba <virtio_disk_rw+0x68>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005f16:	0001f697          	auipc	a3,0x1f
    80005f1a:	0ea6b683          	ld	a3,234(a3) # 80025000 <disk+0x2000>
    80005f1e:	96ba                	add	a3,a3,a4
    80005f20:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005f24:	0001d817          	auipc	a6,0x1d
    80005f28:	0dc80813          	addi	a6,a6,220 # 80023000 <disk>
    80005f2c:	0001f697          	auipc	a3,0x1f
    80005f30:	0d468693          	addi	a3,a3,212 # 80025000 <disk+0x2000>
    80005f34:	6290                	ld	a2,0(a3)
    80005f36:	963a                	add	a2,a2,a4
    80005f38:	00c65583          	lhu	a1,12(a2)
    80005f3c:	0015e593          	ori	a1,a1,1
    80005f40:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80005f44:	f9842603          	lw	a2,-104(s0)
    80005f48:	628c                	ld	a1,0(a3)
    80005f4a:	972e                	add	a4,a4,a1
    80005f4c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005f50:	20050593          	addi	a1,a0,512
    80005f54:	0592                	slli	a1,a1,0x4
    80005f56:	95c2                	add	a1,a1,a6
    80005f58:	577d                	li	a4,-1
    80005f5a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005f5e:	00461713          	slli	a4,a2,0x4
    80005f62:	6290                	ld	a2,0(a3)
    80005f64:	963a                	add	a2,a2,a4
    80005f66:	03078793          	addi	a5,a5,48
    80005f6a:	97c2                	add	a5,a5,a6
    80005f6c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80005f6e:	629c                	ld	a5,0(a3)
    80005f70:	97ba                	add	a5,a5,a4
    80005f72:	4605                	li	a2,1
    80005f74:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f76:	629c                	ld	a5,0(a3)
    80005f78:	97ba                	add	a5,a5,a4
    80005f7a:	4809                	li	a6,2
    80005f7c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80005f80:	629c                	ld	a5,0(a3)
    80005f82:	97ba                	add	a5,a5,a4
    80005f84:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005f88:	00ca2223          	sw	a2,4(s4)
  disk.info[idx[0]].b = b;
    80005f8c:	0345b423          	sd	s4,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005f90:	6698                	ld	a4,8(a3)
    80005f92:	00275783          	lhu	a5,2(a4)
    80005f96:	8b9d                	andi	a5,a5,7
    80005f98:	0786                	slli	a5,a5,0x1
    80005f9a:	973e                	add	a4,a4,a5
    80005f9c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80005fa0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005fa4:	6698                	ld	a4,8(a3)
    80005fa6:	00275783          	lhu	a5,2(a4)
    80005faa:	2785                	addiw	a5,a5,1
    80005fac:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005fb0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005fb4:	100017b7          	lui	a5,0x10001
    80005fb8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005fbc:	004a2783          	lw	a5,4(s4)
    80005fc0:	02c79163          	bne	a5,a2,80005fe2 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80005fc4:	0001f917          	auipc	s2,0x1f
    80005fc8:	16490913          	addi	s2,s2,356 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80005fcc:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005fce:	85ca                	mv	a1,s2
    80005fd0:	8552                	mv	a0,s4
    80005fd2:	ffffc097          	auipc	ra,0xffffc
    80005fd6:	282080e7          	jalr	642(ra) # 80002254 <sleep>
  while(b->disk == 1) {
    80005fda:	004a2783          	lw	a5,4(s4)
    80005fde:	fe9788e3          	beq	a5,s1,80005fce <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80005fe2:	f9042903          	lw	s2,-112(s0)
    80005fe6:	20090713          	addi	a4,s2,512
    80005fea:	0712                	slli	a4,a4,0x4
    80005fec:	0001d797          	auipc	a5,0x1d
    80005ff0:	01478793          	addi	a5,a5,20 # 80023000 <disk>
    80005ff4:	97ba                	add	a5,a5,a4
    80005ff6:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80005ffa:	0001f997          	auipc	s3,0x1f
    80005ffe:	00698993          	addi	s3,s3,6 # 80025000 <disk+0x2000>
    80006002:	00491713          	slli	a4,s2,0x4
    80006006:	0009b783          	ld	a5,0(s3)
    8000600a:	97ba                	add	a5,a5,a4
    8000600c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006010:	854a                	mv	a0,s2
    80006012:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006016:	00000097          	auipc	ra,0x0
    8000601a:	c60080e7          	jalr	-928(ra) # 80005c76 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000601e:	8885                	andi	s1,s1,1
    80006020:	f0ed                	bnez	s1,80006002 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006022:	0001f517          	auipc	a0,0x1f
    80006026:	10650513          	addi	a0,a0,262 # 80025128 <disk+0x2128>
    8000602a:	ffffb097          	auipc	ra,0xffffb
    8000602e:	d70080e7          	jalr	-656(ra) # 80000d9a <release>
}
    80006032:	70a6                	ld	ra,104(sp)
    80006034:	7406                	ld	s0,96(sp)
    80006036:	64e6                	ld	s1,88(sp)
    80006038:	6946                	ld	s2,80(sp)
    8000603a:	69a6                	ld	s3,72(sp)
    8000603c:	6a06                	ld	s4,64(sp)
    8000603e:	7ae2                	ld	s5,56(sp)
    80006040:	7b42                	ld	s6,48(sp)
    80006042:	7ba2                	ld	s7,40(sp)
    80006044:	7c02                	ld	s8,32(sp)
    80006046:	6ce2                	ld	s9,24(sp)
    80006048:	6d42                	ld	s10,16(sp)
    8000604a:	6165                	addi	sp,sp,112
    8000604c:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000604e:	f9042503          	lw	a0,-112(s0)
    80006052:	20050793          	addi	a5,a0,512
    80006056:	0792                	slli	a5,a5,0x4
  if(write)
    80006058:	0001d817          	auipc	a6,0x1d
    8000605c:	fa880813          	addi	a6,a6,-88 # 80023000 <disk>
    80006060:	00f80733          	add	a4,a6,a5
    80006064:	019036b3          	snez	a3,s9
    80006068:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000606c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006070:	0b873823          	sd	s8,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006074:	7679                	lui	a2,0xffffe
    80006076:	963e                	add	a2,a2,a5
    80006078:	0001f697          	auipc	a3,0x1f
    8000607c:	f8868693          	addi	a3,a3,-120 # 80025000 <disk+0x2000>
    80006080:	6298                	ld	a4,0(a3)
    80006082:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006084:	0a878593          	addi	a1,a5,168
    80006088:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000608a:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000608c:	6298                	ld	a4,0(a3)
    8000608e:	9732                	add	a4,a4,a2
    80006090:	45c1                	li	a1,16
    80006092:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006094:	6298                	ld	a4,0(a3)
    80006096:	9732                	add	a4,a4,a2
    80006098:	4585                	li	a1,1
    8000609a:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    8000609e:	f9442703          	lw	a4,-108(s0)
    800060a2:	628c                	ld	a1,0(a3)
    800060a4:	962e                	add	a2,a2,a1
    800060a6:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800060aa:	0712                	slli	a4,a4,0x4
    800060ac:	6290                	ld	a2,0(a3)
    800060ae:	963a                	add	a2,a2,a4
    800060b0:	058a0593          	addi	a1,s4,88
    800060b4:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800060b6:	6294                	ld	a3,0(a3)
    800060b8:	96ba                	add	a3,a3,a4
    800060ba:	40000613          	li	a2,1024
    800060be:	c690                	sw	a2,8(a3)
  if(write)
    800060c0:	e40c9be3          	bnez	s9,80005f16 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800060c4:	0001f697          	auipc	a3,0x1f
    800060c8:	f3c6b683          	ld	a3,-196(a3) # 80025000 <disk+0x2000>
    800060cc:	96ba                	add	a3,a3,a4
    800060ce:	4609                	li	a2,2
    800060d0:	00c69623          	sh	a2,12(a3)
    800060d4:	bd81                	j	80005f24 <virtio_disk_rw+0xd2>

00000000800060d6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800060d6:	1101                	addi	sp,sp,-32
    800060d8:	ec06                	sd	ra,24(sp)
    800060da:	e822                	sd	s0,16(sp)
    800060dc:	e426                	sd	s1,8(sp)
    800060de:	e04a                	sd	s2,0(sp)
    800060e0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800060e2:	0001f517          	auipc	a0,0x1f
    800060e6:	04650513          	addi	a0,a0,70 # 80025128 <disk+0x2128>
    800060ea:	ffffb097          	auipc	ra,0xffffb
    800060ee:	bfc080e7          	jalr	-1028(ra) # 80000ce6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800060f2:	10001737          	lui	a4,0x10001
    800060f6:	533c                	lw	a5,96(a4)
    800060f8:	8b8d                	andi	a5,a5,3
    800060fa:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800060fc:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006100:	0001f797          	auipc	a5,0x1f
    80006104:	f0078793          	addi	a5,a5,-256 # 80025000 <disk+0x2000>
    80006108:	6b94                	ld	a3,16(a5)
    8000610a:	0207d703          	lhu	a4,32(a5)
    8000610e:	0026d783          	lhu	a5,2(a3)
    80006112:	06f70163          	beq	a4,a5,80006174 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006116:	0001d917          	auipc	s2,0x1d
    8000611a:	eea90913          	addi	s2,s2,-278 # 80023000 <disk>
    8000611e:	0001f497          	auipc	s1,0x1f
    80006122:	ee248493          	addi	s1,s1,-286 # 80025000 <disk+0x2000>
    __sync_synchronize();
    80006126:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000612a:	6898                	ld	a4,16(s1)
    8000612c:	0204d783          	lhu	a5,32(s1)
    80006130:	8b9d                	andi	a5,a5,7
    80006132:	078e                	slli	a5,a5,0x3
    80006134:	97ba                	add	a5,a5,a4
    80006136:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006138:	20078713          	addi	a4,a5,512
    8000613c:	0712                	slli	a4,a4,0x4
    8000613e:	974a                	add	a4,a4,s2
    80006140:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006144:	e731                	bnez	a4,80006190 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006146:	20078793          	addi	a5,a5,512
    8000614a:	0792                	slli	a5,a5,0x4
    8000614c:	97ca                	add	a5,a5,s2
    8000614e:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006150:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006154:	ffffc097          	auipc	ra,0xffffc
    80006158:	280080e7          	jalr	640(ra) # 800023d4 <wakeup>

    disk.used_idx += 1;
    8000615c:	0204d783          	lhu	a5,32(s1)
    80006160:	2785                	addiw	a5,a5,1
    80006162:	17c2                	slli	a5,a5,0x30
    80006164:	93c1                	srli	a5,a5,0x30
    80006166:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000616a:	6898                	ld	a4,16(s1)
    8000616c:	00275703          	lhu	a4,2(a4)
    80006170:	faf71be3          	bne	a4,a5,80006126 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006174:	0001f517          	auipc	a0,0x1f
    80006178:	fb450513          	addi	a0,a0,-76 # 80025128 <disk+0x2128>
    8000617c:	ffffb097          	auipc	ra,0xffffb
    80006180:	c1e080e7          	jalr	-994(ra) # 80000d9a <release>
}
    80006184:	60e2                	ld	ra,24(sp)
    80006186:	6442                	ld	s0,16(sp)
    80006188:	64a2                	ld	s1,8(sp)
    8000618a:	6902                	ld	s2,0(sp)
    8000618c:	6105                	addi	sp,sp,32
    8000618e:	8082                	ret
      panic("virtio_disk_intr status");
    80006190:	00002517          	auipc	a0,0x2
    80006194:	65050513          	addi	a0,a0,1616 # 800087e0 <syscalls+0x3c0>
    80006198:	ffffa097          	auipc	ra,0xffffa
    8000619c:	3b0080e7          	jalr	944(ra) # 80000548 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
