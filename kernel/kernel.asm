
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
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fde70713          	addi	a4,a4,-34 # 80009030 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	f9c78793          	addi	a5,a5,-100 # 80006000 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd67d7>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	2c678793          	addi	a5,a5,710 # 80001374 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
    80000106:	8a2a                	mv	s4,a0
    80000108:	84ae                	mv	s1,a1
    8000010a:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    8000010c:	00011517          	auipc	a0,0x11
    80000110:	06450513          	addi	a0,a0,100 # 80011170 <cons>
    80000114:	00001097          	auipc	ra,0x1
    80000118:	cce080e7          	jalr	-818(ra) # 80000de2 <acquire>
  for(i = 0; i < n; i++){
    8000011c:	05305b63          	blez	s3,80000172 <consolewrite+0x7e>
    80000120:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000122:	5afd                	li	s5,-1
    80000124:	4685                	li	a3,1
    80000126:	8626                	mv	a2,s1
    80000128:	85d2                	mv	a1,s4
    8000012a:	fbf40513          	addi	a0,s0,-65
    8000012e:	00002097          	auipc	ra,0x2
    80000132:	7c2080e7          	jalr	1986(ra) # 800028f0 <either_copyin>
    80000136:	01550c63          	beq	a0,s5,8000014e <consolewrite+0x5a>
      break;
    uartputc(c);
    8000013a:	fbf44503          	lbu	a0,-65(s0)
    8000013e:	00000097          	auipc	ra,0x0
    80000142:	7aa080e7          	jalr	1962(ra) # 800008e8 <uartputc>
  for(i = 0; i < n; i++){
    80000146:	2905                	addiw	s2,s2,1
    80000148:	0485                	addi	s1,s1,1
    8000014a:	fd299de3          	bne	s3,s2,80000124 <consolewrite+0x30>
  }
  release(&cons.lock);
    8000014e:	00011517          	auipc	a0,0x11
    80000152:	02250513          	addi	a0,a0,34 # 80011170 <cons>
    80000156:	00001097          	auipc	ra,0x1
    8000015a:	d5c080e7          	jalr	-676(ra) # 80000eb2 <release>

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
    80000174:	bfe9                	j	8000014e <consolewrite+0x5a>

0000000080000176 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	7119                	addi	sp,sp,-128
    80000178:	fc86                	sd	ra,120(sp)
    8000017a:	f8a2                	sd	s0,112(sp)
    8000017c:	f4a6                	sd	s1,104(sp)
    8000017e:	f0ca                	sd	s2,96(sp)
    80000180:	ecce                	sd	s3,88(sp)
    80000182:	e8d2                	sd	s4,80(sp)
    80000184:	e4d6                	sd	s5,72(sp)
    80000186:	e0da                	sd	s6,64(sp)
    80000188:	fc5e                	sd	s7,56(sp)
    8000018a:	f862                	sd	s8,48(sp)
    8000018c:	f466                	sd	s9,40(sp)
    8000018e:	f06a                	sd	s10,32(sp)
    80000190:	ec6e                	sd	s11,24(sp)
    80000192:	0100                	addi	s0,sp,128
    80000194:	8b2a                	mv	s6,a0
    80000196:	8aae                	mv	s5,a1
    80000198:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000019a:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000019e:	00011517          	auipc	a0,0x11
    800001a2:	fd250513          	addi	a0,a0,-46 # 80011170 <cons>
    800001a6:	00001097          	auipc	ra,0x1
    800001aa:	c3c080e7          	jalr	-964(ra) # 80000de2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ae:	00011497          	auipc	s1,0x11
    800001b2:	fc248493          	addi	s1,s1,-62 # 80011170 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b6:	89a6                	mv	s3,s1
    800001b8:	00011917          	auipc	s2,0x11
    800001bc:	05890913          	addi	s2,s2,88 # 80011210 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001c0:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c2:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001c4:	4da9                	li	s11,10
  while(n > 0){
    800001c6:	07405863          	blez	s4,80000236 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001ca:	0a04a783          	lw	a5,160(s1)
    800001ce:	0a44a703          	lw	a4,164(s1)
    800001d2:	02f71463          	bne	a4,a5,800001fa <consoleread+0x84>
      if(myproc()->killed){
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	c54080e7          	jalr	-940(ra) # 80001e2a <myproc>
    800001de:	5d1c                	lw	a5,56(a0)
    800001e0:	e7b5                	bnez	a5,8000024c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001e2:	85ce                	mv	a1,s3
    800001e4:	854a                	mv	a0,s2
    800001e6:	00002097          	auipc	ra,0x2
    800001ea:	454080e7          	jalr	1108(ra) # 8000263a <sleep>
    while(cons.r == cons.w){
    800001ee:	0a04a783          	lw	a5,160(s1)
    800001f2:	0a44a703          	lw	a4,164(s1)
    800001f6:	fef700e3          	beq	a4,a5,800001d6 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001fa:	0017871b          	addiw	a4,a5,1
    800001fe:	0ae4a023          	sw	a4,160(s1)
    80000202:	07f7f713          	andi	a4,a5,127
    80000206:	9726                	add	a4,a4,s1
    80000208:	02074703          	lbu	a4,32(a4)
    8000020c:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000210:	079c0663          	beq	s8,s9,8000027c <consoleread+0x106>
    cbuf = c;
    80000214:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000218:	4685                	li	a3,1
    8000021a:	f8f40613          	addi	a2,s0,-113
    8000021e:	85d6                	mv	a1,s5
    80000220:	855a                	mv	a0,s6
    80000222:	00002097          	auipc	ra,0x2
    80000226:	678080e7          	jalr	1656(ra) # 8000289a <either_copyout>
    8000022a:	01a50663          	beq	a0,s10,80000236 <consoleread+0xc0>
    dst++;
    8000022e:	0a85                	addi	s5,s5,1
    --n;
    80000230:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000232:	f9bc1ae3          	bne	s8,s11,800001c6 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	f3a50513          	addi	a0,a0,-198 # 80011170 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	c74080e7          	jalr	-908(ra) # 80000eb2 <release>

  return target - n;
    80000246:	414b853b          	subw	a0,s7,s4
    8000024a:	a811                	j	8000025e <consoleread+0xe8>
        release(&cons.lock);
    8000024c:	00011517          	auipc	a0,0x11
    80000250:	f2450513          	addi	a0,a0,-220 # 80011170 <cons>
    80000254:	00001097          	auipc	ra,0x1
    80000258:	c5e080e7          	jalr	-930(ra) # 80000eb2 <release>
        return -1;
    8000025c:	557d                	li	a0,-1
}
    8000025e:	70e6                	ld	ra,120(sp)
    80000260:	7446                	ld	s0,112(sp)
    80000262:	74a6                	ld	s1,104(sp)
    80000264:	7906                	ld	s2,96(sp)
    80000266:	69e6                	ld	s3,88(sp)
    80000268:	6a46                	ld	s4,80(sp)
    8000026a:	6aa6                	ld	s5,72(sp)
    8000026c:	6b06                	ld	s6,64(sp)
    8000026e:	7be2                	ld	s7,56(sp)
    80000270:	7c42                	ld	s8,48(sp)
    80000272:	7ca2                	ld	s9,40(sp)
    80000274:	7d02                	ld	s10,32(sp)
    80000276:	6de2                	ld	s11,24(sp)
    80000278:	6109                	addi	sp,sp,128
    8000027a:	8082                	ret
      if(n < target){
    8000027c:	000a071b          	sext.w	a4,s4
    80000280:	fb777be3          	bgeu	a4,s7,80000236 <consoleread+0xc0>
        cons.r--;
    80000284:	00011717          	auipc	a4,0x11
    80000288:	f8f72623          	sw	a5,-116(a4) # 80011210 <cons+0xa0>
    8000028c:	b76d                	j	80000236 <consoleread+0xc0>

000000008000028e <consputc>:
{
    8000028e:	1141                	addi	sp,sp,-16
    80000290:	e406                	sd	ra,8(sp)
    80000292:	e022                	sd	s0,0(sp)
    80000294:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000296:	10000793          	li	a5,256
    8000029a:	00f50a63          	beq	a0,a5,800002ae <consputc+0x20>
    uartputc_sync(c);
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	564080e7          	jalr	1380(ra) # 80000802 <uartputc_sync>
}
    800002a6:	60a2                	ld	ra,8(sp)
    800002a8:	6402                	ld	s0,0(sp)
    800002aa:	0141                	addi	sp,sp,16
    800002ac:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	552080e7          	jalr	1362(ra) # 80000802 <uartputc_sync>
    800002b8:	02000513          	li	a0,32
    800002bc:	00000097          	auipc	ra,0x0
    800002c0:	546080e7          	jalr	1350(ra) # 80000802 <uartputc_sync>
    800002c4:	4521                	li	a0,8
    800002c6:	00000097          	auipc	ra,0x0
    800002ca:	53c080e7          	jalr	1340(ra) # 80000802 <uartputc_sync>
    800002ce:	bfe1                	j	800002a6 <consputc+0x18>

00000000800002d0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d0:	1101                	addi	sp,sp,-32
    800002d2:	ec06                	sd	ra,24(sp)
    800002d4:	e822                	sd	s0,16(sp)
    800002d6:	e426                	sd	s1,8(sp)
    800002d8:	e04a                	sd	s2,0(sp)
    800002da:	1000                	addi	s0,sp,32
    800002dc:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002de:	00011517          	auipc	a0,0x11
    800002e2:	e9250513          	addi	a0,a0,-366 # 80011170 <cons>
    800002e6:	00001097          	auipc	ra,0x1
    800002ea:	afc080e7          	jalr	-1284(ra) # 80000de2 <acquire>

  switch(c){
    800002ee:	47d5                	li	a5,21
    800002f0:	0af48663          	beq	s1,a5,8000039c <consoleintr+0xcc>
    800002f4:	0297ca63          	blt	a5,s1,80000328 <consoleintr+0x58>
    800002f8:	47a1                	li	a5,8
    800002fa:	0ef48763          	beq	s1,a5,800003e8 <consoleintr+0x118>
    800002fe:	47c1                	li	a5,16
    80000300:	10f49a63          	bne	s1,a5,80000414 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000304:	00002097          	auipc	ra,0x2
    80000308:	642080e7          	jalr	1602(ra) # 80002946 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030c:	00011517          	auipc	a0,0x11
    80000310:	e6450513          	addi	a0,a0,-412 # 80011170 <cons>
    80000314:	00001097          	auipc	ra,0x1
    80000318:	b9e080e7          	jalr	-1122(ra) # 80000eb2 <release>
}
    8000031c:	60e2                	ld	ra,24(sp)
    8000031e:	6442                	ld	s0,16(sp)
    80000320:	64a2                	ld	s1,8(sp)
    80000322:	6902                	ld	s2,0(sp)
    80000324:	6105                	addi	sp,sp,32
    80000326:	8082                	ret
  switch(c){
    80000328:	07f00793          	li	a5,127
    8000032c:	0af48e63          	beq	s1,a5,800003e8 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000330:	00011717          	auipc	a4,0x11
    80000334:	e4070713          	addi	a4,a4,-448 # 80011170 <cons>
    80000338:	0a872783          	lw	a5,168(a4)
    8000033c:	0a072703          	lw	a4,160(a4)
    80000340:	9f99                	subw	a5,a5,a4
    80000342:	07f00713          	li	a4,127
    80000346:	fcf763e3          	bltu	a4,a5,8000030c <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000034a:	47b5                	li	a5,13
    8000034c:	0cf48763          	beq	s1,a5,8000041a <consoleintr+0x14a>
      consputc(c);
    80000350:	8526                	mv	a0,s1
    80000352:	00000097          	auipc	ra,0x0
    80000356:	f3c080e7          	jalr	-196(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000035a:	00011797          	auipc	a5,0x11
    8000035e:	e1678793          	addi	a5,a5,-490 # 80011170 <cons>
    80000362:	0a87a703          	lw	a4,168(a5)
    80000366:	0017069b          	addiw	a3,a4,1
    8000036a:	0006861b          	sext.w	a2,a3
    8000036e:	0ad7a423          	sw	a3,168(a5)
    80000372:	07f77713          	andi	a4,a4,127
    80000376:	97ba                	add	a5,a5,a4
    80000378:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000037c:	47a9                	li	a5,10
    8000037e:	0cf48563          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000382:	4791                	li	a5,4
    80000384:	0cf48263          	beq	s1,a5,80000448 <consoleintr+0x178>
    80000388:	00011797          	auipc	a5,0x11
    8000038c:	e887a783          	lw	a5,-376(a5) # 80011210 <cons+0xa0>
    80000390:	0807879b          	addiw	a5,a5,128
    80000394:	f6f61ce3          	bne	a2,a5,8000030c <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000398:	863e                	mv	a2,a5
    8000039a:	a07d                	j	80000448 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000039c:	00011717          	auipc	a4,0x11
    800003a0:	dd470713          	addi	a4,a4,-556 # 80011170 <cons>
    800003a4:	0a872783          	lw	a5,168(a4)
    800003a8:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ac:	00011497          	auipc	s1,0x11
    800003b0:	dc448493          	addi	s1,s1,-572 # 80011170 <cons>
    while(cons.e != cons.w &&
    800003b4:	4929                	li	s2,10
    800003b6:	f4f70be3          	beq	a4,a5,8000030c <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ba:	37fd                	addiw	a5,a5,-1
    800003bc:	07f7f713          	andi	a4,a5,127
    800003c0:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c2:	02074703          	lbu	a4,32(a4)
    800003c6:	f52703e3          	beq	a4,s2,8000030c <consoleintr+0x3c>
      cons.e--;
    800003ca:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003ce:	10000513          	li	a0,256
    800003d2:	00000097          	auipc	ra,0x0
    800003d6:	ebc080e7          	jalr	-324(ra) # 8000028e <consputc>
    while(cons.e != cons.w &&
    800003da:	0a84a783          	lw	a5,168(s1)
    800003de:	0a44a703          	lw	a4,164(s1)
    800003e2:	fcf71ce3          	bne	a4,a5,800003ba <consoleintr+0xea>
    800003e6:	b71d                	j	8000030c <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	d8870713          	addi	a4,a4,-632 # 80011170 <cons>
    800003f0:	0a872783          	lw	a5,168(a4)
    800003f4:	0a472703          	lw	a4,164(a4)
    800003f8:	f0f70ae3          	beq	a4,a5,8000030c <consoleintr+0x3c>
      cons.e--;
    800003fc:	37fd                	addiw	a5,a5,-1
    800003fe:	00011717          	auipc	a4,0x11
    80000402:	e0f72d23          	sw	a5,-486(a4) # 80011218 <cons+0xa8>
      consputc(BACKSPACE);
    80000406:	10000513          	li	a0,256
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e84080e7          	jalr	-380(ra) # 8000028e <consputc>
    80000412:	bded                	j	8000030c <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000414:	ee048ce3          	beqz	s1,8000030c <consoleintr+0x3c>
    80000418:	bf21                	j	80000330 <consoleintr+0x60>
      consputc(c);
    8000041a:	4529                	li	a0,10
    8000041c:	00000097          	auipc	ra,0x0
    80000420:	e72080e7          	jalr	-398(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000424:	00011797          	auipc	a5,0x11
    80000428:	d4c78793          	addi	a5,a5,-692 # 80011170 <cons>
    8000042c:	0a87a703          	lw	a4,168(a5)
    80000430:	0017069b          	addiw	a3,a4,1
    80000434:	0006861b          	sext.w	a2,a3
    80000438:	0ad7a423          	sw	a3,168(a5)
    8000043c:	07f77713          	andi	a4,a4,127
    80000440:	97ba                	add	a5,a5,a4
    80000442:	4729                	li	a4,10
    80000444:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000448:	00011797          	auipc	a5,0x11
    8000044c:	dcc7a623          	sw	a2,-564(a5) # 80011214 <cons+0xa4>
        wakeup(&cons.r);
    80000450:	00011517          	auipc	a0,0x11
    80000454:	dc050513          	addi	a0,a0,-576 # 80011210 <cons+0xa0>
    80000458:	00002097          	auipc	ra,0x2
    8000045c:	368080e7          	jalr	872(ra) # 800027c0 <wakeup>
    80000460:	b575                	j	8000030c <consoleintr+0x3c>

0000000080000462 <consoleinit>:

void
consoleinit(void)
{
    80000462:	1141                	addi	sp,sp,-16
    80000464:	e406                	sd	ra,8(sp)
    80000466:	e022                	sd	s0,0(sp)
    80000468:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000046a:	00008597          	auipc	a1,0x8
    8000046e:	ba658593          	addi	a1,a1,-1114 # 80008010 <etext+0x10>
    80000472:	00011517          	auipc	a0,0x11
    80000476:	cfe50513          	addi	a0,a0,-770 # 80011170 <cons>
    8000047a:	00001097          	auipc	ra,0x1
    8000047e:	ae4080e7          	jalr	-1308(ra) # 80000f5e <initlock>

  uartinit();
    80000482:	00000097          	auipc	ra,0x0
    80000486:	330080e7          	jalr	816(ra) # 800007b2 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048a:	00022797          	auipc	a5,0x22
    8000048e:	40e78793          	addi	a5,a5,1038 # 80022898 <devsw>
    80000492:	00000717          	auipc	a4,0x0
    80000496:	ce470713          	addi	a4,a4,-796 # 80000176 <consoleread>
    8000049a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000049c:	00000717          	auipc	a4,0x0
    800004a0:	c5870713          	addi	a4,a4,-936 # 800000f4 <consolewrite>
    800004a4:	ef98                	sd	a4,24(a5)
}
    800004a6:	60a2                	ld	ra,8(sp)
    800004a8:	6402                	ld	s0,0(sp)
    800004aa:	0141                	addi	sp,sp,16
    800004ac:	8082                	ret

00000000800004ae <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ae:	7179                	addi	sp,sp,-48
    800004b0:	f406                	sd	ra,40(sp)
    800004b2:	f022                	sd	s0,32(sp)
    800004b4:	ec26                	sd	s1,24(sp)
    800004b6:	e84a                	sd	s2,16(sp)
    800004b8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ba:	c219                	beqz	a2,800004c0 <printint+0x12>
    800004bc:	08054663          	bltz	a0,80000548 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004c0:	2501                	sext.w	a0,a0
    800004c2:	4881                	li	a7,0
    800004c4:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004ca:	2581                	sext.w	a1,a1
    800004cc:	00008617          	auipc	a2,0x8
    800004d0:	b7460613          	addi	a2,a2,-1164 # 80008040 <digits>
    800004d4:	883a                	mv	a6,a4
    800004d6:	2705                	addiw	a4,a4,1
    800004d8:	02b577bb          	remuw	a5,a0,a1
    800004dc:	1782                	slli	a5,a5,0x20
    800004de:	9381                	srli	a5,a5,0x20
    800004e0:	97b2                	add	a5,a5,a2
    800004e2:	0007c783          	lbu	a5,0(a5)
    800004e6:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ea:	0005079b          	sext.w	a5,a0
    800004ee:	02b5553b          	divuw	a0,a0,a1
    800004f2:	0685                	addi	a3,a3,1
    800004f4:	feb7f0e3          	bgeu	a5,a1,800004d4 <printint+0x26>

  if(sign)
    800004f8:	00088b63          	beqz	a7,8000050e <printint+0x60>
    buf[i++] = '-';
    800004fc:	fe040793          	addi	a5,s0,-32
    80000500:	973e                	add	a4,a4,a5
    80000502:	02d00793          	li	a5,45
    80000506:	fef70823          	sb	a5,-16(a4)
    8000050a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000050e:	02e05763          	blez	a4,8000053c <printint+0x8e>
    80000512:	fd040793          	addi	a5,s0,-48
    80000516:	00e784b3          	add	s1,a5,a4
    8000051a:	fff78913          	addi	s2,a5,-1
    8000051e:	993a                	add	s2,s2,a4
    80000520:	377d                	addiw	a4,a4,-1
    80000522:	1702                	slli	a4,a4,0x20
    80000524:	9301                	srli	a4,a4,0x20
    80000526:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000052a:	fff4c503          	lbu	a0,-1(s1)
    8000052e:	00000097          	auipc	ra,0x0
    80000532:	d60080e7          	jalr	-672(ra) # 8000028e <consputc>
  while(--i >= 0)
    80000536:	14fd                	addi	s1,s1,-1
    80000538:	ff2499e3          	bne	s1,s2,8000052a <printint+0x7c>
}
    8000053c:	70a2                	ld	ra,40(sp)
    8000053e:	7402                	ld	s0,32(sp)
    80000540:	64e2                	ld	s1,24(sp)
    80000542:	6942                	ld	s2,16(sp)
    80000544:	6145                	addi	sp,sp,48
    80000546:	8082                	ret
    x = -xx;
    80000548:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000054c:	4885                	li	a7,1
    x = -xx;
    8000054e:	bf9d                	j	800004c4 <printint+0x16>

0000000080000550 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000550:	1101                	addi	sp,sp,-32
    80000552:	ec06                	sd	ra,24(sp)
    80000554:	e822                	sd	s0,16(sp)
    80000556:	e426                	sd	s1,8(sp)
    80000558:	1000                	addi	s0,sp,32
    8000055a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000055c:	00011797          	auipc	a5,0x11
    80000560:	ce07a223          	sw	zero,-796(a5) # 80011240 <pr+0x20>
  printf("panic: ");
    80000564:	00008517          	auipc	a0,0x8
    80000568:	ab450513          	addi	a0,a0,-1356 # 80008018 <etext+0x18>
    8000056c:	00000097          	auipc	ra,0x0
    80000570:	02e080e7          	jalr	46(ra) # 8000059a <printf>
  printf(s);
    80000574:	8526                	mv	a0,s1
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	024080e7          	jalr	36(ra) # 8000059a <printf>
  printf("\n");
    8000057e:	00008517          	auipc	a0,0x8
    80000582:	be250513          	addi	a0,a0,-1054 # 80008160 <digits+0x120>
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	014080e7          	jalr	20(ra) # 8000059a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000058e:	4785                	li	a5,1
    80000590:	00009717          	auipc	a4,0x9
    80000594:	a6f72823          	sw	a5,-1424(a4) # 80009000 <panicked>
  for(;;)
    80000598:	a001                	j	80000598 <panic+0x48>

000000008000059a <printf>:
{
    8000059a:	7131                	addi	sp,sp,-192
    8000059c:	fc86                	sd	ra,120(sp)
    8000059e:	f8a2                	sd	s0,112(sp)
    800005a0:	f4a6                	sd	s1,104(sp)
    800005a2:	f0ca                	sd	s2,96(sp)
    800005a4:	ecce                	sd	s3,88(sp)
    800005a6:	e8d2                	sd	s4,80(sp)
    800005a8:	e4d6                	sd	s5,72(sp)
    800005aa:	e0da                	sd	s6,64(sp)
    800005ac:	fc5e                	sd	s7,56(sp)
    800005ae:	f862                	sd	s8,48(sp)
    800005b0:	f466                	sd	s9,40(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	ec6e                	sd	s11,24(sp)
    800005b6:	0100                	addi	s0,sp,128
    800005b8:	8a2a                	mv	s4,a0
    800005ba:	e40c                	sd	a1,8(s0)
    800005bc:	e810                	sd	a2,16(s0)
    800005be:	ec14                	sd	a3,24(s0)
    800005c0:	f018                	sd	a4,32(s0)
    800005c2:	f41c                	sd	a5,40(s0)
    800005c4:	03043823          	sd	a6,48(s0)
    800005c8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005cc:	00011d97          	auipc	s11,0x11
    800005d0:	c74dad83          	lw	s11,-908(s11) # 80011240 <pr+0x20>
  if(locking)
    800005d4:	020d9b63          	bnez	s11,8000060a <printf+0x70>
  if (fmt == 0)
    800005d8:	040a0263          	beqz	s4,8000061c <printf+0x82>
  va_start(ap, fmt);
    800005dc:	00840793          	addi	a5,s0,8
    800005e0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e4:	000a4503          	lbu	a0,0(s4)
    800005e8:	16050263          	beqz	a0,8000074c <printf+0x1b2>
    800005ec:	4481                	li	s1,0
    if(c != '%'){
    800005ee:	02500a93          	li	s5,37
    switch(c){
    800005f2:	07000b13          	li	s6,112
  consputc('x');
    800005f6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f8:	00008b97          	auipc	s7,0x8
    800005fc:	a48b8b93          	addi	s7,s7,-1464 # 80008040 <digits>
    switch(c){
    80000600:	07300c93          	li	s9,115
    80000604:	06400c13          	li	s8,100
    80000608:	a82d                	j	80000642 <printf+0xa8>
    acquire(&pr.lock);
    8000060a:	00011517          	auipc	a0,0x11
    8000060e:	c1650513          	addi	a0,a0,-1002 # 80011220 <pr>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	7d0080e7          	jalr	2000(ra) # 80000de2 <acquire>
    8000061a:	bf7d                	j	800005d8 <printf+0x3e>
    panic("null fmt");
    8000061c:	00008517          	auipc	a0,0x8
    80000620:	a0c50513          	addi	a0,a0,-1524 # 80008028 <etext+0x28>
    80000624:	00000097          	auipc	ra,0x0
    80000628:	f2c080e7          	jalr	-212(ra) # 80000550 <panic>
      consputc(c);
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	c62080e7          	jalr	-926(ra) # 8000028e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c503          	lbu	a0,0(a5)
    8000063e:	10050763          	beqz	a0,8000074c <printf+0x1b2>
    if(c != '%'){
    80000642:	ff5515e3          	bne	a0,s5,8000062c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000646:	2485                	addiw	s1,s1,1
    80000648:	009a07b3          	add	a5,s4,s1
    8000064c:	0007c783          	lbu	a5,0(a5)
    80000650:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000654:	cfe5                	beqz	a5,8000074c <printf+0x1b2>
    switch(c){
    80000656:	05678a63          	beq	a5,s6,800006aa <printf+0x110>
    8000065a:	02fb7663          	bgeu	s6,a5,80000686 <printf+0xec>
    8000065e:	09978963          	beq	a5,s9,800006f0 <printf+0x156>
    80000662:	07800713          	li	a4,120
    80000666:	0ce79863          	bne	a5,a4,80000736 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000066a:	f8843783          	ld	a5,-120(s0)
    8000066e:	00878713          	addi	a4,a5,8
    80000672:	f8e43423          	sd	a4,-120(s0)
    80000676:	4605                	li	a2,1
    80000678:	85ea                	mv	a1,s10
    8000067a:	4388                	lw	a0,0(a5)
    8000067c:	00000097          	auipc	ra,0x0
    80000680:	e32080e7          	jalr	-462(ra) # 800004ae <printint>
      break;
    80000684:	bf45                	j	80000634 <printf+0x9a>
    switch(c){
    80000686:	0b578263          	beq	a5,s5,8000072a <printf+0x190>
    8000068a:	0b879663          	bne	a5,s8,80000736 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	45a9                	li	a1,10
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e0e080e7          	jalr	-498(ra) # 800004ae <printint>
      break;
    800006a8:	b771                	j	80000634 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006aa:	f8843783          	ld	a5,-120(s0)
    800006ae:	00878713          	addi	a4,a5,8
    800006b2:	f8e43423          	sd	a4,-120(s0)
    800006b6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ba:	03000513          	li	a0,48
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bd0080e7          	jalr	-1072(ra) # 8000028e <consputc>
  consputc('x');
    800006c6:	07800513          	li	a0,120
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bc4080e7          	jalr	-1084(ra) # 8000028e <consputc>
    800006d2:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d4:	03c9d793          	srli	a5,s3,0x3c
    800006d8:	97de                	add	a5,a5,s7
    800006da:	0007c503          	lbu	a0,0(a5)
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	bb0080e7          	jalr	-1104(ra) # 8000028e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e6:	0992                	slli	s3,s3,0x4
    800006e8:	397d                	addiw	s2,s2,-1
    800006ea:	fe0915e3          	bnez	s2,800006d4 <printf+0x13a>
    800006ee:	b799                	j	80000634 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006f0:	f8843783          	ld	a5,-120(s0)
    800006f4:	00878713          	addi	a4,a5,8
    800006f8:	f8e43423          	sd	a4,-120(s0)
    800006fc:	0007b903          	ld	s2,0(a5)
    80000700:	00090e63          	beqz	s2,8000071c <printf+0x182>
      for(; *s; s++)
    80000704:	00094503          	lbu	a0,0(s2)
    80000708:	d515                	beqz	a0,80000634 <printf+0x9a>
        consputc(*s);
    8000070a:	00000097          	auipc	ra,0x0
    8000070e:	b84080e7          	jalr	-1148(ra) # 8000028e <consputc>
      for(; *s; s++)
    80000712:	0905                	addi	s2,s2,1
    80000714:	00094503          	lbu	a0,0(s2)
    80000718:	f96d                	bnez	a0,8000070a <printf+0x170>
    8000071a:	bf29                	j	80000634 <printf+0x9a>
        s = "(null)";
    8000071c:	00008917          	auipc	s2,0x8
    80000720:	90490913          	addi	s2,s2,-1788 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000724:	02800513          	li	a0,40
    80000728:	b7cd                	j	8000070a <printf+0x170>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b62080e7          	jalr	-1182(ra) # 8000028e <consputc>
      break;
    80000734:	b701                	j	80000634 <printf+0x9a>
      consputc('%');
    80000736:	8556                	mv	a0,s5
    80000738:	00000097          	auipc	ra,0x0
    8000073c:	b56080e7          	jalr	-1194(ra) # 8000028e <consputc>
      consputc(c);
    80000740:	854a                	mv	a0,s2
    80000742:	00000097          	auipc	ra,0x0
    80000746:	b4c080e7          	jalr	-1204(ra) # 8000028e <consputc>
      break;
    8000074a:	b5ed                	j	80000634 <printf+0x9a>
  if(locking)
    8000074c:	020d9163          	bnez	s11,8000076e <printf+0x1d4>
}
    80000750:	70e6                	ld	ra,120(sp)
    80000752:	7446                	ld	s0,112(sp)
    80000754:	74a6                	ld	s1,104(sp)
    80000756:	7906                	ld	s2,96(sp)
    80000758:	69e6                	ld	s3,88(sp)
    8000075a:	6a46                	ld	s4,80(sp)
    8000075c:	6aa6                	ld	s5,72(sp)
    8000075e:	6b06                	ld	s6,64(sp)
    80000760:	7be2                	ld	s7,56(sp)
    80000762:	7c42                	ld	s8,48(sp)
    80000764:	7ca2                	ld	s9,40(sp)
    80000766:	7d02                	ld	s10,32(sp)
    80000768:	6de2                	ld	s11,24(sp)
    8000076a:	6129                	addi	sp,sp,192
    8000076c:	8082                	ret
    release(&pr.lock);
    8000076e:	00011517          	auipc	a0,0x11
    80000772:	ab250513          	addi	a0,a0,-1358 # 80011220 <pr>
    80000776:	00000097          	auipc	ra,0x0
    8000077a:	73c080e7          	jalr	1852(ra) # 80000eb2 <release>
}
    8000077e:	bfc9                	j	80000750 <printf+0x1b6>

0000000080000780 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000780:	1101                	addi	sp,sp,-32
    80000782:	ec06                	sd	ra,24(sp)
    80000784:	e822                	sd	s0,16(sp)
    80000786:	e426                	sd	s1,8(sp)
    80000788:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000078a:	00011497          	auipc	s1,0x11
    8000078e:	a9648493          	addi	s1,s1,-1386 # 80011220 <pr>
    80000792:	00008597          	auipc	a1,0x8
    80000796:	8a658593          	addi	a1,a1,-1882 # 80008038 <etext+0x38>
    8000079a:	8526                	mv	a0,s1
    8000079c:	00000097          	auipc	ra,0x0
    800007a0:	7c2080e7          	jalr	1986(ra) # 80000f5e <initlock>
  pr.locking = 1;
    800007a4:	4785                	li	a5,1
    800007a6:	d09c                	sw	a5,32(s1)
}
    800007a8:	60e2                	ld	ra,24(sp)
    800007aa:	6442                	ld	s0,16(sp)
    800007ac:	64a2                	ld	s1,8(sp)
    800007ae:	6105                	addi	sp,sp,32
    800007b0:	8082                	ret

00000000800007b2 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007b2:	1141                	addi	sp,sp,-16
    800007b4:	e406                	sd	ra,8(sp)
    800007b6:	e022                	sd	s0,0(sp)
    800007b8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ba:	100007b7          	lui	a5,0x10000
    800007be:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007c2:	f8000713          	li	a4,-128
    800007c6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ca:	470d                	li	a4,3
    800007cc:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007d0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007d4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d8:	469d                	li	a3,7
    800007da:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007de:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007e2:	00008597          	auipc	a1,0x8
    800007e6:	87658593          	addi	a1,a1,-1930 # 80008058 <digits+0x18>
    800007ea:	00011517          	auipc	a0,0x11
    800007ee:	a5e50513          	addi	a0,a0,-1442 # 80011248 <uart_tx_lock>
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	76c080e7          	jalr	1900(ra) # 80000f5e <initlock>
}
    800007fa:	60a2                	ld	ra,8(sp)
    800007fc:	6402                	ld	s0,0(sp)
    800007fe:	0141                	addi	sp,sp,16
    80000800:	8082                	ret

0000000080000802 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000802:	1101                	addi	sp,sp,-32
    80000804:	ec06                	sd	ra,24(sp)
    80000806:	e822                	sd	s0,16(sp)
    80000808:	e426                	sd	s1,8(sp)
    8000080a:	1000                	addi	s0,sp,32
    8000080c:	84aa                	mv	s1,a0
  push_off();
    8000080e:	00000097          	auipc	ra,0x0
    80000812:	588080e7          	jalr	1416(ra) # 80000d96 <push_off>

  if(panicked){
    80000816:	00008797          	auipc	a5,0x8
    8000081a:	7ea7a783          	lw	a5,2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	10000737          	lui	a4,0x10000
  if(panicked){
    80000822:	c391                	beqz	a5,80000826 <uartputc_sync+0x24>
    for(;;)
    80000824:	a001                	j	80000824 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000826:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000082a:	0ff7f793          	andi	a5,a5,255
    8000082e:	0207f793          	andi	a5,a5,32
    80000832:	dbf5                	beqz	a5,80000826 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000834:	0ff4f793          	andi	a5,s1,255
    80000838:	10000737          	lui	a4,0x10000
    8000083c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000840:	00000097          	auipc	ra,0x0
    80000844:	612080e7          	jalr	1554(ra) # 80000e52 <pop_off>
}
    80000848:	60e2                	ld	ra,24(sp)
    8000084a:	6442                	ld	s0,16(sp)
    8000084c:	64a2                	ld	s1,8(sp)
    8000084e:	6105                	addi	sp,sp,32
    80000850:	8082                	ret

0000000080000852 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000852:	00008797          	auipc	a5,0x8
    80000856:	7b27a783          	lw	a5,1970(a5) # 80009004 <uart_tx_r>
    8000085a:	00008717          	auipc	a4,0x8
    8000085e:	7ae72703          	lw	a4,1966(a4) # 80009008 <uart_tx_w>
    80000862:	08f70263          	beq	a4,a5,800008e6 <uartstart+0x94>
{
    80000866:	7139                	addi	sp,sp,-64
    80000868:	fc06                	sd	ra,56(sp)
    8000086a:	f822                	sd	s0,48(sp)
    8000086c:	f426                	sd	s1,40(sp)
    8000086e:	f04a                	sd	s2,32(sp)
    80000870:	ec4e                	sd	s3,24(sp)
    80000872:	e852                	sd	s4,16(sp)
    80000874:	e456                	sd	s5,8(sp)
    80000876:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    8000087c:	00011a17          	auipc	s4,0x11
    80000880:	9cca0a13          	addi	s4,s4,-1588 # 80011248 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000884:	00008497          	auipc	s1,0x8
    80000888:	78048493          	addi	s1,s1,1920 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000088c:	00008997          	auipc	s3,0x8
    80000890:	77c98993          	addi	s3,s3,1916 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000894:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000898:	0ff77713          	andi	a4,a4,255
    8000089c:	02077713          	andi	a4,a4,32
    800008a0:	cb15                	beqz	a4,800008d4 <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    800008a2:	00fa0733          	add	a4,s4,a5
    800008a6:	02074a83          	lbu	s5,32(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008aa:	2785                	addiw	a5,a5,1
    800008ac:	41f7d71b          	sraiw	a4,a5,0x1f
    800008b0:	01b7571b          	srliw	a4,a4,0x1b
    800008b4:	9fb9                	addw	a5,a5,a4
    800008b6:	8bfd                	andi	a5,a5,31
    800008b8:	9f99                	subw	a5,a5,a4
    800008ba:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008bc:	8526                	mv	a0,s1
    800008be:	00002097          	auipc	ra,0x2
    800008c2:	f02080e7          	jalr	-254(ra) # 800027c0 <wakeup>
    
    WriteReg(THR, c);
    800008c6:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ca:	409c                	lw	a5,0(s1)
    800008cc:	0009a703          	lw	a4,0(s3)
    800008d0:	fcf712e3          	bne	a4,a5,80000894 <uartstart+0x42>
  }
}
    800008d4:	70e2                	ld	ra,56(sp)
    800008d6:	7442                	ld	s0,48(sp)
    800008d8:	74a2                	ld	s1,40(sp)
    800008da:	7902                	ld	s2,32(sp)
    800008dc:	69e2                	ld	s3,24(sp)
    800008de:	6a42                	ld	s4,16(sp)
    800008e0:	6aa2                	ld	s5,8(sp)
    800008e2:	6121                	addi	sp,sp,64
    800008e4:	8082                	ret
    800008e6:	8082                	ret

00000000800008e8 <uartputc>:
{
    800008e8:	7179                	addi	sp,sp,-48
    800008ea:	f406                	sd	ra,40(sp)
    800008ec:	f022                	sd	s0,32(sp)
    800008ee:	ec26                	sd	s1,24(sp)
    800008f0:	e84a                	sd	s2,16(sp)
    800008f2:	e44e                	sd	s3,8(sp)
    800008f4:	e052                	sd	s4,0(sp)
    800008f6:	1800                	addi	s0,sp,48
    800008f8:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008fa:	00011517          	auipc	a0,0x11
    800008fe:	94e50513          	addi	a0,a0,-1714 # 80011248 <uart_tx_lock>
    80000902:	00000097          	auipc	ra,0x0
    80000906:	4e0080e7          	jalr	1248(ra) # 80000de2 <acquire>
  if(panicked){
    8000090a:	00008797          	auipc	a5,0x8
    8000090e:	6f67a783          	lw	a5,1782(a5) # 80009000 <panicked>
    80000912:	c391                	beqz	a5,80000916 <uartputc+0x2e>
    for(;;)
    80000914:	a001                	j	80000914 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000916:	00008717          	auipc	a4,0x8
    8000091a:	6f272703          	lw	a4,1778(a4) # 80009008 <uart_tx_w>
    8000091e:	0017079b          	addiw	a5,a4,1
    80000922:	41f7d69b          	sraiw	a3,a5,0x1f
    80000926:	01b6d69b          	srliw	a3,a3,0x1b
    8000092a:	9fb5                	addw	a5,a5,a3
    8000092c:	8bfd                	andi	a5,a5,31
    8000092e:	9f95                	subw	a5,a5,a3
    80000930:	00008697          	auipc	a3,0x8
    80000934:	6d46a683          	lw	a3,1748(a3) # 80009004 <uart_tx_r>
    80000938:	04f69263          	bne	a3,a5,8000097c <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000093c:	00011a17          	auipc	s4,0x11
    80000940:	90ca0a13          	addi	s4,s4,-1780 # 80011248 <uart_tx_lock>
    80000944:	00008497          	auipc	s1,0x8
    80000948:	6c048493          	addi	s1,s1,1728 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000094c:	00008917          	auipc	s2,0x8
    80000950:	6bc90913          	addi	s2,s2,1724 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000954:	85d2                	mv	a1,s4
    80000956:	8526                	mv	a0,s1
    80000958:	00002097          	auipc	ra,0x2
    8000095c:	ce2080e7          	jalr	-798(ra) # 8000263a <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000960:	00092703          	lw	a4,0(s2)
    80000964:	0017079b          	addiw	a5,a4,1
    80000968:	41f7d69b          	sraiw	a3,a5,0x1f
    8000096c:	01b6d69b          	srliw	a3,a3,0x1b
    80000970:	9fb5                	addw	a5,a5,a3
    80000972:	8bfd                	andi	a5,a5,31
    80000974:	9f95                	subw	a5,a5,a3
    80000976:	4094                	lw	a3,0(s1)
    80000978:	fcf68ee3          	beq	a3,a5,80000954 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    8000097c:	00011497          	auipc	s1,0x11
    80000980:	8cc48493          	addi	s1,s1,-1844 # 80011248 <uart_tx_lock>
    80000984:	9726                	add	a4,a4,s1
    80000986:	03370023          	sb	s3,32(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    8000098a:	00008717          	auipc	a4,0x8
    8000098e:	66f72f23          	sw	a5,1662(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000992:	00000097          	auipc	ra,0x0
    80000996:	ec0080e7          	jalr	-320(ra) # 80000852 <uartstart>
      release(&uart_tx_lock);
    8000099a:	8526                	mv	a0,s1
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	516080e7          	jalr	1302(ra) # 80000eb2 <release>
}
    800009a4:	70a2                	ld	ra,40(sp)
    800009a6:	7402                	ld	s0,32(sp)
    800009a8:	64e2                	ld	s1,24(sp)
    800009aa:	6942                	ld	s2,16(sp)
    800009ac:	69a2                	ld	s3,8(sp)
    800009ae:	6a02                	ld	s4,0(sp)
    800009b0:	6145                	addi	sp,sp,48
    800009b2:	8082                	ret

00000000800009b4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009b4:	1141                	addi	sp,sp,-16
    800009b6:	e422                	sd	s0,8(sp)
    800009b8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009c2:	8b85                	andi	a5,a5,1
    800009c4:	cb91                	beqz	a5,800009d8 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009c6:	100007b7          	lui	a5,0x10000
    800009ca:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009ce:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009d2:	6422                	ld	s0,8(sp)
    800009d4:	0141                	addi	sp,sp,16
    800009d6:	8082                	ret
    return -1;
    800009d8:	557d                	li	a0,-1
    800009da:	bfe5                	j	800009d2 <uartgetc+0x1e>

00000000800009dc <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009dc:	1101                	addi	sp,sp,-32
    800009de:	ec06                	sd	ra,24(sp)
    800009e0:	e822                	sd	s0,16(sp)
    800009e2:	e426                	sd	s1,8(sp)
    800009e4:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009e6:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	fcc080e7          	jalr	-52(ra) # 800009b4 <uartgetc>
    if(c == -1)
    800009f0:	00950763          	beq	a0,s1,800009fe <uartintr+0x22>
      break;
    consoleintr(c);
    800009f4:	00000097          	auipc	ra,0x0
    800009f8:	8dc080e7          	jalr	-1828(ra) # 800002d0 <consoleintr>
  while(1){
    800009fc:	b7f5                	j	800009e8 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009fe:	00011497          	auipc	s1,0x11
    80000a02:	84a48493          	addi	s1,s1,-1974 # 80011248 <uart_tx_lock>
    80000a06:	8526                	mv	a0,s1
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	3da080e7          	jalr	986(ra) # 80000de2 <acquire>
  uartstart();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	e42080e7          	jalr	-446(ra) # 80000852 <uartstart>
  release(&uart_tx_lock);
    80000a18:	8526                	mv	a0,s1
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	498080e7          	jalr	1176(ra) # 80000eb2 <release>
}
    80000a22:	60e2                	ld	ra,24(sp)
    80000a24:	6442                	ld	s0,16(sp)
    80000a26:	64a2                	ld	s1,8(sp)
    80000a28:	6105                	addi	sp,sp,32
    80000a2a:	8082                	ret

0000000080000a2c <freecpurange>:
}
*/

void
freecpurange(void *pa_start,void *pa_end,int i)
{
    80000a2c:	715d                	addi	sp,sp,-80
    80000a2e:	e486                	sd	ra,72(sp)
    80000a30:	e0a2                	sd	s0,64(sp)
    80000a32:	fc26                	sd	s1,56(sp)
    80000a34:	f84a                	sd	s2,48(sp)
    80000a36:	f44e                	sd	s3,40(sp)
    80000a38:	f052                	sd	s4,32(sp)
    80000a3a:	ec56                	sd	s5,24(sp)
    80000a3c:	e85a                	sd	s6,16(sp)
    80000a3e:	e45e                	sd	s7,8(sp)
    80000a40:	0880                	addi	s0,sp,80
  char *p;
  struct run *r;
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a42:	6785                	lui	a5,0x1
    80000a44:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a48:	9526                	add	a0,a0,s1
    80000a4a:	74fd                	lui	s1,0xfffff
    80000a4c:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){  
    80000a4e:	97a6                	add	a5,a5,s1
    80000a50:	08f5e763          	bltu	a1,a5,80000ade <freecpurange+0xb2>
    80000a54:	8a2e                	mv	s4,a1
    if(((uint64)p % PGSIZE) != 0 || (char*)p < end || (uint64)p >= PHYSTOP)
    80000a56:	00027797          	auipc	a5,0x27
    80000a5a:	5d278793          	addi	a5,a5,1490 # 80028028 <end>
    80000a5e:	06f4e863          	bltu	s1,a5,80000ace <freecpurange+0xa2>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	06f4f463          	bgeu	s1,a5,80000ace <freecpurange+0xa2>
    panic("kfree");
    // Fill with junk to catch dangling refs.
    memset(p, 1, PGSIZE);
    r = (struct run*)p;
    acquire(&kmem[i].lock);
    80000a6a:	00261993          	slli	s3,a2,0x2
    80000a6e:	99b2                	add	s3,s3,a2
    80000a70:	00399793          	slli	a5,s3,0x3
    80000a74:	00011997          	auipc	s3,0x11
    80000a78:	81498993          	addi	s3,s3,-2028 # 80011288 <kmem>
    80000a7c:	99be                	add	s3,s3,a5
    r->next = kmem[i].freelist;
    80000a7e:	894e                	mv	s2,s3
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){  
    80000a80:	6b09                	lui	s6,0x2
    if(((uint64)p % PGSIZE) != 0 || (char*)p < end || (uint64)p >= PHYSTOP)
    80000a82:	00027b97          	auipc	s7,0x27
    80000a86:	5a6b8b93          	addi	s7,s7,1446 # 80028028 <end>
    80000a8a:	4ac5                	li	s5,17
    80000a8c:	0aee                	slli	s5,s5,0x1b
    memset(p, 1, PGSIZE);
    80000a8e:	6605                	lui	a2,0x1
    80000a90:	4585                	li	a1,1
    80000a92:	8526                	mv	a0,s1
    80000a94:	00000097          	auipc	ra,0x0
    80000a98:	72e080e7          	jalr	1838(ra) # 800011c2 <memset>
    acquire(&kmem[i].lock);
    80000a9c:	854e                	mv	a0,s3
    80000a9e:	00000097          	auipc	ra,0x0
    80000aa2:	344080e7          	jalr	836(ra) # 80000de2 <acquire>
    r->next = kmem[i].freelist;
    80000aa6:	02093783          	ld	a5,32(s2)
    80000aaa:	e09c                	sd	a5,0(s1)
    kmem[i].freelist = r;
    80000aac:	02993023          	sd	s1,32(s2)
    release(&kmem[i].lock);  
    80000ab0:	854e                	mv	a0,s3
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	400080e7          	jalr	1024(ra) # 80000eb2 <release>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){  
    80000aba:	016487b3          	add	a5,s1,s6
    80000abe:	02fa6063          	bltu	s4,a5,80000ade <freecpurange+0xb2>
    if(((uint64)p % PGSIZE) != 0 || (char*)p < end || (uint64)p >= PHYSTOP)
    80000ac2:	6785                	lui	a5,0x1
    80000ac4:	94be                	add	s1,s1,a5
    80000ac6:	0174e463          	bltu	s1,s7,80000ace <freecpurange+0xa2>
    80000aca:	fd54e2e3          	bltu	s1,s5,80000a8e <freecpurange+0x62>
    panic("kfree");
    80000ace:	00007517          	auipc	a0,0x7
    80000ad2:	59250513          	addi	a0,a0,1426 # 80008060 <digits+0x20>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	a7a080e7          	jalr	-1414(ra) # 80000550 <panic>
  }

}
    80000ade:	60a6                	ld	ra,72(sp)
    80000ae0:	6406                	ld	s0,64(sp)
    80000ae2:	74e2                	ld	s1,56(sp)
    80000ae4:	7942                	ld	s2,48(sp)
    80000ae6:	79a2                	ld	s3,40(sp)
    80000ae8:	7a02                	ld	s4,32(sp)
    80000aea:	6ae2                	ld	s5,24(sp)
    80000aec:	6b42                	ld	s6,16(sp)
    80000aee:	6ba2                	ld	s7,8(sp)
    80000af0:	6161                	addi	sp,sp,80
    80000af2:	8082                	ret

0000000080000af4 <kinit>:



void
kinit()
{
    80000af4:	715d                	addi	sp,sp,-80
    80000af6:	e486                	sd	ra,72(sp)
    80000af8:	e0a2                	sd	s0,64(sp)
    80000afa:	fc26                	sd	s1,56(sp)
    80000afc:	f84a                	sd	s2,48(sp)
    80000afe:	f44e                	sd	s3,40(sp)
    80000b00:	f052                	sd	s4,32(sp)
    80000b02:	ec56                	sd	s5,24(sp)
    80000b04:	e85a                	sd	s6,16(sp)
    80000b06:	e45e                	sd	s7,8(sp)
    80000b08:	0880                	addi	s0,sp,80
  char * p1=(char *)end;
  char * p2=(char *)PHYSTOP;
  for (int i = 0; i < NCPU; i++)
    80000b0a:	00010917          	auipc	s2,0x10
    80000b0e:	77e90913          	addi	s2,s2,1918 # 80011288 <kmem>
{
    80000b12:	4481                	li	s1,0
  {
      initlock(&kmem[i].lock, "kmem");
    80000b14:	00007b97          	auipc	s7,0x7
    80000b18:	554b8b93          	addi	s7,s7,1364 # 80008068 <digits+0x28>
      freecpurange((void *)p1+(p2-p1)*i/NCPU,(void *)p1+(p2-p1)*(i+1)/NCPU,i);
    80000b1c:	00027a17          	auipc	s4,0x27
    80000b20:	50ca0a13          	addi	s4,s4,1292 # 80028028 <end>
    80000b24:	49c5                	li	s3,17
    80000b26:	09ee                	slli	s3,s3,0x1b
    80000b28:	414989b3          	sub	s3,s3,s4
  for (int i = 0; i < NCPU; i++)
    80000b2c:	4b21                	li	s6,8
    80000b2e:	00048a9b          	sext.w	s5,s1
      initlock(&kmem[i].lock, "kmem");
    80000b32:	85de                	mv	a1,s7
    80000b34:	854a                	mv	a0,s2
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	428080e7          	jalr	1064(ra) # 80000f5e <initlock>
      freecpurange((void *)p1+(p2-p1)*i/NCPU,(void *)p1+(p2-p1)*(i+1)/NCPU,i);
    80000b3e:	033487b3          	mul	a5,s1,s3
    80000b42:	43f7d513          	srai	a0,a5,0x3f
    80000b46:	891d                	andi	a0,a0,7
    80000b48:	953e                	add	a0,a0,a5
    80000b4a:	850d                	srai	a0,a0,0x3
    80000b4c:	0485                	addi	s1,s1,1
    80000b4e:	033487b3          	mul	a5,s1,s3
    80000b52:	43f7d593          	srai	a1,a5,0x3f
    80000b56:	899d                	andi	a1,a1,7
    80000b58:	95be                	add	a1,a1,a5
    80000b5a:	858d                	srai	a1,a1,0x3
    80000b5c:	8656                	mv	a2,s5
    80000b5e:	95d2                	add	a1,a1,s4
    80000b60:	9552                	add	a0,a0,s4
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	eca080e7          	jalr	-310(ra) # 80000a2c <freecpurange>
  for (int i = 0; i < NCPU; i++)
    80000b6a:	02890913          	addi	s2,s2,40
    80000b6e:	fd6490e3          	bne	s1,s6,80000b2e <kinit+0x3a>
  }
  
  //freerange(end, (void*)PHYSTOP);
}
    80000b72:	60a6                	ld	ra,72(sp)
    80000b74:	6406                	ld	s0,64(sp)
    80000b76:	74e2                	ld	s1,56(sp)
    80000b78:	7942                	ld	s2,48(sp)
    80000b7a:	79a2                	ld	s3,40(sp)
    80000b7c:	7a02                	ld	s4,32(sp)
    80000b7e:	6ae2                	ld	s5,24(sp)
    80000b80:	6b42                	ld	s6,16(sp)
    80000b82:	6ba2                	ld	s7,8(sp)
    80000b84:	6161                	addi	sp,sp,80
    80000b86:	8082                	ret

0000000080000b88 <kfree>:
*/


void
kfree(void *pa)
{
    80000b88:	7139                	addi	sp,sp,-64
    80000b8a:	fc06                	sd	ra,56(sp)
    80000b8c:	f822                	sd	s0,48(sp)
    80000b8e:	f426                	sd	s1,40(sp)
    80000b90:	f04a                	sd	s2,32(sp)
    80000b92:	ec4e                	sd	s3,24(sp)
    80000b94:	e852                	sd	s4,16(sp)
    80000b96:	e456                	sd	s5,8(sp)
    80000b98:	0080                	addi	s0,sp,64
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000b9a:	03451793          	slli	a5,a0,0x34
    80000b9e:	e3c1                	bnez	a5,80000c1e <kfree+0x96>
    80000ba0:	84aa                	mv	s1,a0
    80000ba2:	00027797          	auipc	a5,0x27
    80000ba6:	48678793          	addi	a5,a5,1158 # 80028028 <end>
    80000baa:	06f56a63          	bltu	a0,a5,80000c1e <kfree+0x96>
    80000bae:	47c5                	li	a5,17
    80000bb0:	07ee                	slli	a5,a5,0x1b
    80000bb2:	06f57663          	bgeu	a0,a5,80000c1e <kfree+0x96>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000bb6:	6605                	lui	a2,0x1
    80000bb8:	4585                	li	a1,1
    80000bba:	00000097          	auipc	ra,0x0
    80000bbe:	608080e7          	jalr	1544(ra) # 800011c2 <memset>

  r = (struct run*)pa;

  push_off();
    80000bc2:	00000097          	auipc	ra,0x0
    80000bc6:	1d4080e7          	jalr	468(ra) # 80000d96 <push_off>
  int id=cpuid();
    80000bca:	00001097          	auipc	ra,0x1
    80000bce:	234080e7          	jalr	564(ra) # 80001dfe <cpuid>

  acquire(&kmem[id].lock);
    80000bd2:	00010a97          	auipc	s5,0x10
    80000bd6:	6b6a8a93          	addi	s5,s5,1718 # 80011288 <kmem>
    80000bda:	00251993          	slli	s3,a0,0x2
    80000bde:	00a98933          	add	s2,s3,a0
    80000be2:	090e                	slli	s2,s2,0x3
    80000be4:	9956                	add	s2,s2,s5
    80000be6:	854a                	mv	a0,s2
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	1fa080e7          	jalr	506(ra) # 80000de2 <acquire>
  r->next = kmem[id].freelist;
    80000bf0:	02093783          	ld	a5,32(s2)
    80000bf4:	e09c                	sd	a5,0(s1)
  kmem[id].freelist = r;
    80000bf6:	02993023          	sd	s1,32(s2)
  release(&kmem[id].lock);
    80000bfa:	854a                	mv	a0,s2
    80000bfc:	00000097          	auipc	ra,0x0
    80000c00:	2b6080e7          	jalr	694(ra) # 80000eb2 <release>

  pop_off();
    80000c04:	00000097          	auipc	ra,0x0
    80000c08:	24e080e7          	jalr	590(ra) # 80000e52 <pop_off>
}
    80000c0c:	70e2                	ld	ra,56(sp)
    80000c0e:	7442                	ld	s0,48(sp)
    80000c10:	74a2                	ld	s1,40(sp)
    80000c12:	7902                	ld	s2,32(sp)
    80000c14:	69e2                	ld	s3,24(sp)
    80000c16:	6a42                	ld	s4,16(sp)
    80000c18:	6aa2                	ld	s5,8(sp)
    80000c1a:	6121                	addi	sp,sp,64
    80000c1c:	8082                	ret
    panic("kfree");
    80000c1e:	00007517          	auipc	a0,0x7
    80000c22:	44250513          	addi	a0,a0,1090 # 80008060 <digits+0x20>
    80000c26:	00000097          	auipc	ra,0x0
    80000c2a:	92a080e7          	jalr	-1750(ra) # 80000550 <panic>

0000000080000c2e <freerange>:
{
    80000c2e:	7179                	addi	sp,sp,-48
    80000c30:	f406                	sd	ra,40(sp)
    80000c32:	f022                	sd	s0,32(sp)
    80000c34:	ec26                	sd	s1,24(sp)
    80000c36:	e84a                	sd	s2,16(sp)
    80000c38:	e44e                	sd	s3,8(sp)
    80000c3a:	e052                	sd	s4,0(sp)
    80000c3c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000c3e:	6785                	lui	a5,0x1
    80000c40:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000c44:	94aa                	add	s1,s1,a0
    80000c46:	757d                	lui	a0,0xfffff
    80000c48:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000c4a:	94be                	add	s1,s1,a5
    80000c4c:	0095ee63          	bltu	a1,s1,80000c68 <freerange+0x3a>
    80000c50:	892e                	mv	s2,a1
    kfree(p);
    80000c52:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000c54:	6985                	lui	s3,0x1
    kfree(p);
    80000c56:	01448533          	add	a0,s1,s4
    80000c5a:	00000097          	auipc	ra,0x0
    80000c5e:	f2e080e7          	jalr	-210(ra) # 80000b88 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000c62:	94ce                	add	s1,s1,s3
    80000c64:	fe9979e3          	bgeu	s2,s1,80000c56 <freerange+0x28>
}
    80000c68:	70a2                	ld	ra,40(sp)
    80000c6a:	7402                	ld	s0,32(sp)
    80000c6c:	64e2                	ld	s1,24(sp)
    80000c6e:	6942                	ld	s2,16(sp)
    80000c70:	69a2                	ld	s3,8(sp)
    80000c72:	6a02                	ld	s4,0(sp)
    80000c74:	6145                	addi	sp,sp,48
    80000c76:	8082                	ret

0000000080000c78 <kalloc>:
}
*/

void *
kalloc(void)
{
    80000c78:	7139                	addi	sp,sp,-64
    80000c7a:	fc06                	sd	ra,56(sp)
    80000c7c:	f822                	sd	s0,48(sp)
    80000c7e:	f426                	sd	s1,40(sp)
    80000c80:	f04a                	sd	s2,32(sp)
    80000c82:	ec4e                	sd	s3,24(sp)
    80000c84:	e852                	sd	s4,16(sp)
    80000c86:	e456                	sd	s5,8(sp)
    80000c88:	0080                	addi	s0,sp,64
  struct run *r;

  push_off();
    80000c8a:	00000097          	auipc	ra,0x0
    80000c8e:	10c080e7          	jalr	268(ra) # 80000d96 <push_off>
  int id=cpuid();
    80000c92:	00001097          	auipc	ra,0x1
    80000c96:	16c080e7          	jalr	364(ra) # 80001dfe <cpuid>
  acquire(&kmem[id].lock);
    80000c9a:	00251993          	slli	s3,a0,0x2
    80000c9e:	99aa                	add	s3,s3,a0
    80000ca0:	00399793          	slli	a5,s3,0x3
    80000ca4:	00010997          	auipc	s3,0x10
    80000ca8:	5e498993          	addi	s3,s3,1508 # 80011288 <kmem>
    80000cac:	99be                	add	s3,s3,a5
    80000cae:	854e                	mv	a0,s3
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	132080e7          	jalr	306(ra) # 80000de2 <acquire>
  r = kmem[id].freelist;
    80000cb8:	0209b903          	ld	s2,32(s3)
  if(r){
    80000cbc:	04090063          	beqz	s2,80000cfc <kalloc+0x84>
    kmem[id].freelist = r->next;
    80000cc0:	00093703          	ld	a4,0(s2)
    80000cc4:	02e9b023          	sd	a4,32(s3)
    release(&kmem[id].lock);
    80000cc8:	854e                	mv	a0,s3
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	1e8080e7          	jalr	488(ra) # 80000eb2 <release>
        break;
      }
      release(&kmem[i].lock);
    }
  }
  pop_off();
    80000cd2:	00000097          	auipc	ra,0x0
    80000cd6:	180080e7          	jalr	384(ra) # 80000e52 <pop_off>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000cda:	6605                	lui	a2,0x1
    80000cdc:	4595                	li	a1,5
    80000cde:	854a                	mv	a0,s2
    80000ce0:	00000097          	auipc	ra,0x0
    80000ce4:	4e2080e7          	jalr	1250(ra) # 800011c2 <memset>
  return (void*)r;
}
    80000ce8:	854a                	mv	a0,s2
    80000cea:	70e2                	ld	ra,56(sp)
    80000cec:	7442                	ld	s0,48(sp)
    80000cee:	74a2                	ld	s1,40(sp)
    80000cf0:	7902                	ld	s2,32(sp)
    80000cf2:	69e2                	ld	s3,24(sp)
    80000cf4:	6a42                	ld	s4,16(sp)
    80000cf6:	6aa2                	ld	s5,8(sp)
    80000cf8:	6121                	addi	sp,sp,64
    80000cfa:	8082                	ret
    release(&kmem[id].lock);
    80000cfc:	854e                	mv	a0,s3
    80000cfe:	00000097          	auipc	ra,0x0
    80000d02:	1b4080e7          	jalr	436(ra) # 80000eb2 <release>
    for (int i = 0; i < NCPU; i++)
    80000d06:	00010497          	auipc	s1,0x10
    80000d0a:	58248493          	addi	s1,s1,1410 # 80011288 <kmem>
    80000d0e:	4981                	li	s3,0
    80000d10:	4a21                	li	s4,8
      acquire(&kmem[i].lock);
    80000d12:	8526                	mv	a0,s1
    80000d14:	00000097          	auipc	ra,0x0
    80000d18:	0ce080e7          	jalr	206(ra) # 80000de2 <acquire>
      r=kmem[i].freelist;
    80000d1c:	0204b903          	ld	s2,32(s1)
      if(r){
    80000d20:	02091163          	bnez	s2,80000d42 <kalloc+0xca>
      release(&kmem[i].lock);
    80000d24:	8526                	mv	a0,s1
    80000d26:	00000097          	auipc	ra,0x0
    80000d2a:	18c080e7          	jalr	396(ra) # 80000eb2 <release>
    for (int i = 0; i < NCPU; i++)
    80000d2e:	2985                	addiw	s3,s3,1
    80000d30:	02848493          	addi	s1,s1,40
    80000d34:	fd499fe3          	bne	s3,s4,80000d12 <kalloc+0x9a>
  pop_off();
    80000d38:	00000097          	auipc	ra,0x0
    80000d3c:	11a080e7          	jalr	282(ra) # 80000e52 <pop_off>
  if(r)
    80000d40:	b765                	j	80000ce8 <kalloc+0x70>
        kmem[i].freelist=r->next;
    80000d42:	00093703          	ld	a4,0(s2)
    80000d46:	00299793          	slli	a5,s3,0x2
    80000d4a:	99be                	add	s3,s3,a5
    80000d4c:	098e                	slli	s3,s3,0x3
    80000d4e:	00010797          	auipc	a5,0x10
    80000d52:	53a78793          	addi	a5,a5,1338 # 80011288 <kmem>
    80000d56:	99be                	add	s3,s3,a5
    80000d58:	02e9b023          	sd	a4,32(s3)
        release(&kmem[i].lock);
    80000d5c:	8526                	mv	a0,s1
    80000d5e:	00000097          	auipc	ra,0x0
    80000d62:	154080e7          	jalr	340(ra) # 80000eb2 <release>
        break;
    80000d66:	b7b5                	j	80000cd2 <kalloc+0x5a>

0000000080000d68 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d68:	411c                	lw	a5,0(a0)
    80000d6a:	e399                	bnez	a5,80000d70 <holding+0x8>
    80000d6c:	4501                	li	a0,0
  return r;
}
    80000d6e:	8082                	ret
{
    80000d70:	1101                	addi	sp,sp,-32
    80000d72:	ec06                	sd	ra,24(sp)
    80000d74:	e822                	sd	s0,16(sp)
    80000d76:	e426                	sd	s1,8(sp)
    80000d78:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d7a:	6904                	ld	s1,16(a0)
    80000d7c:	00001097          	auipc	ra,0x1
    80000d80:	092080e7          	jalr	146(ra) # 80001e0e <mycpu>
    80000d84:	40a48533          	sub	a0,s1,a0
    80000d88:	00153513          	seqz	a0,a0
}
    80000d8c:	60e2                	ld	ra,24(sp)
    80000d8e:	6442                	ld	s0,16(sp)
    80000d90:	64a2                	ld	s1,8(sp)
    80000d92:	6105                	addi	sp,sp,32
    80000d94:	8082                	ret

0000000080000d96 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d96:	1101                	addi	sp,sp,-32
    80000d98:	ec06                	sd	ra,24(sp)
    80000d9a:	e822                	sd	s0,16(sp)
    80000d9c:	e426                	sd	s1,8(sp)
    80000d9e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000da0:	100024f3          	csrr	s1,sstatus
    80000da4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000da8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000daa:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000dae:	00001097          	auipc	ra,0x1
    80000db2:	060080e7          	jalr	96(ra) # 80001e0e <mycpu>
    80000db6:	5d3c                	lw	a5,120(a0)
    80000db8:	cf89                	beqz	a5,80000dd2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000dba:	00001097          	auipc	ra,0x1
    80000dbe:	054080e7          	jalr	84(ra) # 80001e0e <mycpu>
    80000dc2:	5d3c                	lw	a5,120(a0)
    80000dc4:	2785                	addiw	a5,a5,1
    80000dc6:	dd3c                	sw	a5,120(a0)
}
    80000dc8:	60e2                	ld	ra,24(sp)
    80000dca:	6442                	ld	s0,16(sp)
    80000dcc:	64a2                	ld	s1,8(sp)
    80000dce:	6105                	addi	sp,sp,32
    80000dd0:	8082                	ret
    mycpu()->intena = old;
    80000dd2:	00001097          	auipc	ra,0x1
    80000dd6:	03c080e7          	jalr	60(ra) # 80001e0e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000dda:	8085                	srli	s1,s1,0x1
    80000ddc:	8885                	andi	s1,s1,1
    80000dde:	dd64                	sw	s1,124(a0)
    80000de0:	bfe9                	j	80000dba <push_off+0x24>

0000000080000de2 <acquire>:
{
    80000de2:	1101                	addi	sp,sp,-32
    80000de4:	ec06                	sd	ra,24(sp)
    80000de6:	e822                	sd	s0,16(sp)
    80000de8:	e426                	sd	s1,8(sp)
    80000dea:	1000                	addi	s0,sp,32
    80000dec:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000dee:	00000097          	auipc	ra,0x0
    80000df2:	fa8080e7          	jalr	-88(ra) # 80000d96 <push_off>
  if(holding(lk))
    80000df6:	8526                	mv	a0,s1
    80000df8:	00000097          	auipc	ra,0x0
    80000dfc:	f70080e7          	jalr	-144(ra) # 80000d68 <holding>
    80000e00:	e911                	bnez	a0,80000e14 <acquire+0x32>
    __sync_fetch_and_add(&(lk->n), 1);
    80000e02:	4785                	li	a5,1
    80000e04:	01c48713          	addi	a4,s1,28
    80000e08:	0f50000f          	fence	iorw,ow
    80000e0c:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000e10:	4705                	li	a4,1
    80000e12:	a839                	j	80000e30 <acquire+0x4e>
    panic("acquire");
    80000e14:	00007517          	auipc	a0,0x7
    80000e18:	25c50513          	addi	a0,a0,604 # 80008070 <digits+0x30>
    80000e1c:	fffff097          	auipc	ra,0xfffff
    80000e20:	734080e7          	jalr	1844(ra) # 80000550 <panic>
    __sync_fetch_and_add(&(lk->nts), 1);
    80000e24:	01848793          	addi	a5,s1,24
    80000e28:	0f50000f          	fence	iorw,ow
    80000e2c:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000e30:	87ba                	mv	a5,a4
    80000e32:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000e36:	2781                	sext.w	a5,a5
    80000e38:	f7f5                	bnez	a5,80000e24 <acquire+0x42>
  __sync_synchronize();
    80000e3a:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000e3e:	00001097          	auipc	ra,0x1
    80000e42:	fd0080e7          	jalr	-48(ra) # 80001e0e <mycpu>
    80000e46:	e888                	sd	a0,16(s1)
}
    80000e48:	60e2                	ld	ra,24(sp)
    80000e4a:	6442                	ld	s0,16(sp)
    80000e4c:	64a2                	ld	s1,8(sp)
    80000e4e:	6105                	addi	sp,sp,32
    80000e50:	8082                	ret

0000000080000e52 <pop_off>:

void
pop_off(void)
{
    80000e52:	1141                	addi	sp,sp,-16
    80000e54:	e406                	sd	ra,8(sp)
    80000e56:	e022                	sd	s0,0(sp)
    80000e58:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e5a:	00001097          	auipc	ra,0x1
    80000e5e:	fb4080e7          	jalr	-76(ra) # 80001e0e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e62:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e66:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e68:	e78d                	bnez	a5,80000e92 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e6a:	5d3c                	lw	a5,120(a0)
    80000e6c:	02f05b63          	blez	a5,80000ea2 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e70:	37fd                	addiw	a5,a5,-1
    80000e72:	0007871b          	sext.w	a4,a5
    80000e76:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e78:	eb09                	bnez	a4,80000e8a <pop_off+0x38>
    80000e7a:	5d7c                	lw	a5,124(a0)
    80000e7c:	c799                	beqz	a5,80000e8a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e86:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e8a:	60a2                	ld	ra,8(sp)
    80000e8c:	6402                	ld	s0,0(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret
    panic("pop_off - interruptible");
    80000e92:	00007517          	auipc	a0,0x7
    80000e96:	1e650513          	addi	a0,a0,486 # 80008078 <digits+0x38>
    80000e9a:	fffff097          	auipc	ra,0xfffff
    80000e9e:	6b6080e7          	jalr	1718(ra) # 80000550 <panic>
    panic("pop_off");
    80000ea2:	00007517          	auipc	a0,0x7
    80000ea6:	1ee50513          	addi	a0,a0,494 # 80008090 <digits+0x50>
    80000eaa:	fffff097          	auipc	ra,0xfffff
    80000eae:	6a6080e7          	jalr	1702(ra) # 80000550 <panic>

0000000080000eb2 <release>:
{
    80000eb2:	1101                	addi	sp,sp,-32
    80000eb4:	ec06                	sd	ra,24(sp)
    80000eb6:	e822                	sd	s0,16(sp)
    80000eb8:	e426                	sd	s1,8(sp)
    80000eba:	1000                	addi	s0,sp,32
    80000ebc:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ebe:	00000097          	auipc	ra,0x0
    80000ec2:	eaa080e7          	jalr	-342(ra) # 80000d68 <holding>
    80000ec6:	c115                	beqz	a0,80000eea <release+0x38>
  lk->cpu = 0;
    80000ec8:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ecc:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ed0:	0f50000f          	fence	iorw,ow
    80000ed4:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	f7a080e7          	jalr	-134(ra) # 80000e52 <pop_off>
}
    80000ee0:	60e2                	ld	ra,24(sp)
    80000ee2:	6442                	ld	s0,16(sp)
    80000ee4:	64a2                	ld	s1,8(sp)
    80000ee6:	6105                	addi	sp,sp,32
    80000ee8:	8082                	ret
    panic("release");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1ae50513          	addi	a0,a0,430 # 80008098 <digits+0x58>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	65e080e7          	jalr	1630(ra) # 80000550 <panic>

0000000080000efa <freelock>:
{
    80000efa:	1101                	addi	sp,sp,-32
    80000efc:	ec06                	sd	ra,24(sp)
    80000efe:	e822                	sd	s0,16(sp)
    80000f00:	e426                	sd	s1,8(sp)
    80000f02:	1000                	addi	s0,sp,32
    80000f04:	84aa                	mv	s1,a0
  acquire(&lock_locks);
    80000f06:	00010517          	auipc	a0,0x10
    80000f0a:	4c250513          	addi	a0,a0,1218 # 800113c8 <lock_locks>
    80000f0e:	00000097          	auipc	ra,0x0
    80000f12:	ed4080e7          	jalr	-300(ra) # 80000de2 <acquire>
  for (i = 0; i < NLOCK; i++) {
    80000f16:	00010717          	auipc	a4,0x10
    80000f1a:	4d270713          	addi	a4,a4,1234 # 800113e8 <locks>
    80000f1e:	4781                	li	a5,0
    80000f20:	1f400613          	li	a2,500
    if(locks[i] == lk) {
    80000f24:	6314                	ld	a3,0(a4)
    80000f26:	00968763          	beq	a3,s1,80000f34 <freelock+0x3a>
  for (i = 0; i < NLOCK; i++) {
    80000f2a:	2785                	addiw	a5,a5,1
    80000f2c:	0721                	addi	a4,a4,8
    80000f2e:	fec79be3          	bne	a5,a2,80000f24 <freelock+0x2a>
    80000f32:	a809                	j	80000f44 <freelock+0x4a>
      locks[i] = 0;
    80000f34:	078e                	slli	a5,a5,0x3
    80000f36:	00010717          	auipc	a4,0x10
    80000f3a:	4b270713          	addi	a4,a4,1202 # 800113e8 <locks>
    80000f3e:	97ba                	add	a5,a5,a4
    80000f40:	0007b023          	sd	zero,0(a5)
  release(&lock_locks);
    80000f44:	00010517          	auipc	a0,0x10
    80000f48:	48450513          	addi	a0,a0,1156 # 800113c8 <lock_locks>
    80000f4c:	00000097          	auipc	ra,0x0
    80000f50:	f66080e7          	jalr	-154(ra) # 80000eb2 <release>
}
    80000f54:	60e2                	ld	ra,24(sp)
    80000f56:	6442                	ld	s0,16(sp)
    80000f58:	64a2                	ld	s1,8(sp)
    80000f5a:	6105                	addi	sp,sp,32
    80000f5c:	8082                	ret

0000000080000f5e <initlock>:
{
    80000f5e:	1101                	addi	sp,sp,-32
    80000f60:	ec06                	sd	ra,24(sp)
    80000f62:	e822                	sd	s0,16(sp)
    80000f64:	e426                	sd	s1,8(sp)
    80000f66:	1000                	addi	s0,sp,32
    80000f68:	84aa                	mv	s1,a0
  lk->name = name;
    80000f6a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000f6c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000f70:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000f74:	00052c23          	sw	zero,24(a0)
  lk->n = 0;
    80000f78:	00052e23          	sw	zero,28(a0)
  acquire(&lock_locks);
    80000f7c:	00010517          	auipc	a0,0x10
    80000f80:	44c50513          	addi	a0,a0,1100 # 800113c8 <lock_locks>
    80000f84:	00000097          	auipc	ra,0x0
    80000f88:	e5e080e7          	jalr	-418(ra) # 80000de2 <acquire>
  for (i = 0; i < NLOCK; i++) {
    80000f8c:	00010717          	auipc	a4,0x10
    80000f90:	45c70713          	addi	a4,a4,1116 # 800113e8 <locks>
    80000f94:	4781                	li	a5,0
    80000f96:	1f400693          	li	a3,500
    if(locks[i] == 0) {
    80000f9a:	6310                	ld	a2,0(a4)
    80000f9c:	ce09                	beqz	a2,80000fb6 <initlock+0x58>
  for (i = 0; i < NLOCK; i++) {
    80000f9e:	2785                	addiw	a5,a5,1
    80000fa0:	0721                	addi	a4,a4,8
    80000fa2:	fed79ce3          	bne	a5,a3,80000f9a <initlock+0x3c>
  panic("findslot");
    80000fa6:	00007517          	auipc	a0,0x7
    80000faa:	0fa50513          	addi	a0,a0,250 # 800080a0 <digits+0x60>
    80000fae:	fffff097          	auipc	ra,0xfffff
    80000fb2:	5a2080e7          	jalr	1442(ra) # 80000550 <panic>
      locks[i] = lk;
    80000fb6:	078e                	slli	a5,a5,0x3
    80000fb8:	00010717          	auipc	a4,0x10
    80000fbc:	43070713          	addi	a4,a4,1072 # 800113e8 <locks>
    80000fc0:	97ba                	add	a5,a5,a4
    80000fc2:	e384                	sd	s1,0(a5)
      release(&lock_locks);
    80000fc4:	00010517          	auipc	a0,0x10
    80000fc8:	40450513          	addi	a0,a0,1028 # 800113c8 <lock_locks>
    80000fcc:	00000097          	auipc	ra,0x0
    80000fd0:	ee6080e7          	jalr	-282(ra) # 80000eb2 <release>
}
    80000fd4:	60e2                	ld	ra,24(sp)
    80000fd6:	6442                	ld	s0,16(sp)
    80000fd8:	64a2                	ld	s1,8(sp)
    80000fda:	6105                	addi	sp,sp,32
    80000fdc:	8082                	ret

0000000080000fde <snprint_lock>:
#ifdef LAB_LOCK
int
snprint_lock(char *buf, int sz, struct spinlock *lk)
{
  int n = 0;
  if(lk->n > 0) {
    80000fde:	4e5c                	lw	a5,28(a2)
    80000fe0:	00f04463          	bgtz	a5,80000fe8 <snprint_lock+0xa>
  int n = 0;
    80000fe4:	4501                	li	a0,0
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
                 lk->name, lk->nts, lk->n);
  }
  return n;
}
    80000fe6:	8082                	ret
{
    80000fe8:	1141                	addi	sp,sp,-16
    80000fea:	e406                	sd	ra,8(sp)
    80000fec:	e022                	sd	s0,0(sp)
    80000fee:	0800                	addi	s0,sp,16
    n = snprintf(buf, sz, "lock: %s: #fetch-and-add %d #acquire() %d\n",
    80000ff0:	4e18                	lw	a4,24(a2)
    80000ff2:	6614                	ld	a3,8(a2)
    80000ff4:	00007617          	auipc	a2,0x7
    80000ff8:	0bc60613          	addi	a2,a2,188 # 800080b0 <digits+0x70>
    80000ffc:	00005097          	auipc	ra,0x5
    80001000:	7ce080e7          	jalr	1998(ra) # 800067ca <snprintf>
}
    80001004:	60a2                	ld	ra,8(sp)
    80001006:	6402                	ld	s0,0(sp)
    80001008:	0141                	addi	sp,sp,16
    8000100a:	8082                	ret

000000008000100c <statslock>:

int
statslock(char *buf, int sz) {
    8000100c:	7159                	addi	sp,sp,-112
    8000100e:	f486                	sd	ra,104(sp)
    80001010:	f0a2                	sd	s0,96(sp)
    80001012:	eca6                	sd	s1,88(sp)
    80001014:	e8ca                	sd	s2,80(sp)
    80001016:	e4ce                	sd	s3,72(sp)
    80001018:	e0d2                	sd	s4,64(sp)
    8000101a:	fc56                	sd	s5,56(sp)
    8000101c:	f85a                	sd	s6,48(sp)
    8000101e:	f45e                	sd	s7,40(sp)
    80001020:	f062                	sd	s8,32(sp)
    80001022:	ec66                	sd	s9,24(sp)
    80001024:	e86a                	sd	s10,16(sp)
    80001026:	e46e                	sd	s11,8(sp)
    80001028:	1880                	addi	s0,sp,112
    8000102a:	8aaa                	mv	s5,a0
    8000102c:	8b2e                	mv	s6,a1
  int n;
  int tot = 0;

  acquire(&lock_locks);
    8000102e:	00010517          	auipc	a0,0x10
    80001032:	39a50513          	addi	a0,a0,922 # 800113c8 <lock_locks>
    80001036:	00000097          	auipc	ra,0x0
    8000103a:	dac080e7          	jalr	-596(ra) # 80000de2 <acquire>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    8000103e:	00007617          	auipc	a2,0x7
    80001042:	0a260613          	addi	a2,a2,162 # 800080e0 <digits+0xa0>
    80001046:	85da                	mv	a1,s6
    80001048:	8556                	mv	a0,s5
    8000104a:	00005097          	auipc	ra,0x5
    8000104e:	780080e7          	jalr	1920(ra) # 800067ca <snprintf>
    80001052:	892a                	mv	s2,a0
  for(int i = 0; i < NLOCK; i++) {
    80001054:	00010c97          	auipc	s9,0x10
    80001058:	394c8c93          	addi	s9,s9,916 # 800113e8 <locks>
    8000105c:	00011c17          	auipc	s8,0x11
    80001060:	32cc0c13          	addi	s8,s8,812 # 80012388 <pid_lock>
  n = snprintf(buf, sz, "--- lock kmem/bcache stats\n");
    80001064:	84e6                	mv	s1,s9
  int tot = 0;
    80001066:	4a01                	li	s4,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80001068:	00007b97          	auipc	s7,0x7
    8000106c:	098b8b93          	addi	s7,s7,152 # 80008100 <digits+0xc0>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80001070:	00007d17          	auipc	s10,0x7
    80001074:	ff8d0d13          	addi	s10,s10,-8 # 80008068 <digits+0x28>
    80001078:	a01d                	j	8000109e <statslock+0x92>
      tot += locks[i]->nts;
    8000107a:	0009b603          	ld	a2,0(s3)
    8000107e:	4e1c                	lw	a5,24(a2)
    80001080:	01478a3b          	addw	s4,a5,s4
      n += snprint_lock(buf +n, sz-n, locks[i]);
    80001084:	412b05bb          	subw	a1,s6,s2
    80001088:	012a8533          	add	a0,s5,s2
    8000108c:	00000097          	auipc	ra,0x0
    80001090:	f52080e7          	jalr	-174(ra) # 80000fde <snprint_lock>
    80001094:	0125093b          	addw	s2,a0,s2
  for(int i = 0; i < NLOCK; i++) {
    80001098:	04a1                	addi	s1,s1,8
    8000109a:	05848763          	beq	s1,s8,800010e8 <statslock+0xdc>
    if(locks[i] == 0)
    8000109e:	89a6                	mv	s3,s1
    800010a0:	609c                	ld	a5,0(s1)
    800010a2:	c3b9                	beqz	a5,800010e8 <statslock+0xdc>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    800010a4:	0087bd83          	ld	s11,8(a5)
    800010a8:	855e                	mv	a0,s7
    800010aa:	00000097          	auipc	ra,0x0
    800010ae:	2a0080e7          	jalr	672(ra) # 8000134a <strlen>
    800010b2:	0005061b          	sext.w	a2,a0
    800010b6:	85de                	mv	a1,s7
    800010b8:	856e                	mv	a0,s11
    800010ba:	00000097          	auipc	ra,0x0
    800010be:	1e4080e7          	jalr	484(ra) # 8000129e <strncmp>
    800010c2:	dd45                	beqz	a0,8000107a <statslock+0x6e>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    800010c4:	609c                	ld	a5,0(s1)
    800010c6:	0087bd83          	ld	s11,8(a5)
    800010ca:	856a                	mv	a0,s10
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	27e080e7          	jalr	638(ra) # 8000134a <strlen>
    800010d4:	0005061b          	sext.w	a2,a0
    800010d8:	85ea                	mv	a1,s10
    800010da:	856e                	mv	a0,s11
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	1c2080e7          	jalr	450(ra) # 8000129e <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    800010e4:	f955                	bnez	a0,80001098 <statslock+0x8c>
    800010e6:	bf51                	j	8000107a <statslock+0x6e>
    }
  }
  
  n += snprintf(buf+n, sz-n, "--- top 5 contended locks:\n");
    800010e8:	00007617          	auipc	a2,0x7
    800010ec:	02060613          	addi	a2,a2,32 # 80008108 <digits+0xc8>
    800010f0:	412b05bb          	subw	a1,s6,s2
    800010f4:	012a8533          	add	a0,s5,s2
    800010f8:	00005097          	auipc	ra,0x5
    800010fc:	6d2080e7          	jalr	1746(ra) # 800067ca <snprintf>
    80001100:	012509bb          	addw	s3,a0,s2
    80001104:	4b95                	li	s7,5
  int last = 100000000;
    80001106:	05f5e537          	lui	a0,0x5f5e
    8000110a:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t = 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    8000110e:	4c01                	li	s8,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80001110:	00010497          	auipc	s1,0x10
    80001114:	2d848493          	addi	s1,s1,728 # 800113e8 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80001118:	1f400913          	li	s2,500
    8000111c:	a881                	j	8000116c <statslock+0x160>
    8000111e:	2705                	addiw	a4,a4,1
    80001120:	06a1                	addi	a3,a3,8
    80001122:	03270063          	beq	a4,s2,80001142 <statslock+0x136>
      if(locks[i] == 0)
    80001126:	629c                	ld	a5,0(a3)
    80001128:	cf89                	beqz	a5,80001142 <statslock+0x136>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    8000112a:	4f90                	lw	a2,24(a5)
    8000112c:	00359793          	slli	a5,a1,0x3
    80001130:	97a6                	add	a5,a5,s1
    80001132:	639c                	ld	a5,0(a5)
    80001134:	4f9c                	lw	a5,24(a5)
    80001136:	fec7d4e3          	bge	a5,a2,8000111e <statslock+0x112>
    8000113a:	fea652e3          	bge	a2,a0,8000111e <statslock+0x112>
    8000113e:	85ba                	mv	a1,a4
    80001140:	bff9                	j	8000111e <statslock+0x112>
        top = i;
      }
    }
    n += snprint_lock(buf+n, sz-n, locks[top]);
    80001142:	058e                	slli	a1,a1,0x3
    80001144:	00b48d33          	add	s10,s1,a1
    80001148:	000d3603          	ld	a2,0(s10)
    8000114c:	413b05bb          	subw	a1,s6,s3
    80001150:	013a8533          	add	a0,s5,s3
    80001154:	00000097          	auipc	ra,0x0
    80001158:	e8a080e7          	jalr	-374(ra) # 80000fde <snprint_lock>
    8000115c:	013509bb          	addw	s3,a0,s3
    last = locks[top]->nts;
    80001160:	000d3783          	ld	a5,0(s10)
    80001164:	4f88                	lw	a0,24(a5)
  for(int t = 0; t < 5; t++) {
    80001166:	3bfd                	addiw	s7,s7,-1
    80001168:	000b8663          	beqz	s7,80001174 <statslock+0x168>
  int tot = 0;
    8000116c:	86e6                	mv	a3,s9
    for(int i = 0; i < NLOCK; i++) {
    8000116e:	8762                	mv	a4,s8
    int top = 0;
    80001170:	85e2                	mv	a1,s8
    80001172:	bf55                	j	80001126 <statslock+0x11a>
  }
  n += snprintf(buf+n, sz-n, "tot= %d\n", tot);
    80001174:	86d2                	mv	a3,s4
    80001176:	00007617          	auipc	a2,0x7
    8000117a:	fb260613          	addi	a2,a2,-78 # 80008128 <digits+0xe8>
    8000117e:	413b05bb          	subw	a1,s6,s3
    80001182:	013a8533          	add	a0,s5,s3
    80001186:	00005097          	auipc	ra,0x5
    8000118a:	644080e7          	jalr	1604(ra) # 800067ca <snprintf>
    8000118e:	013509bb          	addw	s3,a0,s3
  release(&lock_locks);  
    80001192:	00010517          	auipc	a0,0x10
    80001196:	23650513          	addi	a0,a0,566 # 800113c8 <lock_locks>
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	d18080e7          	jalr	-744(ra) # 80000eb2 <release>
  return n;
}
    800011a2:	854e                	mv	a0,s3
    800011a4:	70a6                	ld	ra,104(sp)
    800011a6:	7406                	ld	s0,96(sp)
    800011a8:	64e6                	ld	s1,88(sp)
    800011aa:	6946                	ld	s2,80(sp)
    800011ac:	69a6                	ld	s3,72(sp)
    800011ae:	6a06                	ld	s4,64(sp)
    800011b0:	7ae2                	ld	s5,56(sp)
    800011b2:	7b42                	ld	s6,48(sp)
    800011b4:	7ba2                	ld	s7,40(sp)
    800011b6:	7c02                	ld	s8,32(sp)
    800011b8:	6ce2                	ld	s9,24(sp)
    800011ba:	6d42                	ld	s10,16(sp)
    800011bc:	6da2                	ld	s11,8(sp)
    800011be:	6165                	addi	sp,sp,112
    800011c0:	8082                	ret

00000000800011c2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800011c2:	1141                	addi	sp,sp,-16
    800011c4:	e422                	sd	s0,8(sp)
    800011c6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800011c8:	ce09                	beqz	a2,800011e2 <memset+0x20>
    800011ca:	87aa                	mv	a5,a0
    800011cc:	fff6071b          	addiw	a4,a2,-1
    800011d0:	1702                	slli	a4,a4,0x20
    800011d2:	9301                	srli	a4,a4,0x20
    800011d4:	0705                	addi	a4,a4,1
    800011d6:	972a                	add	a4,a4,a0
    cdst[i] = c;
    800011d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800011dc:	0785                	addi	a5,a5,1
    800011de:	fee79de3          	bne	a5,a4,800011d8 <memset+0x16>
  }
  return dst;
}
    800011e2:	6422                	ld	s0,8(sp)
    800011e4:	0141                	addi	sp,sp,16
    800011e6:	8082                	ret

00000000800011e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800011e8:	1141                	addi	sp,sp,-16
    800011ea:	e422                	sd	s0,8(sp)
    800011ec:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800011ee:	ca05                	beqz	a2,8000121e <memcmp+0x36>
    800011f0:	fff6069b          	addiw	a3,a2,-1
    800011f4:	1682                	slli	a3,a3,0x20
    800011f6:	9281                	srli	a3,a3,0x20
    800011f8:	0685                	addi	a3,a3,1
    800011fa:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800011fc:	00054783          	lbu	a5,0(a0)
    80001200:	0005c703          	lbu	a4,0(a1)
    80001204:	00e79863          	bne	a5,a4,80001214 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80001208:	0505                	addi	a0,a0,1
    8000120a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000120c:	fed518e3          	bne	a0,a3,800011fc <memcmp+0x14>
  }

  return 0;
    80001210:	4501                	li	a0,0
    80001212:	a019                	j	80001218 <memcmp+0x30>
      return *s1 - *s2;
    80001214:	40e7853b          	subw	a0,a5,a4
}
    80001218:	6422                	ld	s0,8(sp)
    8000121a:	0141                	addi	sp,sp,16
    8000121c:	8082                	ret
  return 0;
    8000121e:	4501                	li	a0,0
    80001220:	bfe5                	j	80001218 <memcmp+0x30>

0000000080001222 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e422                	sd	s0,8(sp)
    80001226:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80001228:	02a5e563          	bltu	a1,a0,80001252 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000122c:	fff6069b          	addiw	a3,a2,-1
    80001230:	ce11                	beqz	a2,8000124c <memmove+0x2a>
    80001232:	1682                	slli	a3,a3,0x20
    80001234:	9281                	srli	a3,a3,0x20
    80001236:	0685                	addi	a3,a3,1
    80001238:	96ae                	add	a3,a3,a1
    8000123a:	87aa                	mv	a5,a0
      *d++ = *s++;
    8000123c:	0585                	addi	a1,a1,1
    8000123e:	0785                	addi	a5,a5,1
    80001240:	fff5c703          	lbu	a4,-1(a1)
    80001244:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80001248:	fed59ae3          	bne	a1,a3,8000123c <memmove+0x1a>

  return dst;
}
    8000124c:	6422                	ld	s0,8(sp)
    8000124e:	0141                	addi	sp,sp,16
    80001250:	8082                	ret
  if(s < d && s + n > d){
    80001252:	02061713          	slli	a4,a2,0x20
    80001256:	9301                	srli	a4,a4,0x20
    80001258:	00e587b3          	add	a5,a1,a4
    8000125c:	fcf578e3          	bgeu	a0,a5,8000122c <memmove+0xa>
    d += n;
    80001260:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80001262:	fff6069b          	addiw	a3,a2,-1
    80001266:	d27d                	beqz	a2,8000124c <memmove+0x2a>
    80001268:	02069613          	slli	a2,a3,0x20
    8000126c:	9201                	srli	a2,a2,0x20
    8000126e:	fff64613          	not	a2,a2
    80001272:	963e                	add	a2,a2,a5
      *--d = *--s;
    80001274:	17fd                	addi	a5,a5,-1
    80001276:	177d                	addi	a4,a4,-1
    80001278:	0007c683          	lbu	a3,0(a5)
    8000127c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80001280:	fec79ae3          	bne	a5,a2,80001274 <memmove+0x52>
    80001284:	b7e1                	j	8000124c <memmove+0x2a>

0000000080001286 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80001286:	1141                	addi	sp,sp,-16
    80001288:	e406                	sd	ra,8(sp)
    8000128a:	e022                	sd	s0,0(sp)
    8000128c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000128e:	00000097          	auipc	ra,0x0
    80001292:	f94080e7          	jalr	-108(ra) # 80001222 <memmove>
}
    80001296:	60a2                	ld	ra,8(sp)
    80001298:	6402                	ld	s0,0(sp)
    8000129a:	0141                	addi	sp,sp,16
    8000129c:	8082                	ret

000000008000129e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000129e:	1141                	addi	sp,sp,-16
    800012a0:	e422                	sd	s0,8(sp)
    800012a2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800012a4:	ce11                	beqz	a2,800012c0 <strncmp+0x22>
    800012a6:	00054783          	lbu	a5,0(a0)
    800012aa:	cf89                	beqz	a5,800012c4 <strncmp+0x26>
    800012ac:	0005c703          	lbu	a4,0(a1)
    800012b0:	00f71a63          	bne	a4,a5,800012c4 <strncmp+0x26>
    n--, p++, q++;
    800012b4:	367d                	addiw	a2,a2,-1
    800012b6:	0505                	addi	a0,a0,1
    800012b8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800012ba:	f675                	bnez	a2,800012a6 <strncmp+0x8>
  if(n == 0)
    return 0;
    800012bc:	4501                	li	a0,0
    800012be:	a809                	j	800012d0 <strncmp+0x32>
    800012c0:	4501                	li	a0,0
    800012c2:	a039                	j	800012d0 <strncmp+0x32>
  if(n == 0)
    800012c4:	ca09                	beqz	a2,800012d6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800012c6:	00054503          	lbu	a0,0(a0)
    800012ca:	0005c783          	lbu	a5,0(a1)
    800012ce:	9d1d                	subw	a0,a0,a5
}
    800012d0:	6422                	ld	s0,8(sp)
    800012d2:	0141                	addi	sp,sp,16
    800012d4:	8082                	ret
    return 0;
    800012d6:	4501                	li	a0,0
    800012d8:	bfe5                	j	800012d0 <strncmp+0x32>

00000000800012da <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800012da:	1141                	addi	sp,sp,-16
    800012dc:	e422                	sd	s0,8(sp)
    800012de:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800012e0:	872a                	mv	a4,a0
    800012e2:	8832                	mv	a6,a2
    800012e4:	367d                	addiw	a2,a2,-1
    800012e6:	01005963          	blez	a6,800012f8 <strncpy+0x1e>
    800012ea:	0705                	addi	a4,a4,1
    800012ec:	0005c783          	lbu	a5,0(a1)
    800012f0:	fef70fa3          	sb	a5,-1(a4)
    800012f4:	0585                	addi	a1,a1,1
    800012f6:	f7f5                	bnez	a5,800012e2 <strncpy+0x8>
    ;
  while(n-- > 0)
    800012f8:	86ba                	mv	a3,a4
    800012fa:	00c05c63          	blez	a2,80001312 <strncpy+0x38>
    *s++ = 0;
    800012fe:	0685                	addi	a3,a3,1
    80001300:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001304:	fff6c793          	not	a5,a3
    80001308:	9fb9                	addw	a5,a5,a4
    8000130a:	010787bb          	addw	a5,a5,a6
    8000130e:	fef048e3          	bgtz	a5,800012fe <strncpy+0x24>
  return os;
}
    80001312:	6422                	ld	s0,8(sp)
    80001314:	0141                	addi	sp,sp,16
    80001316:	8082                	ret

0000000080001318 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80001318:	1141                	addi	sp,sp,-16
    8000131a:	e422                	sd	s0,8(sp)
    8000131c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000131e:	02c05363          	blez	a2,80001344 <safestrcpy+0x2c>
    80001322:	fff6069b          	addiw	a3,a2,-1
    80001326:	1682                	slli	a3,a3,0x20
    80001328:	9281                	srli	a3,a3,0x20
    8000132a:	96ae                	add	a3,a3,a1
    8000132c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000132e:	00d58963          	beq	a1,a3,80001340 <safestrcpy+0x28>
    80001332:	0585                	addi	a1,a1,1
    80001334:	0785                	addi	a5,a5,1
    80001336:	fff5c703          	lbu	a4,-1(a1)
    8000133a:	fee78fa3          	sb	a4,-1(a5)
    8000133e:	fb65                	bnez	a4,8000132e <safestrcpy+0x16>
    ;
  *s = 0;
    80001340:	00078023          	sb	zero,0(a5)
  return os;
}
    80001344:	6422                	ld	s0,8(sp)
    80001346:	0141                	addi	sp,sp,16
    80001348:	8082                	ret

000000008000134a <strlen>:

int
strlen(const char *s)
{
    8000134a:	1141                	addi	sp,sp,-16
    8000134c:	e422                	sd	s0,8(sp)
    8000134e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001350:	00054783          	lbu	a5,0(a0)
    80001354:	cf91                	beqz	a5,80001370 <strlen+0x26>
    80001356:	0505                	addi	a0,a0,1
    80001358:	87aa                	mv	a5,a0
    8000135a:	4685                	li	a3,1
    8000135c:	9e89                	subw	a3,a3,a0
    8000135e:	00f6853b          	addw	a0,a3,a5
    80001362:	0785                	addi	a5,a5,1
    80001364:	fff7c703          	lbu	a4,-1(a5)
    80001368:	fb7d                	bnez	a4,8000135e <strlen+0x14>
    ;
  return n;
}
    8000136a:	6422                	ld	s0,8(sp)
    8000136c:	0141                	addi	sp,sp,16
    8000136e:	8082                	ret
  for(n = 0; s[n]; n++)
    80001370:	4501                	li	a0,0
    80001372:	bfe5                	j	8000136a <strlen+0x20>

0000000080001374 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001374:	1141                	addi	sp,sp,-16
    80001376:	e406                	sd	ra,8(sp)
    80001378:	e022                	sd	s0,0(sp)
    8000137a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000137c:	00001097          	auipc	ra,0x1
    80001380:	a82080e7          	jalr	-1406(ra) # 80001dfe <cpuid>
#endif    
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001384:	00008717          	auipc	a4,0x8
    80001388:	c8870713          	addi	a4,a4,-888 # 8000900c <started>
  if(cpuid() == 0){
    8000138c:	c139                	beqz	a0,800013d2 <main+0x5e>
    while(started == 0)
    8000138e:	431c                	lw	a5,0(a4)
    80001390:	2781                	sext.w	a5,a5
    80001392:	dff5                	beqz	a5,8000138e <main+0x1a>
      ;
    __sync_synchronize();
    80001394:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001398:	00001097          	auipc	ra,0x1
    8000139c:	a66080e7          	jalr	-1434(ra) # 80001dfe <cpuid>
    800013a0:	85aa                	mv	a1,a0
    800013a2:	00007517          	auipc	a0,0x7
    800013a6:	dae50513          	addi	a0,a0,-594 # 80008150 <digits+0x110>
    800013aa:	fffff097          	auipc	ra,0xfffff
    800013ae:	1f0080e7          	jalr	496(ra) # 8000059a <printf>
    kvminithart();    // turn on paging
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	186080e7          	jalr	390(ra) # 80001538 <kvminithart>
    trapinithart();   // install kernel trap vector
    800013ba:	00001097          	auipc	ra,0x1
    800013be:	6cc080e7          	jalr	1740(ra) # 80002a86 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800013c2:	00005097          	auipc	ra,0x5
    800013c6:	c7e080e7          	jalr	-898(ra) # 80006040 <plicinithart>
  }

  scheduler();        
    800013ca:	00001097          	auipc	ra,0x1
    800013ce:	f90080e7          	jalr	-112(ra) # 8000235a <scheduler>
    consoleinit();
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	090080e7          	jalr	144(ra) # 80000462 <consoleinit>
    statsinit();
    800013da:	00005097          	auipc	ra,0x5
    800013de:	314080e7          	jalr	788(ra) # 800066ee <statsinit>
    printfinit();
    800013e2:	fffff097          	auipc	ra,0xfffff
    800013e6:	39e080e7          	jalr	926(ra) # 80000780 <printfinit>
    printf("\n");
    800013ea:	00007517          	auipc	a0,0x7
    800013ee:	d7650513          	addi	a0,a0,-650 # 80008160 <digits+0x120>
    800013f2:	fffff097          	auipc	ra,0xfffff
    800013f6:	1a8080e7          	jalr	424(ra) # 8000059a <printf>
    printf("xv6 kernel is booting\n");
    800013fa:	00007517          	auipc	a0,0x7
    800013fe:	d3e50513          	addi	a0,a0,-706 # 80008138 <digits+0xf8>
    80001402:	fffff097          	auipc	ra,0xfffff
    80001406:	198080e7          	jalr	408(ra) # 8000059a <printf>
    printf("\n");
    8000140a:	00007517          	auipc	a0,0x7
    8000140e:	d5650513          	addi	a0,a0,-682 # 80008160 <digits+0x120>
    80001412:	fffff097          	auipc	ra,0xfffff
    80001416:	188080e7          	jalr	392(ra) # 8000059a <printf>
    kinit();         // physical page allocator
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6da080e7          	jalr	1754(ra) # 80000af4 <kinit>
    kvminit();       // create kernel page table
    80001422:	00000097          	auipc	ra,0x0
    80001426:	242080e7          	jalr	578(ra) # 80001664 <kvminit>
    kvminithart();   // turn on paging
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	10e080e7          	jalr	270(ra) # 80001538 <kvminithart>
    procinit();      // process table
    80001432:	00001097          	auipc	ra,0x1
    80001436:	8fc080e7          	jalr	-1796(ra) # 80001d2e <procinit>
    trapinit();      // trap vectors
    8000143a:	00001097          	auipc	ra,0x1
    8000143e:	624080e7          	jalr	1572(ra) # 80002a5e <trapinit>
    trapinithart();  // install kernel trap vector
    80001442:	00001097          	auipc	ra,0x1
    80001446:	644080e7          	jalr	1604(ra) # 80002a86 <trapinithart>
    plicinit();      // set up interrupt controller
    8000144a:	00005097          	auipc	ra,0x5
    8000144e:	be0080e7          	jalr	-1056(ra) # 8000602a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001452:	00005097          	auipc	ra,0x5
    80001456:	bee080e7          	jalr	-1042(ra) # 80006040 <plicinithart>
    binit();         // buffer cache
    8000145a:	00002097          	auipc	ra,0x2
    8000145e:	d6e080e7          	jalr	-658(ra) # 800031c8 <binit>
    iinit();         // inode cache
    80001462:	00002097          	auipc	ra,0x2
    80001466:	3fe080e7          	jalr	1022(ra) # 80003860 <iinit>
    fileinit();      // file table
    8000146a:	00003097          	auipc	ra,0x3
    8000146e:	3ae080e7          	jalr	942(ra) # 80004818 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001472:	00005097          	auipc	ra,0x5
    80001476:	cf0080e7          	jalr	-784(ra) # 80006162 <virtio_disk_init>
    userinit();      // first user process
    8000147a:	00001097          	auipc	ra,0x1
    8000147e:	c7a080e7          	jalr	-902(ra) # 800020f4 <userinit>
    __sync_synchronize();
    80001482:	0ff0000f          	fence
    started = 1;
    80001486:	4785                	li	a5,1
    80001488:	00008717          	auipc	a4,0x8
    8000148c:	b8f72223          	sw	a5,-1148(a4) # 8000900c <started>
    80001490:	bf2d                	j	800013ca <main+0x56>

0000000080001492 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001492:	7139                	addi	sp,sp,-64
    80001494:	fc06                	sd	ra,56(sp)
    80001496:	f822                	sd	s0,48(sp)
    80001498:	f426                	sd	s1,40(sp)
    8000149a:	f04a                	sd	s2,32(sp)
    8000149c:	ec4e                	sd	s3,24(sp)
    8000149e:	e852                	sd	s4,16(sp)
    800014a0:	e456                	sd	s5,8(sp)
    800014a2:	e05a                	sd	s6,0(sp)
    800014a4:	0080                	addi	s0,sp,64
    800014a6:	84aa                	mv	s1,a0
    800014a8:	89ae                	mv	s3,a1
    800014aa:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800014ac:	57fd                	li	a5,-1
    800014ae:	83e9                	srli	a5,a5,0x1a
    800014b0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800014b2:	4b31                	li	s6,12
  if(va >= MAXVA)
    800014b4:	04b7f263          	bgeu	a5,a1,800014f8 <walk+0x66>
    panic("walk");
    800014b8:	00007517          	auipc	a0,0x7
    800014bc:	cb050513          	addi	a0,a0,-848 # 80008168 <digits+0x128>
    800014c0:	fffff097          	auipc	ra,0xfffff
    800014c4:	090080e7          	jalr	144(ra) # 80000550 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800014c8:	060a8663          	beqz	s5,80001534 <walk+0xa2>
    800014cc:	fffff097          	auipc	ra,0xfffff
    800014d0:	7ac080e7          	jalr	1964(ra) # 80000c78 <kalloc>
    800014d4:	84aa                	mv	s1,a0
    800014d6:	c529                	beqz	a0,80001520 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800014d8:	6605                	lui	a2,0x1
    800014da:	4581                	li	a1,0
    800014dc:	00000097          	auipc	ra,0x0
    800014e0:	ce6080e7          	jalr	-794(ra) # 800011c2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800014e4:	00c4d793          	srli	a5,s1,0xc
    800014e8:	07aa                	slli	a5,a5,0xa
    800014ea:	0017e793          	ori	a5,a5,1
    800014ee:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800014f2:	3a5d                	addiw	s4,s4,-9
    800014f4:	036a0063          	beq	s4,s6,80001514 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800014f8:	0149d933          	srl	s2,s3,s4
    800014fc:	1ff97913          	andi	s2,s2,511
    80001500:	090e                	slli	s2,s2,0x3
    80001502:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001504:	00093483          	ld	s1,0(s2)
    80001508:	0014f793          	andi	a5,s1,1
    8000150c:	dfd5                	beqz	a5,800014c8 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000150e:	80a9                	srli	s1,s1,0xa
    80001510:	04b2                	slli	s1,s1,0xc
    80001512:	b7c5                	j	800014f2 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001514:	00c9d513          	srli	a0,s3,0xc
    80001518:	1ff57513          	andi	a0,a0,511
    8000151c:	050e                	slli	a0,a0,0x3
    8000151e:	9526                	add	a0,a0,s1
}
    80001520:	70e2                	ld	ra,56(sp)
    80001522:	7442                	ld	s0,48(sp)
    80001524:	74a2                	ld	s1,40(sp)
    80001526:	7902                	ld	s2,32(sp)
    80001528:	69e2                	ld	s3,24(sp)
    8000152a:	6a42                	ld	s4,16(sp)
    8000152c:	6aa2                	ld	s5,8(sp)
    8000152e:	6b02                	ld	s6,0(sp)
    80001530:	6121                	addi	sp,sp,64
    80001532:	8082                	ret
        return 0;
    80001534:	4501                	li	a0,0
    80001536:	b7ed                	j	80001520 <walk+0x8e>

0000000080001538 <kvminithart>:
{
    80001538:	1141                	addi	sp,sp,-16
    8000153a:	e422                	sd	s0,8(sp)
    8000153c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000153e:	00008797          	auipc	a5,0x8
    80001542:	ad27b783          	ld	a5,-1326(a5) # 80009010 <kernel_pagetable>
    80001546:	83b1                	srli	a5,a5,0xc
    80001548:	577d                	li	a4,-1
    8000154a:	177e                	slli	a4,a4,0x3f
    8000154c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000154e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001552:	12000073          	sfence.vma
}
    80001556:	6422                	ld	s0,8(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret

000000008000155c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000155c:	57fd                	li	a5,-1
    8000155e:	83e9                	srli	a5,a5,0x1a
    80001560:	00b7f463          	bgeu	a5,a1,80001568 <walkaddr+0xc>
    return 0;
    80001564:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001566:	8082                	ret
{
    80001568:	1141                	addi	sp,sp,-16
    8000156a:	e406                	sd	ra,8(sp)
    8000156c:	e022                	sd	s0,0(sp)
    8000156e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001570:	4601                	li	a2,0
    80001572:	00000097          	auipc	ra,0x0
    80001576:	f20080e7          	jalr	-224(ra) # 80001492 <walk>
  if(pte == 0)
    8000157a:	c105                	beqz	a0,8000159a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000157c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000157e:	0117f693          	andi	a3,a5,17
    80001582:	4745                	li	a4,17
    return 0;
    80001584:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001586:	00e68663          	beq	a3,a4,80001592 <walkaddr+0x36>
}
    8000158a:	60a2                	ld	ra,8(sp)
    8000158c:	6402                	ld	s0,0(sp)
    8000158e:	0141                	addi	sp,sp,16
    80001590:	8082                	ret
  pa = PTE2PA(*pte);
    80001592:	00a7d513          	srli	a0,a5,0xa
    80001596:	0532                	slli	a0,a0,0xc
  return pa;
    80001598:	bfcd                	j	8000158a <walkaddr+0x2e>
    return 0;
    8000159a:	4501                	li	a0,0
    8000159c:	b7fd                	j	8000158a <walkaddr+0x2e>

000000008000159e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000159e:	715d                	addi	sp,sp,-80
    800015a0:	e486                	sd	ra,72(sp)
    800015a2:	e0a2                	sd	s0,64(sp)
    800015a4:	fc26                	sd	s1,56(sp)
    800015a6:	f84a                	sd	s2,48(sp)
    800015a8:	f44e                	sd	s3,40(sp)
    800015aa:	f052                	sd	s4,32(sp)
    800015ac:	ec56                	sd	s5,24(sp)
    800015ae:	e85a                	sd	s6,16(sp)
    800015b0:	e45e                	sd	s7,8(sp)
    800015b2:	0880                	addi	s0,sp,80
    800015b4:	8aaa                	mv	s5,a0
    800015b6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800015b8:	777d                	lui	a4,0xfffff
    800015ba:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800015be:	167d                	addi	a2,a2,-1
    800015c0:	00b609b3          	add	s3,a2,a1
    800015c4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800015c8:	893e                	mv	s2,a5
    800015ca:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800015ce:	6b85                	lui	s7,0x1
    800015d0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800015d4:	4605                	li	a2,1
    800015d6:	85ca                	mv	a1,s2
    800015d8:	8556                	mv	a0,s5
    800015da:	00000097          	auipc	ra,0x0
    800015de:	eb8080e7          	jalr	-328(ra) # 80001492 <walk>
    800015e2:	c51d                	beqz	a0,80001610 <mappages+0x72>
    if(*pte & PTE_V)
    800015e4:	611c                	ld	a5,0(a0)
    800015e6:	8b85                	andi	a5,a5,1
    800015e8:	ef81                	bnez	a5,80001600 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800015ea:	80b1                	srli	s1,s1,0xc
    800015ec:	04aa                	slli	s1,s1,0xa
    800015ee:	0164e4b3          	or	s1,s1,s6
    800015f2:	0014e493          	ori	s1,s1,1
    800015f6:	e104                	sd	s1,0(a0)
    if(a == last)
    800015f8:	03390863          	beq	s2,s3,80001628 <mappages+0x8a>
    a += PGSIZE;
    800015fc:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800015fe:	bfc9                	j	800015d0 <mappages+0x32>
      panic("remap");
    80001600:	00007517          	auipc	a0,0x7
    80001604:	b7050513          	addi	a0,a0,-1168 # 80008170 <digits+0x130>
    80001608:	fffff097          	auipc	ra,0xfffff
    8000160c:	f48080e7          	jalr	-184(ra) # 80000550 <panic>
      return -1;
    80001610:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001612:	60a6                	ld	ra,72(sp)
    80001614:	6406                	ld	s0,64(sp)
    80001616:	74e2                	ld	s1,56(sp)
    80001618:	7942                	ld	s2,48(sp)
    8000161a:	79a2                	ld	s3,40(sp)
    8000161c:	7a02                	ld	s4,32(sp)
    8000161e:	6ae2                	ld	s5,24(sp)
    80001620:	6b42                	ld	s6,16(sp)
    80001622:	6ba2                	ld	s7,8(sp)
    80001624:	6161                	addi	sp,sp,80
    80001626:	8082                	ret
  return 0;
    80001628:	4501                	li	a0,0
    8000162a:	b7e5                	j	80001612 <mappages+0x74>

000000008000162c <kvmmap>:
{
    8000162c:	1141                	addi	sp,sp,-16
    8000162e:	e406                	sd	ra,8(sp)
    80001630:	e022                	sd	s0,0(sp)
    80001632:	0800                	addi	s0,sp,16
    80001634:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001636:	86ae                	mv	a3,a1
    80001638:	85aa                	mv	a1,a0
    8000163a:	00008517          	auipc	a0,0x8
    8000163e:	9d653503          	ld	a0,-1578(a0) # 80009010 <kernel_pagetable>
    80001642:	00000097          	auipc	ra,0x0
    80001646:	f5c080e7          	jalr	-164(ra) # 8000159e <mappages>
    8000164a:	e509                	bnez	a0,80001654 <kvmmap+0x28>
}
    8000164c:	60a2                	ld	ra,8(sp)
    8000164e:	6402                	ld	s0,0(sp)
    80001650:	0141                	addi	sp,sp,16
    80001652:	8082                	ret
    panic("kvmmap");
    80001654:	00007517          	auipc	a0,0x7
    80001658:	b2450513          	addi	a0,a0,-1244 # 80008178 <digits+0x138>
    8000165c:	fffff097          	auipc	ra,0xfffff
    80001660:	ef4080e7          	jalr	-268(ra) # 80000550 <panic>

0000000080001664 <kvminit>:
{
    80001664:	1101                	addi	sp,sp,-32
    80001666:	ec06                	sd	ra,24(sp)
    80001668:	e822                	sd	s0,16(sp)
    8000166a:	e426                	sd	s1,8(sp)
    8000166c:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	60a080e7          	jalr	1546(ra) # 80000c78 <kalloc>
    80001676:	00008797          	auipc	a5,0x8
    8000167a:	98a7bd23          	sd	a0,-1638(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000167e:	6605                	lui	a2,0x1
    80001680:	4581                	li	a1,0
    80001682:	00000097          	auipc	ra,0x0
    80001686:	b40080e7          	jalr	-1216(ra) # 800011c2 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000168a:	4699                	li	a3,6
    8000168c:	6605                	lui	a2,0x1
    8000168e:	100005b7          	lui	a1,0x10000
    80001692:	10000537          	lui	a0,0x10000
    80001696:	00000097          	auipc	ra,0x0
    8000169a:	f96080e7          	jalr	-106(ra) # 8000162c <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000169e:	4699                	li	a3,6
    800016a0:	6605                	lui	a2,0x1
    800016a2:	100015b7          	lui	a1,0x10001
    800016a6:	10001537          	lui	a0,0x10001
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	f82080e7          	jalr	-126(ra) # 8000162c <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800016b2:	4699                	li	a3,6
    800016b4:	00400637          	lui	a2,0x400
    800016b8:	0c0005b7          	lui	a1,0xc000
    800016bc:	0c000537          	lui	a0,0xc000
    800016c0:	00000097          	auipc	ra,0x0
    800016c4:	f6c080e7          	jalr	-148(ra) # 8000162c <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800016c8:	00007497          	auipc	s1,0x7
    800016cc:	93848493          	addi	s1,s1,-1736 # 80008000 <etext>
    800016d0:	46a9                	li	a3,10
    800016d2:	80007617          	auipc	a2,0x80007
    800016d6:	92e60613          	addi	a2,a2,-1746 # 8000 <_entry-0x7fff8000>
    800016da:	4585                	li	a1,1
    800016dc:	05fe                	slli	a1,a1,0x1f
    800016de:	852e                	mv	a0,a1
    800016e0:	00000097          	auipc	ra,0x0
    800016e4:	f4c080e7          	jalr	-180(ra) # 8000162c <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800016e8:	4699                	li	a3,6
    800016ea:	4645                	li	a2,17
    800016ec:	066e                	slli	a2,a2,0x1b
    800016ee:	8e05                	sub	a2,a2,s1
    800016f0:	85a6                	mv	a1,s1
    800016f2:	8526                	mv	a0,s1
    800016f4:	00000097          	auipc	ra,0x0
    800016f8:	f38080e7          	jalr	-200(ra) # 8000162c <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800016fc:	46a9                	li	a3,10
    800016fe:	6605                	lui	a2,0x1
    80001700:	00006597          	auipc	a1,0x6
    80001704:	90058593          	addi	a1,a1,-1792 # 80007000 <_trampoline>
    80001708:	04000537          	lui	a0,0x4000
    8000170c:	157d                	addi	a0,a0,-1
    8000170e:	0532                	slli	a0,a0,0xc
    80001710:	00000097          	auipc	ra,0x0
    80001714:	f1c080e7          	jalr	-228(ra) # 8000162c <kvmmap>
}
    80001718:	60e2                	ld	ra,24(sp)
    8000171a:	6442                	ld	s0,16(sp)
    8000171c:	64a2                	ld	s1,8(sp)
    8000171e:	6105                	addi	sp,sp,32
    80001720:	8082                	ret

0000000080001722 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001722:	715d                	addi	sp,sp,-80
    80001724:	e486                	sd	ra,72(sp)
    80001726:	e0a2                	sd	s0,64(sp)
    80001728:	fc26                	sd	s1,56(sp)
    8000172a:	f84a                	sd	s2,48(sp)
    8000172c:	f44e                	sd	s3,40(sp)
    8000172e:	f052                	sd	s4,32(sp)
    80001730:	ec56                	sd	s5,24(sp)
    80001732:	e85a                	sd	s6,16(sp)
    80001734:	e45e                	sd	s7,8(sp)
    80001736:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001738:	03459793          	slli	a5,a1,0x34
    8000173c:	e795                	bnez	a5,80001768 <uvmunmap+0x46>
    8000173e:	8a2a                	mv	s4,a0
    80001740:	892e                	mv	s2,a1
    80001742:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001744:	0632                	slli	a2,a2,0xc
    80001746:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000174a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000174c:	6b05                	lui	s6,0x1
    8000174e:	0735e863          	bltu	a1,s3,800017be <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001752:	60a6                	ld	ra,72(sp)
    80001754:	6406                	ld	s0,64(sp)
    80001756:	74e2                	ld	s1,56(sp)
    80001758:	7942                	ld	s2,48(sp)
    8000175a:	79a2                	ld	s3,40(sp)
    8000175c:	7a02                	ld	s4,32(sp)
    8000175e:	6ae2                	ld	s5,24(sp)
    80001760:	6b42                	ld	s6,16(sp)
    80001762:	6ba2                	ld	s7,8(sp)
    80001764:	6161                	addi	sp,sp,80
    80001766:	8082                	ret
    panic("uvmunmap: not aligned");
    80001768:	00007517          	auipc	a0,0x7
    8000176c:	a1850513          	addi	a0,a0,-1512 # 80008180 <digits+0x140>
    80001770:	fffff097          	auipc	ra,0xfffff
    80001774:	de0080e7          	jalr	-544(ra) # 80000550 <panic>
      panic("uvmunmap: walk");
    80001778:	00007517          	auipc	a0,0x7
    8000177c:	a2050513          	addi	a0,a0,-1504 # 80008198 <digits+0x158>
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	dd0080e7          	jalr	-560(ra) # 80000550 <panic>
      panic("uvmunmap: not mapped");
    80001788:	00007517          	auipc	a0,0x7
    8000178c:	a2050513          	addi	a0,a0,-1504 # 800081a8 <digits+0x168>
    80001790:	fffff097          	auipc	ra,0xfffff
    80001794:	dc0080e7          	jalr	-576(ra) # 80000550 <panic>
      panic("uvmunmap: not a leaf");
    80001798:	00007517          	auipc	a0,0x7
    8000179c:	a2850513          	addi	a0,a0,-1496 # 800081c0 <digits+0x180>
    800017a0:	fffff097          	auipc	ra,0xfffff
    800017a4:	db0080e7          	jalr	-592(ra) # 80000550 <panic>
      uint64 pa = PTE2PA(*pte);
    800017a8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800017aa:	0532                	slli	a0,a0,0xc
    800017ac:	fffff097          	auipc	ra,0xfffff
    800017b0:	3dc080e7          	jalr	988(ra) # 80000b88 <kfree>
    *pte = 0;
    800017b4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800017b8:	995a                	add	s2,s2,s6
    800017ba:	f9397ce3          	bgeu	s2,s3,80001752 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800017be:	4601                	li	a2,0
    800017c0:	85ca                	mv	a1,s2
    800017c2:	8552                	mv	a0,s4
    800017c4:	00000097          	auipc	ra,0x0
    800017c8:	cce080e7          	jalr	-818(ra) # 80001492 <walk>
    800017cc:	84aa                	mv	s1,a0
    800017ce:	d54d                	beqz	a0,80001778 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800017d0:	6108                	ld	a0,0(a0)
    800017d2:	00157793          	andi	a5,a0,1
    800017d6:	dbcd                	beqz	a5,80001788 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800017d8:	3ff57793          	andi	a5,a0,1023
    800017dc:	fb778ee3          	beq	a5,s7,80001798 <uvmunmap+0x76>
    if(do_free){
    800017e0:	fc0a8ae3          	beqz	s5,800017b4 <uvmunmap+0x92>
    800017e4:	b7d1                	j	800017a8 <uvmunmap+0x86>

00000000800017e6 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800017e6:	1101                	addi	sp,sp,-32
    800017e8:	ec06                	sd	ra,24(sp)
    800017ea:	e822                	sd	s0,16(sp)
    800017ec:	e426                	sd	s1,8(sp)
    800017ee:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800017f0:	fffff097          	auipc	ra,0xfffff
    800017f4:	488080e7          	jalr	1160(ra) # 80000c78 <kalloc>
    800017f8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800017fa:	c519                	beqz	a0,80001808 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800017fc:	6605                	lui	a2,0x1
    800017fe:	4581                	li	a1,0
    80001800:	00000097          	auipc	ra,0x0
    80001804:	9c2080e7          	jalr	-1598(ra) # 800011c2 <memset>
  return pagetable;
}
    80001808:	8526                	mv	a0,s1
    8000180a:	60e2                	ld	ra,24(sp)
    8000180c:	6442                	ld	s0,16(sp)
    8000180e:	64a2                	ld	s1,8(sp)
    80001810:	6105                	addi	sp,sp,32
    80001812:	8082                	ret

0000000080001814 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001814:	7179                	addi	sp,sp,-48
    80001816:	f406                	sd	ra,40(sp)
    80001818:	f022                	sd	s0,32(sp)
    8000181a:	ec26                	sd	s1,24(sp)
    8000181c:	e84a                	sd	s2,16(sp)
    8000181e:	e44e                	sd	s3,8(sp)
    80001820:	e052                	sd	s4,0(sp)
    80001822:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001824:	6785                	lui	a5,0x1
    80001826:	04f67863          	bgeu	a2,a5,80001876 <uvminit+0x62>
    8000182a:	8a2a                	mv	s4,a0
    8000182c:	89ae                	mv	s3,a1
    8000182e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001830:	fffff097          	auipc	ra,0xfffff
    80001834:	448080e7          	jalr	1096(ra) # 80000c78 <kalloc>
    80001838:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000183a:	6605                	lui	a2,0x1
    8000183c:	4581                	li	a1,0
    8000183e:	00000097          	auipc	ra,0x0
    80001842:	984080e7          	jalr	-1660(ra) # 800011c2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001846:	4779                	li	a4,30
    80001848:	86ca                	mv	a3,s2
    8000184a:	6605                	lui	a2,0x1
    8000184c:	4581                	li	a1,0
    8000184e:	8552                	mv	a0,s4
    80001850:	00000097          	auipc	ra,0x0
    80001854:	d4e080e7          	jalr	-690(ra) # 8000159e <mappages>
  memmove(mem, src, sz);
    80001858:	8626                	mv	a2,s1
    8000185a:	85ce                	mv	a1,s3
    8000185c:	854a                	mv	a0,s2
    8000185e:	00000097          	auipc	ra,0x0
    80001862:	9c4080e7          	jalr	-1596(ra) # 80001222 <memmove>
}
    80001866:	70a2                	ld	ra,40(sp)
    80001868:	7402                	ld	s0,32(sp)
    8000186a:	64e2                	ld	s1,24(sp)
    8000186c:	6942                	ld	s2,16(sp)
    8000186e:	69a2                	ld	s3,8(sp)
    80001870:	6a02                	ld	s4,0(sp)
    80001872:	6145                	addi	sp,sp,48
    80001874:	8082                	ret
    panic("inituvm: more than a page");
    80001876:	00007517          	auipc	a0,0x7
    8000187a:	96250513          	addi	a0,a0,-1694 # 800081d8 <digits+0x198>
    8000187e:	fffff097          	auipc	ra,0xfffff
    80001882:	cd2080e7          	jalr	-814(ra) # 80000550 <panic>

0000000080001886 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001886:	1101                	addi	sp,sp,-32
    80001888:	ec06                	sd	ra,24(sp)
    8000188a:	e822                	sd	s0,16(sp)
    8000188c:	e426                	sd	s1,8(sp)
    8000188e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001890:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001892:	00b67d63          	bgeu	a2,a1,800018ac <uvmdealloc+0x26>
    80001896:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001898:	6785                	lui	a5,0x1
    8000189a:	17fd                	addi	a5,a5,-1
    8000189c:	00f60733          	add	a4,a2,a5
    800018a0:	767d                	lui	a2,0xfffff
    800018a2:	8f71                	and	a4,a4,a2
    800018a4:	97ae                	add	a5,a5,a1
    800018a6:	8ff1                	and	a5,a5,a2
    800018a8:	00f76863          	bltu	a4,a5,800018b8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800018ac:	8526                	mv	a0,s1
    800018ae:	60e2                	ld	ra,24(sp)
    800018b0:	6442                	ld	s0,16(sp)
    800018b2:	64a2                	ld	s1,8(sp)
    800018b4:	6105                	addi	sp,sp,32
    800018b6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800018b8:	8f99                	sub	a5,a5,a4
    800018ba:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800018bc:	4685                	li	a3,1
    800018be:	0007861b          	sext.w	a2,a5
    800018c2:	85ba                	mv	a1,a4
    800018c4:	00000097          	auipc	ra,0x0
    800018c8:	e5e080e7          	jalr	-418(ra) # 80001722 <uvmunmap>
    800018cc:	b7c5                	j	800018ac <uvmdealloc+0x26>

00000000800018ce <uvmalloc>:
  if(newsz < oldsz)
    800018ce:	0ab66163          	bltu	a2,a1,80001970 <uvmalloc+0xa2>
{
    800018d2:	7139                	addi	sp,sp,-64
    800018d4:	fc06                	sd	ra,56(sp)
    800018d6:	f822                	sd	s0,48(sp)
    800018d8:	f426                	sd	s1,40(sp)
    800018da:	f04a                	sd	s2,32(sp)
    800018dc:	ec4e                	sd	s3,24(sp)
    800018de:	e852                	sd	s4,16(sp)
    800018e0:	e456                	sd	s5,8(sp)
    800018e2:	0080                	addi	s0,sp,64
    800018e4:	8aaa                	mv	s5,a0
    800018e6:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800018e8:	6985                	lui	s3,0x1
    800018ea:	19fd                	addi	s3,s3,-1
    800018ec:	95ce                	add	a1,a1,s3
    800018ee:	79fd                	lui	s3,0xfffff
    800018f0:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800018f4:	08c9f063          	bgeu	s3,a2,80001974 <uvmalloc+0xa6>
    800018f8:	894e                	mv	s2,s3
    mem = kalloc();
    800018fa:	fffff097          	auipc	ra,0xfffff
    800018fe:	37e080e7          	jalr	894(ra) # 80000c78 <kalloc>
    80001902:	84aa                	mv	s1,a0
    if(mem == 0){
    80001904:	c51d                	beqz	a0,80001932 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001906:	6605                	lui	a2,0x1
    80001908:	4581                	li	a1,0
    8000190a:	00000097          	auipc	ra,0x0
    8000190e:	8b8080e7          	jalr	-1864(ra) # 800011c2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001912:	4779                	li	a4,30
    80001914:	86a6                	mv	a3,s1
    80001916:	6605                	lui	a2,0x1
    80001918:	85ca                	mv	a1,s2
    8000191a:	8556                	mv	a0,s5
    8000191c:	00000097          	auipc	ra,0x0
    80001920:	c82080e7          	jalr	-894(ra) # 8000159e <mappages>
    80001924:	e905                	bnez	a0,80001954 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001926:	6785                	lui	a5,0x1
    80001928:	993e                	add	s2,s2,a5
    8000192a:	fd4968e3          	bltu	s2,s4,800018fa <uvmalloc+0x2c>
  return newsz;
    8000192e:	8552                	mv	a0,s4
    80001930:	a809                	j	80001942 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001932:	864e                	mv	a2,s3
    80001934:	85ca                	mv	a1,s2
    80001936:	8556                	mv	a0,s5
    80001938:	00000097          	auipc	ra,0x0
    8000193c:	f4e080e7          	jalr	-178(ra) # 80001886 <uvmdealloc>
      return 0;
    80001940:	4501                	li	a0,0
}
    80001942:	70e2                	ld	ra,56(sp)
    80001944:	7442                	ld	s0,48(sp)
    80001946:	74a2                	ld	s1,40(sp)
    80001948:	7902                	ld	s2,32(sp)
    8000194a:	69e2                	ld	s3,24(sp)
    8000194c:	6a42                	ld	s4,16(sp)
    8000194e:	6aa2                	ld	s5,8(sp)
    80001950:	6121                	addi	sp,sp,64
    80001952:	8082                	ret
      kfree(mem);
    80001954:	8526                	mv	a0,s1
    80001956:	fffff097          	auipc	ra,0xfffff
    8000195a:	232080e7          	jalr	562(ra) # 80000b88 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000195e:	864e                	mv	a2,s3
    80001960:	85ca                	mv	a1,s2
    80001962:	8556                	mv	a0,s5
    80001964:	00000097          	auipc	ra,0x0
    80001968:	f22080e7          	jalr	-222(ra) # 80001886 <uvmdealloc>
      return 0;
    8000196c:	4501                	li	a0,0
    8000196e:	bfd1                	j	80001942 <uvmalloc+0x74>
    return oldsz;
    80001970:	852e                	mv	a0,a1
}
    80001972:	8082                	ret
  return newsz;
    80001974:	8532                	mv	a0,a2
    80001976:	b7f1                	j	80001942 <uvmalloc+0x74>

0000000080001978 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001978:	7179                	addi	sp,sp,-48
    8000197a:	f406                	sd	ra,40(sp)
    8000197c:	f022                	sd	s0,32(sp)
    8000197e:	ec26                	sd	s1,24(sp)
    80001980:	e84a                	sd	s2,16(sp)
    80001982:	e44e                	sd	s3,8(sp)
    80001984:	e052                	sd	s4,0(sp)
    80001986:	1800                	addi	s0,sp,48
    80001988:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000198a:	84aa                	mv	s1,a0
    8000198c:	6905                	lui	s2,0x1
    8000198e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001990:	4985                	li	s3,1
    80001992:	a821                	j	800019aa <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001994:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001996:	0532                	slli	a0,a0,0xc
    80001998:	00000097          	auipc	ra,0x0
    8000199c:	fe0080e7          	jalr	-32(ra) # 80001978 <freewalk>
      pagetable[i] = 0;
    800019a0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800019a4:	04a1                	addi	s1,s1,8
    800019a6:	03248163          	beq	s1,s2,800019c8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800019aa:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800019ac:	00f57793          	andi	a5,a0,15
    800019b0:	ff3782e3          	beq	a5,s3,80001994 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800019b4:	8905                	andi	a0,a0,1
    800019b6:	d57d                	beqz	a0,800019a4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800019b8:	00007517          	auipc	a0,0x7
    800019bc:	84050513          	addi	a0,a0,-1984 # 800081f8 <digits+0x1b8>
    800019c0:	fffff097          	auipc	ra,0xfffff
    800019c4:	b90080e7          	jalr	-1136(ra) # 80000550 <panic>
    }
  }
  kfree((void*)pagetable);
    800019c8:	8552                	mv	a0,s4
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	1be080e7          	jalr	446(ra) # 80000b88 <kfree>
}
    800019d2:	70a2                	ld	ra,40(sp)
    800019d4:	7402                	ld	s0,32(sp)
    800019d6:	64e2                	ld	s1,24(sp)
    800019d8:	6942                	ld	s2,16(sp)
    800019da:	69a2                	ld	s3,8(sp)
    800019dc:	6a02                	ld	s4,0(sp)
    800019de:	6145                	addi	sp,sp,48
    800019e0:	8082                	ret

00000000800019e2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800019e2:	1101                	addi	sp,sp,-32
    800019e4:	ec06                	sd	ra,24(sp)
    800019e6:	e822                	sd	s0,16(sp)
    800019e8:	e426                	sd	s1,8(sp)
    800019ea:	1000                	addi	s0,sp,32
    800019ec:	84aa                	mv	s1,a0
  if(sz > 0)
    800019ee:	e999                	bnez	a1,80001a04 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800019f0:	8526                	mv	a0,s1
    800019f2:	00000097          	auipc	ra,0x0
    800019f6:	f86080e7          	jalr	-122(ra) # 80001978 <freewalk>
}
    800019fa:	60e2                	ld	ra,24(sp)
    800019fc:	6442                	ld	s0,16(sp)
    800019fe:	64a2                	ld	s1,8(sp)
    80001a00:	6105                	addi	sp,sp,32
    80001a02:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001a04:	6605                	lui	a2,0x1
    80001a06:	167d                	addi	a2,a2,-1
    80001a08:	962e                	add	a2,a2,a1
    80001a0a:	4685                	li	a3,1
    80001a0c:	8231                	srli	a2,a2,0xc
    80001a0e:	4581                	li	a1,0
    80001a10:	00000097          	auipc	ra,0x0
    80001a14:	d12080e7          	jalr	-750(ra) # 80001722 <uvmunmap>
    80001a18:	bfe1                	j	800019f0 <uvmfree+0xe>

0000000080001a1a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001a1a:	c679                	beqz	a2,80001ae8 <uvmcopy+0xce>
{
    80001a1c:	715d                	addi	sp,sp,-80
    80001a1e:	e486                	sd	ra,72(sp)
    80001a20:	e0a2                	sd	s0,64(sp)
    80001a22:	fc26                	sd	s1,56(sp)
    80001a24:	f84a                	sd	s2,48(sp)
    80001a26:	f44e                	sd	s3,40(sp)
    80001a28:	f052                	sd	s4,32(sp)
    80001a2a:	ec56                	sd	s5,24(sp)
    80001a2c:	e85a                	sd	s6,16(sp)
    80001a2e:	e45e                	sd	s7,8(sp)
    80001a30:	0880                	addi	s0,sp,80
    80001a32:	8b2a                	mv	s6,a0
    80001a34:	8aae                	mv	s5,a1
    80001a36:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001a38:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001a3a:	4601                	li	a2,0
    80001a3c:	85ce                	mv	a1,s3
    80001a3e:	855a                	mv	a0,s6
    80001a40:	00000097          	auipc	ra,0x0
    80001a44:	a52080e7          	jalr	-1454(ra) # 80001492 <walk>
    80001a48:	c531                	beqz	a0,80001a94 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001a4a:	6118                	ld	a4,0(a0)
    80001a4c:	00177793          	andi	a5,a4,1
    80001a50:	cbb1                	beqz	a5,80001aa4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001a52:	00a75593          	srli	a1,a4,0xa
    80001a56:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001a5a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	21a080e7          	jalr	538(ra) # 80000c78 <kalloc>
    80001a66:	892a                	mv	s2,a0
    80001a68:	c939                	beqz	a0,80001abe <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001a6a:	6605                	lui	a2,0x1
    80001a6c:	85de                	mv	a1,s7
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	7b4080e7          	jalr	1972(ra) # 80001222 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001a76:	8726                	mv	a4,s1
    80001a78:	86ca                	mv	a3,s2
    80001a7a:	6605                	lui	a2,0x1
    80001a7c:	85ce                	mv	a1,s3
    80001a7e:	8556                	mv	a0,s5
    80001a80:	00000097          	auipc	ra,0x0
    80001a84:	b1e080e7          	jalr	-1250(ra) # 8000159e <mappages>
    80001a88:	e515                	bnez	a0,80001ab4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001a8a:	6785                	lui	a5,0x1
    80001a8c:	99be                	add	s3,s3,a5
    80001a8e:	fb49e6e3          	bltu	s3,s4,80001a3a <uvmcopy+0x20>
    80001a92:	a081                	j	80001ad2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001a94:	00006517          	auipc	a0,0x6
    80001a98:	77450513          	addi	a0,a0,1908 # 80008208 <digits+0x1c8>
    80001a9c:	fffff097          	auipc	ra,0xfffff
    80001aa0:	ab4080e7          	jalr	-1356(ra) # 80000550 <panic>
      panic("uvmcopy: page not present");
    80001aa4:	00006517          	auipc	a0,0x6
    80001aa8:	78450513          	addi	a0,a0,1924 # 80008228 <digits+0x1e8>
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	aa4080e7          	jalr	-1372(ra) # 80000550 <panic>
      kfree(mem);
    80001ab4:	854a                	mv	a0,s2
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	0d2080e7          	jalr	210(ra) # 80000b88 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001abe:	4685                	li	a3,1
    80001ac0:	00c9d613          	srli	a2,s3,0xc
    80001ac4:	4581                	li	a1,0
    80001ac6:	8556                	mv	a0,s5
    80001ac8:	00000097          	auipc	ra,0x0
    80001acc:	c5a080e7          	jalr	-934(ra) # 80001722 <uvmunmap>
  return -1;
    80001ad0:	557d                	li	a0,-1
}
    80001ad2:	60a6                	ld	ra,72(sp)
    80001ad4:	6406                	ld	s0,64(sp)
    80001ad6:	74e2                	ld	s1,56(sp)
    80001ad8:	7942                	ld	s2,48(sp)
    80001ada:	79a2                	ld	s3,40(sp)
    80001adc:	7a02                	ld	s4,32(sp)
    80001ade:	6ae2                	ld	s5,24(sp)
    80001ae0:	6b42                	ld	s6,16(sp)
    80001ae2:	6ba2                	ld	s7,8(sp)
    80001ae4:	6161                	addi	sp,sp,80
    80001ae6:	8082                	ret
  return 0;
    80001ae8:	4501                	li	a0,0
}
    80001aea:	8082                	ret

0000000080001aec <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001aec:	1141                	addi	sp,sp,-16
    80001aee:	e406                	sd	ra,8(sp)
    80001af0:	e022                	sd	s0,0(sp)
    80001af2:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001af4:	4601                	li	a2,0
    80001af6:	00000097          	auipc	ra,0x0
    80001afa:	99c080e7          	jalr	-1636(ra) # 80001492 <walk>
  if(pte == 0)
    80001afe:	c901                	beqz	a0,80001b0e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001b00:	611c                	ld	a5,0(a0)
    80001b02:	9bbd                	andi	a5,a5,-17
    80001b04:	e11c                	sd	a5,0(a0)
}
    80001b06:	60a2                	ld	ra,8(sp)
    80001b08:	6402                	ld	s0,0(sp)
    80001b0a:	0141                	addi	sp,sp,16
    80001b0c:	8082                	ret
    panic("uvmclear");
    80001b0e:	00006517          	auipc	a0,0x6
    80001b12:	73a50513          	addi	a0,a0,1850 # 80008248 <digits+0x208>
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	a3a080e7          	jalr	-1478(ra) # 80000550 <panic>

0000000080001b1e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001b1e:	c6bd                	beqz	a3,80001b8c <copyout+0x6e>
{
    80001b20:	715d                	addi	sp,sp,-80
    80001b22:	e486                	sd	ra,72(sp)
    80001b24:	e0a2                	sd	s0,64(sp)
    80001b26:	fc26                	sd	s1,56(sp)
    80001b28:	f84a                	sd	s2,48(sp)
    80001b2a:	f44e                	sd	s3,40(sp)
    80001b2c:	f052                	sd	s4,32(sp)
    80001b2e:	ec56                	sd	s5,24(sp)
    80001b30:	e85a                	sd	s6,16(sp)
    80001b32:	e45e                	sd	s7,8(sp)
    80001b34:	e062                	sd	s8,0(sp)
    80001b36:	0880                	addi	s0,sp,80
    80001b38:	8b2a                	mv	s6,a0
    80001b3a:	8c2e                	mv	s8,a1
    80001b3c:	8a32                	mv	s4,a2
    80001b3e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001b40:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001b42:	6a85                	lui	s5,0x1
    80001b44:	a015                	j	80001b68 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001b46:	9562                	add	a0,a0,s8
    80001b48:	0004861b          	sext.w	a2,s1
    80001b4c:	85d2                	mv	a1,s4
    80001b4e:	41250533          	sub	a0,a0,s2
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	6d0080e7          	jalr	1744(ra) # 80001222 <memmove>

    len -= n;
    80001b5a:	409989b3          	sub	s3,s3,s1
    src += n;
    80001b5e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001b60:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001b64:	02098263          	beqz	s3,80001b88 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001b68:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001b6c:	85ca                	mv	a1,s2
    80001b6e:	855a                	mv	a0,s6
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	9ec080e7          	jalr	-1556(ra) # 8000155c <walkaddr>
    if(pa0 == 0)
    80001b78:	cd01                	beqz	a0,80001b90 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001b7a:	418904b3          	sub	s1,s2,s8
    80001b7e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001b80:	fc99f3e3          	bgeu	s3,s1,80001b46 <copyout+0x28>
    80001b84:	84ce                	mv	s1,s3
    80001b86:	b7c1                	j	80001b46 <copyout+0x28>
  }
  return 0;
    80001b88:	4501                	li	a0,0
    80001b8a:	a021                	j	80001b92 <copyout+0x74>
    80001b8c:	4501                	li	a0,0
}
    80001b8e:	8082                	ret
      return -1;
    80001b90:	557d                	li	a0,-1
}
    80001b92:	60a6                	ld	ra,72(sp)
    80001b94:	6406                	ld	s0,64(sp)
    80001b96:	74e2                	ld	s1,56(sp)
    80001b98:	7942                	ld	s2,48(sp)
    80001b9a:	79a2                	ld	s3,40(sp)
    80001b9c:	7a02                	ld	s4,32(sp)
    80001b9e:	6ae2                	ld	s5,24(sp)
    80001ba0:	6b42                	ld	s6,16(sp)
    80001ba2:	6ba2                	ld	s7,8(sp)
    80001ba4:	6c02                	ld	s8,0(sp)
    80001ba6:	6161                	addi	sp,sp,80
    80001ba8:	8082                	ret

0000000080001baa <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001baa:	c6bd                	beqz	a3,80001c18 <copyin+0x6e>
{
    80001bac:	715d                	addi	sp,sp,-80
    80001bae:	e486                	sd	ra,72(sp)
    80001bb0:	e0a2                	sd	s0,64(sp)
    80001bb2:	fc26                	sd	s1,56(sp)
    80001bb4:	f84a                	sd	s2,48(sp)
    80001bb6:	f44e                	sd	s3,40(sp)
    80001bb8:	f052                	sd	s4,32(sp)
    80001bba:	ec56                	sd	s5,24(sp)
    80001bbc:	e85a                	sd	s6,16(sp)
    80001bbe:	e45e                	sd	s7,8(sp)
    80001bc0:	e062                	sd	s8,0(sp)
    80001bc2:	0880                	addi	s0,sp,80
    80001bc4:	8b2a                	mv	s6,a0
    80001bc6:	8a2e                	mv	s4,a1
    80001bc8:	8c32                	mv	s8,a2
    80001bca:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001bcc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001bce:	6a85                	lui	s5,0x1
    80001bd0:	a015                	j	80001bf4 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001bd2:	9562                	add	a0,a0,s8
    80001bd4:	0004861b          	sext.w	a2,s1
    80001bd8:	412505b3          	sub	a1,a0,s2
    80001bdc:	8552                	mv	a0,s4
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	644080e7          	jalr	1604(ra) # 80001222 <memmove>

    len -= n;
    80001be6:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001bea:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001bec:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001bf0:	02098263          	beqz	s3,80001c14 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001bf4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001bf8:	85ca                	mv	a1,s2
    80001bfa:	855a                	mv	a0,s6
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	960080e7          	jalr	-1696(ra) # 8000155c <walkaddr>
    if(pa0 == 0)
    80001c04:	cd01                	beqz	a0,80001c1c <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001c06:	418904b3          	sub	s1,s2,s8
    80001c0a:	94d6                	add	s1,s1,s5
    if(n > len)
    80001c0c:	fc99f3e3          	bgeu	s3,s1,80001bd2 <copyin+0x28>
    80001c10:	84ce                	mv	s1,s3
    80001c12:	b7c1                	j	80001bd2 <copyin+0x28>
  }
  return 0;
    80001c14:	4501                	li	a0,0
    80001c16:	a021                	j	80001c1e <copyin+0x74>
    80001c18:	4501                	li	a0,0
}
    80001c1a:	8082                	ret
      return -1;
    80001c1c:	557d                	li	a0,-1
}
    80001c1e:	60a6                	ld	ra,72(sp)
    80001c20:	6406                	ld	s0,64(sp)
    80001c22:	74e2                	ld	s1,56(sp)
    80001c24:	7942                	ld	s2,48(sp)
    80001c26:	79a2                	ld	s3,40(sp)
    80001c28:	7a02                	ld	s4,32(sp)
    80001c2a:	6ae2                	ld	s5,24(sp)
    80001c2c:	6b42                	ld	s6,16(sp)
    80001c2e:	6ba2                	ld	s7,8(sp)
    80001c30:	6c02                	ld	s8,0(sp)
    80001c32:	6161                	addi	sp,sp,80
    80001c34:	8082                	ret

0000000080001c36 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001c36:	c6c5                	beqz	a3,80001cde <copyinstr+0xa8>
{
    80001c38:	715d                	addi	sp,sp,-80
    80001c3a:	e486                	sd	ra,72(sp)
    80001c3c:	e0a2                	sd	s0,64(sp)
    80001c3e:	fc26                	sd	s1,56(sp)
    80001c40:	f84a                	sd	s2,48(sp)
    80001c42:	f44e                	sd	s3,40(sp)
    80001c44:	f052                	sd	s4,32(sp)
    80001c46:	ec56                	sd	s5,24(sp)
    80001c48:	e85a                	sd	s6,16(sp)
    80001c4a:	e45e                	sd	s7,8(sp)
    80001c4c:	0880                	addi	s0,sp,80
    80001c4e:	8a2a                	mv	s4,a0
    80001c50:	8b2e                	mv	s6,a1
    80001c52:	8bb2                	mv	s7,a2
    80001c54:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001c56:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001c58:	6985                	lui	s3,0x1
    80001c5a:	a035                	j	80001c86 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001c5c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001c60:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001c62:	0017b793          	seqz	a5,a5
    80001c66:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001c6a:	60a6                	ld	ra,72(sp)
    80001c6c:	6406                	ld	s0,64(sp)
    80001c6e:	74e2                	ld	s1,56(sp)
    80001c70:	7942                	ld	s2,48(sp)
    80001c72:	79a2                	ld	s3,40(sp)
    80001c74:	7a02                	ld	s4,32(sp)
    80001c76:	6ae2                	ld	s5,24(sp)
    80001c78:	6b42                	ld	s6,16(sp)
    80001c7a:	6ba2                	ld	s7,8(sp)
    80001c7c:	6161                	addi	sp,sp,80
    80001c7e:	8082                	ret
    srcva = va0 + PGSIZE;
    80001c80:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001c84:	c8a9                	beqz	s1,80001cd6 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001c86:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001c8a:	85ca                	mv	a1,s2
    80001c8c:	8552                	mv	a0,s4
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	8ce080e7          	jalr	-1842(ra) # 8000155c <walkaddr>
    if(pa0 == 0)
    80001c96:	c131                	beqz	a0,80001cda <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001c98:	41790833          	sub	a6,s2,s7
    80001c9c:	984e                	add	a6,a6,s3
    if(n > max)
    80001c9e:	0104f363          	bgeu	s1,a6,80001ca4 <copyinstr+0x6e>
    80001ca2:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001ca4:	955e                	add	a0,a0,s7
    80001ca6:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001caa:	fc080be3          	beqz	a6,80001c80 <copyinstr+0x4a>
    80001cae:	985a                	add	a6,a6,s6
    80001cb0:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001cb2:	41650633          	sub	a2,a0,s6
    80001cb6:	14fd                	addi	s1,s1,-1
    80001cb8:	9b26                	add	s6,s6,s1
    80001cba:	00f60733          	add	a4,a2,a5
    80001cbe:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd6fd8>
    80001cc2:	df49                	beqz	a4,80001c5c <copyinstr+0x26>
        *dst = *p;
    80001cc4:	00e78023          	sb	a4,0(a5)
      --max;
    80001cc8:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001ccc:	0785                	addi	a5,a5,1
    while(n > 0){
    80001cce:	ff0796e3          	bne	a5,a6,80001cba <copyinstr+0x84>
      dst++;
    80001cd2:	8b42                	mv	s6,a6
    80001cd4:	b775                	j	80001c80 <copyinstr+0x4a>
    80001cd6:	4781                	li	a5,0
    80001cd8:	b769                	j	80001c62 <copyinstr+0x2c>
      return -1;
    80001cda:	557d                	li	a0,-1
    80001cdc:	b779                	j	80001c6a <copyinstr+0x34>
  int got_null = 0;
    80001cde:	4781                	li	a5,0
  if(got_null){
    80001ce0:	0017b793          	seqz	a5,a5
    80001ce4:	40f00533          	neg	a0,a5
}
    80001ce8:	8082                	ret

0000000080001cea <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001cea:	1101                	addi	sp,sp,-32
    80001cec:	ec06                	sd	ra,24(sp)
    80001cee:	e822                	sd	s0,16(sp)
    80001cf0:	e426                	sd	s1,8(sp)
    80001cf2:	1000                	addi	s0,sp,32
    80001cf4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	072080e7          	jalr	114(ra) # 80000d68 <holding>
    80001cfe:	c909                	beqz	a0,80001d10 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001d00:	789c                	ld	a5,48(s1)
    80001d02:	00978f63          	beq	a5,s1,80001d20 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001d06:	60e2                	ld	ra,24(sp)
    80001d08:	6442                	ld	s0,16(sp)
    80001d0a:	64a2                	ld	s1,8(sp)
    80001d0c:	6105                	addi	sp,sp,32
    80001d0e:	8082                	ret
    panic("wakeup1");
    80001d10:	00006517          	auipc	a0,0x6
    80001d14:	54850513          	addi	a0,a0,1352 # 80008258 <digits+0x218>
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	838080e7          	jalr	-1992(ra) # 80000550 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001d20:	5098                	lw	a4,32(s1)
    80001d22:	4785                	li	a5,1
    80001d24:	fef711e3          	bne	a4,a5,80001d06 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001d28:	4789                	li	a5,2
    80001d2a:	d09c                	sw	a5,32(s1)
}
    80001d2c:	bfe9                	j	80001d06 <wakeup1+0x1c>

0000000080001d2e <procinit>:
{
    80001d2e:	715d                	addi	sp,sp,-80
    80001d30:	e486                	sd	ra,72(sp)
    80001d32:	e0a2                	sd	s0,64(sp)
    80001d34:	fc26                	sd	s1,56(sp)
    80001d36:	f84a                	sd	s2,48(sp)
    80001d38:	f44e                	sd	s3,40(sp)
    80001d3a:	f052                	sd	s4,32(sp)
    80001d3c:	ec56                	sd	s5,24(sp)
    80001d3e:	e85a                	sd	s6,16(sp)
    80001d40:	e45e                	sd	s7,8(sp)
    80001d42:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001d44:	00006597          	auipc	a1,0x6
    80001d48:	51c58593          	addi	a1,a1,1308 # 80008260 <digits+0x220>
    80001d4c:	00010517          	auipc	a0,0x10
    80001d50:	63c50513          	addi	a0,a0,1596 # 80012388 <pid_lock>
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	20a080e7          	jalr	522(ra) # 80000f5e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	00011917          	auipc	s2,0x11
    80001d60:	a4c90913          	addi	s2,s2,-1460 # 800127a8 <proc>
      initlock(&p->lock, "proc");
    80001d64:	00006b97          	auipc	s7,0x6
    80001d68:	504b8b93          	addi	s7,s7,1284 # 80008268 <digits+0x228>
      uint64 va = KSTACK((int) (p - proc));
    80001d6c:	8b4a                	mv	s6,s2
    80001d6e:	00006a97          	auipc	s5,0x6
    80001d72:	292a8a93          	addi	s5,s5,658 # 80008000 <etext>
    80001d76:	040009b7          	lui	s3,0x4000
    80001d7a:	19fd                	addi	s3,s3,-1
    80001d7c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d7e:	00016a17          	auipc	s4,0x16
    80001d82:	62aa0a13          	addi	s4,s4,1578 # 800183a8 <tickslock>
      initlock(&p->lock, "proc");
    80001d86:	85de                	mv	a1,s7
    80001d88:	854a                	mv	a0,s2
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	1d4080e7          	jalr	468(ra) # 80000f5e <initlock>
      char *pa = kalloc();
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	ee6080e7          	jalr	-282(ra) # 80000c78 <kalloc>
    80001d9a:	85aa                	mv	a1,a0
      if(pa == 0)
    80001d9c:	c929                	beqz	a0,80001dee <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001d9e:	416904b3          	sub	s1,s2,s6
    80001da2:	8491                	srai	s1,s1,0x4
    80001da4:	000ab783          	ld	a5,0(s5)
    80001da8:	02f484b3          	mul	s1,s1,a5
    80001dac:	2485                	addiw	s1,s1,1
    80001dae:	00d4949b          	slliw	s1,s1,0xd
    80001db2:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001db6:	4699                	li	a3,6
    80001db8:	6605                	lui	a2,0x1
    80001dba:	8526                	mv	a0,s1
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	870080e7          	jalr	-1936(ra) # 8000162c <kvmmap>
      p->kstack = va;
    80001dc4:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dc8:	17090913          	addi	s2,s2,368
    80001dcc:	fb491de3          	bne	s2,s4,80001d86 <procinit+0x58>
  kvminithart();
    80001dd0:	fffff097          	auipc	ra,0xfffff
    80001dd4:	768080e7          	jalr	1896(ra) # 80001538 <kvminithart>
}
    80001dd8:	60a6                	ld	ra,72(sp)
    80001dda:	6406                	ld	s0,64(sp)
    80001ddc:	74e2                	ld	s1,56(sp)
    80001dde:	7942                	ld	s2,48(sp)
    80001de0:	79a2                	ld	s3,40(sp)
    80001de2:	7a02                	ld	s4,32(sp)
    80001de4:	6ae2                	ld	s5,24(sp)
    80001de6:	6b42                	ld	s6,16(sp)
    80001de8:	6ba2                	ld	s7,8(sp)
    80001dea:	6161                	addi	sp,sp,80
    80001dec:	8082                	ret
        panic("kalloc");
    80001dee:	00006517          	auipc	a0,0x6
    80001df2:	48250513          	addi	a0,a0,1154 # 80008270 <digits+0x230>
    80001df6:	ffffe097          	auipc	ra,0xffffe
    80001dfa:	75a080e7          	jalr	1882(ra) # 80000550 <panic>

0000000080001dfe <cpuid>:
{
    80001dfe:	1141                	addi	sp,sp,-16
    80001e00:	e422                	sd	s0,8(sp)
    80001e02:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e04:	8512                	mv	a0,tp
}
    80001e06:	2501                	sext.w	a0,a0
    80001e08:	6422                	ld	s0,8(sp)
    80001e0a:	0141                	addi	sp,sp,16
    80001e0c:	8082                	ret

0000000080001e0e <mycpu>:
mycpu(void) {
    80001e0e:	1141                	addi	sp,sp,-16
    80001e10:	e422                	sd	s0,8(sp)
    80001e12:	0800                	addi	s0,sp,16
    80001e14:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
}
    80001e1a:	00010517          	auipc	a0,0x10
    80001e1e:	58e50513          	addi	a0,a0,1422 # 800123a8 <cpus>
    80001e22:	953e                	add	a0,a0,a5
    80001e24:	6422                	ld	s0,8(sp)
    80001e26:	0141                	addi	sp,sp,16
    80001e28:	8082                	ret

0000000080001e2a <myproc>:
myproc(void) {
    80001e2a:	1101                	addi	sp,sp,-32
    80001e2c:	ec06                	sd	ra,24(sp)
    80001e2e:	e822                	sd	s0,16(sp)
    80001e30:	e426                	sd	s1,8(sp)
    80001e32:	1000                	addi	s0,sp,32
  push_off();
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	f62080e7          	jalr	-158(ra) # 80000d96 <push_off>
    80001e3c:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001e3e:	2781                	sext.w	a5,a5
    80001e40:	079e                	slli	a5,a5,0x7
    80001e42:	00010717          	auipc	a4,0x10
    80001e46:	54670713          	addi	a4,a4,1350 # 80012388 <pid_lock>
    80001e4a:	97ba                	add	a5,a5,a4
    80001e4c:	7384                	ld	s1,32(a5)
  pop_off();
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	004080e7          	jalr	4(ra) # 80000e52 <pop_off>
}
    80001e56:	8526                	mv	a0,s1
    80001e58:	60e2                	ld	ra,24(sp)
    80001e5a:	6442                	ld	s0,16(sp)
    80001e5c:	64a2                	ld	s1,8(sp)
    80001e5e:	6105                	addi	sp,sp,32
    80001e60:	8082                	ret

0000000080001e62 <forkret>:
{
    80001e62:	1141                	addi	sp,sp,-16
    80001e64:	e406                	sd	ra,8(sp)
    80001e66:	e022                	sd	s0,0(sp)
    80001e68:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001e6a:	00000097          	auipc	ra,0x0
    80001e6e:	fc0080e7          	jalr	-64(ra) # 80001e2a <myproc>
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	040080e7          	jalr	64(ra) # 80000eb2 <release>
  if (first) {
    80001e7a:	00007797          	auipc	a5,0x7
    80001e7e:	a367a783          	lw	a5,-1482(a5) # 800088b0 <first.1672>
    80001e82:	eb89                	bnez	a5,80001e94 <forkret+0x32>
  usertrapret();
    80001e84:	00001097          	auipc	ra,0x1
    80001e88:	c1a080e7          	jalr	-998(ra) # 80002a9e <usertrapret>
}
    80001e8c:	60a2                	ld	ra,8(sp)
    80001e8e:	6402                	ld	s0,0(sp)
    80001e90:	0141                	addi	sp,sp,16
    80001e92:	8082                	ret
    first = 0;
    80001e94:	00007797          	auipc	a5,0x7
    80001e98:	a007ae23          	sw	zero,-1508(a5) # 800088b0 <first.1672>
    fsinit(ROOTDEV);
    80001e9c:	4505                	li	a0,1
    80001e9e:	00002097          	auipc	ra,0x2
    80001ea2:	942080e7          	jalr	-1726(ra) # 800037e0 <fsinit>
    80001ea6:	bff9                	j	80001e84 <forkret+0x22>

0000000080001ea8 <allocpid>:
allocpid() {
    80001ea8:	1101                	addi	sp,sp,-32
    80001eaa:	ec06                	sd	ra,24(sp)
    80001eac:	e822                	sd	s0,16(sp)
    80001eae:	e426                	sd	s1,8(sp)
    80001eb0:	e04a                	sd	s2,0(sp)
    80001eb2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001eb4:	00010917          	auipc	s2,0x10
    80001eb8:	4d490913          	addi	s2,s2,1236 # 80012388 <pid_lock>
    80001ebc:	854a                	mv	a0,s2
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	f24080e7          	jalr	-220(ra) # 80000de2 <acquire>
  pid = nextpid;
    80001ec6:	00007797          	auipc	a5,0x7
    80001eca:	9ee78793          	addi	a5,a5,-1554 # 800088b4 <nextpid>
    80001ece:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ed0:	0014871b          	addiw	a4,s1,1
    80001ed4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ed6:	854a                	mv	a0,s2
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	fda080e7          	jalr	-38(ra) # 80000eb2 <release>
}
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	60e2                	ld	ra,24(sp)
    80001ee4:	6442                	ld	s0,16(sp)
    80001ee6:	64a2                	ld	s1,8(sp)
    80001ee8:	6902                	ld	s2,0(sp)
    80001eea:	6105                	addi	sp,sp,32
    80001eec:	8082                	ret

0000000080001eee <proc_pagetable>:
{
    80001eee:	1101                	addi	sp,sp,-32
    80001ef0:	ec06                	sd	ra,24(sp)
    80001ef2:	e822                	sd	s0,16(sp)
    80001ef4:	e426                	sd	s1,8(sp)
    80001ef6:	e04a                	sd	s2,0(sp)
    80001ef8:	1000                	addi	s0,sp,32
    80001efa:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	8ea080e7          	jalr	-1814(ra) # 800017e6 <uvmcreate>
    80001f04:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001f06:	c121                	beqz	a0,80001f46 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f08:	4729                	li	a4,10
    80001f0a:	00005697          	auipc	a3,0x5
    80001f0e:	0f668693          	addi	a3,a3,246 # 80007000 <_trampoline>
    80001f12:	6605                	lui	a2,0x1
    80001f14:	040005b7          	lui	a1,0x4000
    80001f18:	15fd                	addi	a1,a1,-1
    80001f1a:	05b2                	slli	a1,a1,0xc
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	682080e7          	jalr	1666(ra) # 8000159e <mappages>
    80001f24:	02054863          	bltz	a0,80001f54 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f28:	4719                	li	a4,6
    80001f2a:	06093683          	ld	a3,96(s2)
    80001f2e:	6605                	lui	a2,0x1
    80001f30:	020005b7          	lui	a1,0x2000
    80001f34:	15fd                	addi	a1,a1,-1
    80001f36:	05b6                	slli	a1,a1,0xd
    80001f38:	8526                	mv	a0,s1
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	664080e7          	jalr	1636(ra) # 8000159e <mappages>
    80001f42:	02054163          	bltz	a0,80001f64 <proc_pagetable+0x76>
}
    80001f46:	8526                	mv	a0,s1
    80001f48:	60e2                	ld	ra,24(sp)
    80001f4a:	6442                	ld	s0,16(sp)
    80001f4c:	64a2                	ld	s1,8(sp)
    80001f4e:	6902                	ld	s2,0(sp)
    80001f50:	6105                	addi	sp,sp,32
    80001f52:	8082                	ret
    uvmfree(pagetable, 0);
    80001f54:	4581                	li	a1,0
    80001f56:	8526                	mv	a0,s1
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	a8a080e7          	jalr	-1398(ra) # 800019e2 <uvmfree>
    return 0;
    80001f60:	4481                	li	s1,0
    80001f62:	b7d5                	j	80001f46 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f64:	4681                	li	a3,0
    80001f66:	4605                	li	a2,1
    80001f68:	040005b7          	lui	a1,0x4000
    80001f6c:	15fd                	addi	a1,a1,-1
    80001f6e:	05b2                	slli	a1,a1,0xc
    80001f70:	8526                	mv	a0,s1
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	7b0080e7          	jalr	1968(ra) # 80001722 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f7a:	4581                	li	a1,0
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	00000097          	auipc	ra,0x0
    80001f82:	a64080e7          	jalr	-1436(ra) # 800019e2 <uvmfree>
    return 0;
    80001f86:	4481                	li	s1,0
    80001f88:	bf7d                	j	80001f46 <proc_pagetable+0x58>

0000000080001f8a <proc_freepagetable>:
{
    80001f8a:	1101                	addi	sp,sp,-32
    80001f8c:	ec06                	sd	ra,24(sp)
    80001f8e:	e822                	sd	s0,16(sp)
    80001f90:	e426                	sd	s1,8(sp)
    80001f92:	e04a                	sd	s2,0(sp)
    80001f94:	1000                	addi	s0,sp,32
    80001f96:	84aa                	mv	s1,a0
    80001f98:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f9a:	4681                	li	a3,0
    80001f9c:	4605                	li	a2,1
    80001f9e:	040005b7          	lui	a1,0x4000
    80001fa2:	15fd                	addi	a1,a1,-1
    80001fa4:	05b2                	slli	a1,a1,0xc
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	77c080e7          	jalr	1916(ra) # 80001722 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001fae:	4681                	li	a3,0
    80001fb0:	4605                	li	a2,1
    80001fb2:	020005b7          	lui	a1,0x2000
    80001fb6:	15fd                	addi	a1,a1,-1
    80001fb8:	05b6                	slli	a1,a1,0xd
    80001fba:	8526                	mv	a0,s1
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	766080e7          	jalr	1894(ra) # 80001722 <uvmunmap>
  uvmfree(pagetable, sz);
    80001fc4:	85ca                	mv	a1,s2
    80001fc6:	8526                	mv	a0,s1
    80001fc8:	00000097          	auipc	ra,0x0
    80001fcc:	a1a080e7          	jalr	-1510(ra) # 800019e2 <uvmfree>
}
    80001fd0:	60e2                	ld	ra,24(sp)
    80001fd2:	6442                	ld	s0,16(sp)
    80001fd4:	64a2                	ld	s1,8(sp)
    80001fd6:	6902                	ld	s2,0(sp)
    80001fd8:	6105                	addi	sp,sp,32
    80001fda:	8082                	ret

0000000080001fdc <freeproc>:
{
    80001fdc:	1101                	addi	sp,sp,-32
    80001fde:	ec06                	sd	ra,24(sp)
    80001fe0:	e822                	sd	s0,16(sp)
    80001fe2:	e426                	sd	s1,8(sp)
    80001fe4:	1000                	addi	s0,sp,32
    80001fe6:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001fe8:	7128                	ld	a0,96(a0)
    80001fea:	c509                	beqz	a0,80001ff4 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001fec:	fffff097          	auipc	ra,0xfffff
    80001ff0:	b9c080e7          	jalr	-1124(ra) # 80000b88 <kfree>
  p->trapframe = 0;
    80001ff4:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001ff8:	6ca8                	ld	a0,88(s1)
    80001ffa:	c511                	beqz	a0,80002006 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ffc:	68ac                	ld	a1,80(s1)
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	f8c080e7          	jalr	-116(ra) # 80001f8a <proc_freepagetable>
  p->pagetable = 0;
    80002006:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    8000200a:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    8000200e:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80002012:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80002016:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    8000201a:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    8000201e:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80002022:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80002026:	0204a023          	sw	zero,32(s1)
}
    8000202a:	60e2                	ld	ra,24(sp)
    8000202c:	6442                	ld	s0,16(sp)
    8000202e:	64a2                	ld	s1,8(sp)
    80002030:	6105                	addi	sp,sp,32
    80002032:	8082                	ret

0000000080002034 <allocproc>:
{
    80002034:	1101                	addi	sp,sp,-32
    80002036:	ec06                	sd	ra,24(sp)
    80002038:	e822                	sd	s0,16(sp)
    8000203a:	e426                	sd	s1,8(sp)
    8000203c:	e04a                	sd	s2,0(sp)
    8000203e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80002040:	00010497          	auipc	s1,0x10
    80002044:	76848493          	addi	s1,s1,1896 # 800127a8 <proc>
    80002048:	00016917          	auipc	s2,0x16
    8000204c:	36090913          	addi	s2,s2,864 # 800183a8 <tickslock>
    acquire(&p->lock);
    80002050:	8526                	mv	a0,s1
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	d90080e7          	jalr	-624(ra) # 80000de2 <acquire>
    if(p->state == UNUSED) {
    8000205a:	509c                	lw	a5,32(s1)
    8000205c:	cf81                	beqz	a5,80002074 <allocproc+0x40>
      release(&p->lock);
    8000205e:	8526                	mv	a0,s1
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	e52080e7          	jalr	-430(ra) # 80000eb2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002068:	17048493          	addi	s1,s1,368
    8000206c:	ff2492e3          	bne	s1,s2,80002050 <allocproc+0x1c>
  return 0;
    80002070:	4481                	li	s1,0
    80002072:	a0b9                	j	800020c0 <allocproc+0x8c>
  p->pid = allocpid();
    80002074:	00000097          	auipc	ra,0x0
    80002078:	e34080e7          	jalr	-460(ra) # 80001ea8 <allocpid>
    8000207c:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	bfa080e7          	jalr	-1030(ra) # 80000c78 <kalloc>
    80002086:	892a                	mv	s2,a0
    80002088:	f0a8                	sd	a0,96(s1)
    8000208a:	c131                	beqz	a0,800020ce <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    8000208c:	8526                	mv	a0,s1
    8000208e:	00000097          	auipc	ra,0x0
    80002092:	e60080e7          	jalr	-416(ra) # 80001eee <proc_pagetable>
    80002096:	892a                	mv	s2,a0
    80002098:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    8000209a:	c129                	beqz	a0,800020dc <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    8000209c:	07000613          	li	a2,112
    800020a0:	4581                	li	a1,0
    800020a2:	06848513          	addi	a0,s1,104
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	11c080e7          	jalr	284(ra) # 800011c2 <memset>
  p->context.ra = (uint64)forkret;
    800020ae:	00000797          	auipc	a5,0x0
    800020b2:	db478793          	addi	a5,a5,-588 # 80001e62 <forkret>
    800020b6:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    800020b8:	64bc                	ld	a5,72(s1)
    800020ba:	6705                	lui	a4,0x1
    800020bc:	97ba                	add	a5,a5,a4
    800020be:	f8bc                	sd	a5,112(s1)
}
    800020c0:	8526                	mv	a0,s1
    800020c2:	60e2                	ld	ra,24(sp)
    800020c4:	6442                	ld	s0,16(sp)
    800020c6:	64a2                	ld	s1,8(sp)
    800020c8:	6902                	ld	s2,0(sp)
    800020ca:	6105                	addi	sp,sp,32
    800020cc:	8082                	ret
    release(&p->lock);
    800020ce:	8526                	mv	a0,s1
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	de2080e7          	jalr	-542(ra) # 80000eb2 <release>
    return 0;
    800020d8:	84ca                	mv	s1,s2
    800020da:	b7dd                	j	800020c0 <allocproc+0x8c>
    freeproc(p);
    800020dc:	8526                	mv	a0,s1
    800020de:	00000097          	auipc	ra,0x0
    800020e2:	efe080e7          	jalr	-258(ra) # 80001fdc <freeproc>
    release(&p->lock);
    800020e6:	8526                	mv	a0,s1
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	dca080e7          	jalr	-566(ra) # 80000eb2 <release>
    return 0;
    800020f0:	84ca                	mv	s1,s2
    800020f2:	b7f9                	j	800020c0 <allocproc+0x8c>

00000000800020f4 <userinit>:
{
    800020f4:	1101                	addi	sp,sp,-32
    800020f6:	ec06                	sd	ra,24(sp)
    800020f8:	e822                	sd	s0,16(sp)
    800020fa:	e426                	sd	s1,8(sp)
    800020fc:	1000                	addi	s0,sp,32
  p = allocproc();
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	f36080e7          	jalr	-202(ra) # 80002034 <allocproc>
    80002106:	84aa                	mv	s1,a0
  initproc = p;
    80002108:	00007797          	auipc	a5,0x7
    8000210c:	f0a7b823          	sd	a0,-240(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80002110:	03400613          	li	a2,52
    80002114:	00006597          	auipc	a1,0x6
    80002118:	7ac58593          	addi	a1,a1,1964 # 800088c0 <initcode>
    8000211c:	6d28                	ld	a0,88(a0)
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	6f6080e7          	jalr	1782(ra) # 80001814 <uvminit>
  p->sz = PGSIZE;
    80002126:	6785                	lui	a5,0x1
    80002128:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    8000212a:	70b8                	ld	a4,96(s1)
    8000212c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80002130:	70b8                	ld	a4,96(s1)
    80002132:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002134:	4641                	li	a2,16
    80002136:	00006597          	auipc	a1,0x6
    8000213a:	14258593          	addi	a1,a1,322 # 80008278 <digits+0x238>
    8000213e:	16048513          	addi	a0,s1,352
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	1d6080e7          	jalr	470(ra) # 80001318 <safestrcpy>
  p->cwd = namei("/");
    8000214a:	00006517          	auipc	a0,0x6
    8000214e:	13e50513          	addi	a0,a0,318 # 80008288 <digits+0x248>
    80002152:	00002097          	auipc	ra,0x2
    80002156:	0ba080e7          	jalr	186(ra) # 8000420c <namei>
    8000215a:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    8000215e:	4789                	li	a5,2
    80002160:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80002162:	8526                	mv	a0,s1
    80002164:	fffff097          	auipc	ra,0xfffff
    80002168:	d4e080e7          	jalr	-690(ra) # 80000eb2 <release>
}
    8000216c:	60e2                	ld	ra,24(sp)
    8000216e:	6442                	ld	s0,16(sp)
    80002170:	64a2                	ld	s1,8(sp)
    80002172:	6105                	addi	sp,sp,32
    80002174:	8082                	ret

0000000080002176 <growproc>:
{
    80002176:	1101                	addi	sp,sp,-32
    80002178:	ec06                	sd	ra,24(sp)
    8000217a:	e822                	sd	s0,16(sp)
    8000217c:	e426                	sd	s1,8(sp)
    8000217e:	e04a                	sd	s2,0(sp)
    80002180:	1000                	addi	s0,sp,32
    80002182:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002184:	00000097          	auipc	ra,0x0
    80002188:	ca6080e7          	jalr	-858(ra) # 80001e2a <myproc>
    8000218c:	892a                	mv	s2,a0
  sz = p->sz;
    8000218e:	692c                	ld	a1,80(a0)
    80002190:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80002194:	00904f63          	bgtz	s1,800021b2 <growproc+0x3c>
  } else if(n < 0){
    80002198:	0204cc63          	bltz	s1,800021d0 <growproc+0x5a>
  p->sz = sz;
    8000219c:	1602                	slli	a2,a2,0x20
    8000219e:	9201                	srli	a2,a2,0x20
    800021a0:	04c93823          	sd	a2,80(s2)
  return 0;
    800021a4:	4501                	li	a0,0
}
    800021a6:	60e2                	ld	ra,24(sp)
    800021a8:	6442                	ld	s0,16(sp)
    800021aa:	64a2                	ld	s1,8(sp)
    800021ac:	6902                	ld	s2,0(sp)
    800021ae:	6105                	addi	sp,sp,32
    800021b0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800021b2:	9e25                	addw	a2,a2,s1
    800021b4:	1602                	slli	a2,a2,0x20
    800021b6:	9201                	srli	a2,a2,0x20
    800021b8:	1582                	slli	a1,a1,0x20
    800021ba:	9181                	srli	a1,a1,0x20
    800021bc:	6d28                	ld	a0,88(a0)
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	710080e7          	jalr	1808(ra) # 800018ce <uvmalloc>
    800021c6:	0005061b          	sext.w	a2,a0
    800021ca:	fa69                	bnez	a2,8000219c <growproc+0x26>
      return -1;
    800021cc:	557d                	li	a0,-1
    800021ce:	bfe1                	j	800021a6 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800021d0:	9e25                	addw	a2,a2,s1
    800021d2:	1602                	slli	a2,a2,0x20
    800021d4:	9201                	srli	a2,a2,0x20
    800021d6:	1582                	slli	a1,a1,0x20
    800021d8:	9181                	srli	a1,a1,0x20
    800021da:	6d28                	ld	a0,88(a0)
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	6aa080e7          	jalr	1706(ra) # 80001886 <uvmdealloc>
    800021e4:	0005061b          	sext.w	a2,a0
    800021e8:	bf55                	j	8000219c <growproc+0x26>

00000000800021ea <fork>:
{
    800021ea:	7179                	addi	sp,sp,-48
    800021ec:	f406                	sd	ra,40(sp)
    800021ee:	f022                	sd	s0,32(sp)
    800021f0:	ec26                	sd	s1,24(sp)
    800021f2:	e84a                	sd	s2,16(sp)
    800021f4:	e44e                	sd	s3,8(sp)
    800021f6:	e052                	sd	s4,0(sp)
    800021f8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	c30080e7          	jalr	-976(ra) # 80001e2a <myproc>
    80002202:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80002204:	00000097          	auipc	ra,0x0
    80002208:	e30080e7          	jalr	-464(ra) # 80002034 <allocproc>
    8000220c:	c175                	beqz	a0,800022f0 <fork+0x106>
    8000220e:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002210:	05093603          	ld	a2,80(s2)
    80002214:	6d2c                	ld	a1,88(a0)
    80002216:	05893503          	ld	a0,88(s2)
    8000221a:	00000097          	auipc	ra,0x0
    8000221e:	800080e7          	jalr	-2048(ra) # 80001a1a <uvmcopy>
    80002222:	04054863          	bltz	a0,80002272 <fork+0x88>
  np->sz = p->sz;
    80002226:	05093783          	ld	a5,80(s2)
    8000222a:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->parent = p;
    8000222e:	0329b423          	sd	s2,40(s3)
  *(np->trapframe) = *(p->trapframe);
    80002232:	06093683          	ld	a3,96(s2)
    80002236:	87b6                	mv	a5,a3
    80002238:	0609b703          	ld	a4,96(s3)
    8000223c:	12068693          	addi	a3,a3,288
    80002240:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002244:	6788                	ld	a0,8(a5)
    80002246:	6b8c                	ld	a1,16(a5)
    80002248:	6f90                	ld	a2,24(a5)
    8000224a:	01073023          	sd	a6,0(a4)
    8000224e:	e708                	sd	a0,8(a4)
    80002250:	eb0c                	sd	a1,16(a4)
    80002252:	ef10                	sd	a2,24(a4)
    80002254:	02078793          	addi	a5,a5,32
    80002258:	02070713          	addi	a4,a4,32
    8000225c:	fed792e3          	bne	a5,a3,80002240 <fork+0x56>
  np->trapframe->a0 = 0;
    80002260:	0609b783          	ld	a5,96(s3)
    80002264:	0607b823          	sd	zero,112(a5)
    80002268:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    8000226c:	15800a13          	li	s4,344
    80002270:	a03d                	j	8000229e <fork+0xb4>
    freeproc(np);
    80002272:	854e                	mv	a0,s3
    80002274:	00000097          	auipc	ra,0x0
    80002278:	d68080e7          	jalr	-664(ra) # 80001fdc <freeproc>
    release(&np->lock);
    8000227c:	854e                	mv	a0,s3
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	c34080e7          	jalr	-972(ra) # 80000eb2 <release>
    return -1;
    80002286:	54fd                	li	s1,-1
    80002288:	a899                	j	800022de <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    8000228a:	00002097          	auipc	ra,0x2
    8000228e:	620080e7          	jalr	1568(ra) # 800048aa <filedup>
    80002292:	009987b3          	add	a5,s3,s1
    80002296:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002298:	04a1                	addi	s1,s1,8
    8000229a:	01448763          	beq	s1,s4,800022a8 <fork+0xbe>
    if(p->ofile[i])
    8000229e:	009907b3          	add	a5,s2,s1
    800022a2:	6388                	ld	a0,0(a5)
    800022a4:	f17d                	bnez	a0,8000228a <fork+0xa0>
    800022a6:	bfcd                	j	80002298 <fork+0xae>
  np->cwd = idup(p->cwd);
    800022a8:	15893503          	ld	a0,344(s2)
    800022ac:	00001097          	auipc	ra,0x1
    800022b0:	76e080e7          	jalr	1902(ra) # 80003a1a <idup>
    800022b4:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800022b8:	4641                	li	a2,16
    800022ba:	16090593          	addi	a1,s2,352
    800022be:	16098513          	addi	a0,s3,352
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	056080e7          	jalr	86(ra) # 80001318 <safestrcpy>
  pid = np->pid;
    800022ca:	0409a483          	lw	s1,64(s3)
  np->state = RUNNABLE;
    800022ce:	4789                	li	a5,2
    800022d0:	02f9a023          	sw	a5,32(s3)
  release(&np->lock);
    800022d4:	854e                	mv	a0,s3
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	bdc080e7          	jalr	-1060(ra) # 80000eb2 <release>
}
    800022de:	8526                	mv	a0,s1
    800022e0:	70a2                	ld	ra,40(sp)
    800022e2:	7402                	ld	s0,32(sp)
    800022e4:	64e2                	ld	s1,24(sp)
    800022e6:	6942                	ld	s2,16(sp)
    800022e8:	69a2                	ld	s3,8(sp)
    800022ea:	6a02                	ld	s4,0(sp)
    800022ec:	6145                	addi	sp,sp,48
    800022ee:	8082                	ret
    return -1;
    800022f0:	54fd                	li	s1,-1
    800022f2:	b7f5                	j	800022de <fork+0xf4>

00000000800022f4 <reparent>:
{
    800022f4:	7179                	addi	sp,sp,-48
    800022f6:	f406                	sd	ra,40(sp)
    800022f8:	f022                	sd	s0,32(sp)
    800022fa:	ec26                	sd	s1,24(sp)
    800022fc:	e84a                	sd	s2,16(sp)
    800022fe:	e44e                	sd	s3,8(sp)
    80002300:	e052                	sd	s4,0(sp)
    80002302:	1800                	addi	s0,sp,48
    80002304:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002306:	00010497          	auipc	s1,0x10
    8000230a:	4a248493          	addi	s1,s1,1186 # 800127a8 <proc>
      pp->parent = initproc;
    8000230e:	00007a17          	auipc	s4,0x7
    80002312:	d0aa0a13          	addi	s4,s4,-758 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002316:	00016997          	auipc	s3,0x16
    8000231a:	09298993          	addi	s3,s3,146 # 800183a8 <tickslock>
    8000231e:	a029                	j	80002328 <reparent+0x34>
    80002320:	17048493          	addi	s1,s1,368
    80002324:	03348363          	beq	s1,s3,8000234a <reparent+0x56>
    if(pp->parent == p){
    80002328:	749c                	ld	a5,40(s1)
    8000232a:	ff279be3          	bne	a5,s2,80002320 <reparent+0x2c>
      acquire(&pp->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	ab2080e7          	jalr	-1358(ra) # 80000de2 <acquire>
      pp->parent = initproc;
    80002338:	000a3783          	ld	a5,0(s4)
    8000233c:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    8000233e:	8526                	mv	a0,s1
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	b72080e7          	jalr	-1166(ra) # 80000eb2 <release>
    80002348:	bfe1                	j	80002320 <reparent+0x2c>
}
    8000234a:	70a2                	ld	ra,40(sp)
    8000234c:	7402                	ld	s0,32(sp)
    8000234e:	64e2                	ld	s1,24(sp)
    80002350:	6942                	ld	s2,16(sp)
    80002352:	69a2                	ld	s3,8(sp)
    80002354:	6a02                	ld	s4,0(sp)
    80002356:	6145                	addi	sp,sp,48
    80002358:	8082                	ret

000000008000235a <scheduler>:
{
    8000235a:	711d                	addi	sp,sp,-96
    8000235c:	ec86                	sd	ra,88(sp)
    8000235e:	e8a2                	sd	s0,80(sp)
    80002360:	e4a6                	sd	s1,72(sp)
    80002362:	e0ca                	sd	s2,64(sp)
    80002364:	fc4e                	sd	s3,56(sp)
    80002366:	f852                	sd	s4,48(sp)
    80002368:	f456                	sd	s5,40(sp)
    8000236a:	f05a                	sd	s6,32(sp)
    8000236c:	ec5e                	sd	s7,24(sp)
    8000236e:	e862                	sd	s8,16(sp)
    80002370:	e466                	sd	s9,8(sp)
    80002372:	1080                	addi	s0,sp,96
    80002374:	8792                	mv	a5,tp
  int id = r_tp();
    80002376:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002378:	00779c13          	slli	s8,a5,0x7
    8000237c:	00010717          	auipc	a4,0x10
    80002380:	00c70713          	addi	a4,a4,12 # 80012388 <pid_lock>
    80002384:	9762                	add	a4,a4,s8
    80002386:	02073023          	sd	zero,32(a4)
        swtch(&c->context, &p->context);
    8000238a:	00010717          	auipc	a4,0x10
    8000238e:	02670713          	addi	a4,a4,38 # 800123b0 <cpus+0x8>
    80002392:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80002394:	4a89                	li	s5,2
        c->proc = p;
    80002396:	079e                	slli	a5,a5,0x7
    80002398:	00010b17          	auipc	s6,0x10
    8000239c:	ff0b0b13          	addi	s6,s6,-16 # 80012388 <pid_lock>
    800023a0:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800023a2:	00016a17          	auipc	s4,0x16
    800023a6:	006a0a13          	addi	s4,s4,6 # 800183a8 <tickslock>
    int nproc = 0;
    800023aa:	4c81                	li	s9,0
    800023ac:	a8a1                	j	80002404 <scheduler+0xaa>
        p->state = RUNNING;
    800023ae:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    800023b2:	029b3023          	sd	s1,32(s6)
        swtch(&c->context, &p->context);
    800023b6:	06848593          	addi	a1,s1,104
    800023ba:	8562                	mv	a0,s8
    800023bc:	00000097          	auipc	ra,0x0
    800023c0:	638080e7          	jalr	1592(ra) # 800029f4 <swtch>
        c->proc = 0;
    800023c4:	020b3023          	sd	zero,32(s6)
      release(&p->lock);
    800023c8:	8526                	mv	a0,s1
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	ae8080e7          	jalr	-1304(ra) # 80000eb2 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800023d2:	17048493          	addi	s1,s1,368
    800023d6:	01448d63          	beq	s1,s4,800023f0 <scheduler+0x96>
      acquire(&p->lock);
    800023da:	8526                	mv	a0,s1
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	a06080e7          	jalr	-1530(ra) # 80000de2 <acquire>
      if(p->state != UNUSED) {
    800023e4:	509c                	lw	a5,32(s1)
    800023e6:	d3ed                	beqz	a5,800023c8 <scheduler+0x6e>
        nproc++;
    800023e8:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    800023ea:	fd579fe3          	bne	a5,s5,800023c8 <scheduler+0x6e>
    800023ee:	b7c1                	j	800023ae <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    800023f0:	013aca63          	blt	s5,s3,80002404 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023f4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023f8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023fc:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002400:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002404:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002408:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000240c:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    80002410:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    80002412:	00010497          	auipc	s1,0x10
    80002416:	39648493          	addi	s1,s1,918 # 800127a8 <proc>
        p->state = RUNNING;
    8000241a:	4b8d                	li	s7,3
    8000241c:	bf7d                	j	800023da <scheduler+0x80>

000000008000241e <sched>:
{
    8000241e:	7179                	addi	sp,sp,-48
    80002420:	f406                	sd	ra,40(sp)
    80002422:	f022                	sd	s0,32(sp)
    80002424:	ec26                	sd	s1,24(sp)
    80002426:	e84a                	sd	s2,16(sp)
    80002428:	e44e                	sd	s3,8(sp)
    8000242a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000242c:	00000097          	auipc	ra,0x0
    80002430:	9fe080e7          	jalr	-1538(ra) # 80001e2a <myproc>
    80002434:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	932080e7          	jalr	-1742(ra) # 80000d68 <holding>
    8000243e:	c93d                	beqz	a0,800024b4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002440:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002442:	2781                	sext.w	a5,a5
    80002444:	079e                	slli	a5,a5,0x7
    80002446:	00010717          	auipc	a4,0x10
    8000244a:	f4270713          	addi	a4,a4,-190 # 80012388 <pid_lock>
    8000244e:	97ba                	add	a5,a5,a4
    80002450:	0987a703          	lw	a4,152(a5)
    80002454:	4785                	li	a5,1
    80002456:	06f71763          	bne	a4,a5,800024c4 <sched+0xa6>
  if(p->state == RUNNING)
    8000245a:	5098                	lw	a4,32(s1)
    8000245c:	478d                	li	a5,3
    8000245e:	06f70b63          	beq	a4,a5,800024d4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002462:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002466:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002468:	efb5                	bnez	a5,800024e4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000246a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000246c:	00010917          	auipc	s2,0x10
    80002470:	f1c90913          	addi	s2,s2,-228 # 80012388 <pid_lock>
    80002474:	2781                	sext.w	a5,a5
    80002476:	079e                	slli	a5,a5,0x7
    80002478:	97ca                	add	a5,a5,s2
    8000247a:	09c7a983          	lw	s3,156(a5)
    8000247e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002480:	2781                	sext.w	a5,a5
    80002482:	079e                	slli	a5,a5,0x7
    80002484:	00010597          	auipc	a1,0x10
    80002488:	f2c58593          	addi	a1,a1,-212 # 800123b0 <cpus+0x8>
    8000248c:	95be                	add	a1,a1,a5
    8000248e:	06848513          	addi	a0,s1,104
    80002492:	00000097          	auipc	ra,0x0
    80002496:	562080e7          	jalr	1378(ra) # 800029f4 <swtch>
    8000249a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000249c:	2781                	sext.w	a5,a5
    8000249e:	079e                	slli	a5,a5,0x7
    800024a0:	97ca                	add	a5,a5,s2
    800024a2:	0937ae23          	sw	s3,156(a5)
}
    800024a6:	70a2                	ld	ra,40(sp)
    800024a8:	7402                	ld	s0,32(sp)
    800024aa:	64e2                	ld	s1,24(sp)
    800024ac:	6942                	ld	s2,16(sp)
    800024ae:	69a2                	ld	s3,8(sp)
    800024b0:	6145                	addi	sp,sp,48
    800024b2:	8082                	ret
    panic("sched p->lock");
    800024b4:	00006517          	auipc	a0,0x6
    800024b8:	ddc50513          	addi	a0,a0,-548 # 80008290 <digits+0x250>
    800024bc:	ffffe097          	auipc	ra,0xffffe
    800024c0:	094080e7          	jalr	148(ra) # 80000550 <panic>
    panic("sched locks");
    800024c4:	00006517          	auipc	a0,0x6
    800024c8:	ddc50513          	addi	a0,a0,-548 # 800082a0 <digits+0x260>
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	084080e7          	jalr	132(ra) # 80000550 <panic>
    panic("sched running");
    800024d4:	00006517          	auipc	a0,0x6
    800024d8:	ddc50513          	addi	a0,a0,-548 # 800082b0 <digits+0x270>
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	074080e7          	jalr	116(ra) # 80000550 <panic>
    panic("sched interruptible");
    800024e4:	00006517          	auipc	a0,0x6
    800024e8:	ddc50513          	addi	a0,a0,-548 # 800082c0 <digits+0x280>
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	064080e7          	jalr	100(ra) # 80000550 <panic>

00000000800024f4 <exit>:
{
    800024f4:	7179                	addi	sp,sp,-48
    800024f6:	f406                	sd	ra,40(sp)
    800024f8:	f022                	sd	s0,32(sp)
    800024fa:	ec26                	sd	s1,24(sp)
    800024fc:	e84a                	sd	s2,16(sp)
    800024fe:	e44e                	sd	s3,8(sp)
    80002500:	e052                	sd	s4,0(sp)
    80002502:	1800                	addi	s0,sp,48
    80002504:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002506:	00000097          	auipc	ra,0x0
    8000250a:	924080e7          	jalr	-1756(ra) # 80001e2a <myproc>
    8000250e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002510:	00007797          	auipc	a5,0x7
    80002514:	b087b783          	ld	a5,-1272(a5) # 80009018 <initproc>
    80002518:	0d850493          	addi	s1,a0,216
    8000251c:	15850913          	addi	s2,a0,344
    80002520:	02a79363          	bne	a5,a0,80002546 <exit+0x52>
    panic("init exiting");
    80002524:	00006517          	auipc	a0,0x6
    80002528:	db450513          	addi	a0,a0,-588 # 800082d8 <digits+0x298>
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	024080e7          	jalr	36(ra) # 80000550 <panic>
      fileclose(f);
    80002534:	00002097          	auipc	ra,0x2
    80002538:	3c8080e7          	jalr	968(ra) # 800048fc <fileclose>
      p->ofile[fd] = 0;
    8000253c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002540:	04a1                	addi	s1,s1,8
    80002542:	01248563          	beq	s1,s2,8000254c <exit+0x58>
    if(p->ofile[fd]){
    80002546:	6088                	ld	a0,0(s1)
    80002548:	f575                	bnez	a0,80002534 <exit+0x40>
    8000254a:	bfdd                	j	80002540 <exit+0x4c>
  begin_op();
    8000254c:	00002097          	auipc	ra,0x2
    80002550:	edc080e7          	jalr	-292(ra) # 80004428 <begin_op>
  iput(p->cwd);
    80002554:	1589b503          	ld	a0,344(s3)
    80002558:	00001097          	auipc	ra,0x1
    8000255c:	6ba080e7          	jalr	1722(ra) # 80003c12 <iput>
  end_op();
    80002560:	00002097          	auipc	ra,0x2
    80002564:	f48080e7          	jalr	-184(ra) # 800044a8 <end_op>
  p->cwd = 0;
    80002568:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    8000256c:	00007497          	auipc	s1,0x7
    80002570:	aac48493          	addi	s1,s1,-1364 # 80009018 <initproc>
    80002574:	6088                	ld	a0,0(s1)
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	86c080e7          	jalr	-1940(ra) # 80000de2 <acquire>
  wakeup1(initproc);
    8000257e:	6088                	ld	a0,0(s1)
    80002580:	fffff097          	auipc	ra,0xfffff
    80002584:	76a080e7          	jalr	1898(ra) # 80001cea <wakeup1>
  release(&initproc->lock);
    80002588:	6088                	ld	a0,0(s1)
    8000258a:	fffff097          	auipc	ra,0xfffff
    8000258e:	928080e7          	jalr	-1752(ra) # 80000eb2 <release>
  acquire(&p->lock);
    80002592:	854e                	mv	a0,s3
    80002594:	fffff097          	auipc	ra,0xfffff
    80002598:	84e080e7          	jalr	-1970(ra) # 80000de2 <acquire>
  struct proc *original_parent = p->parent;
    8000259c:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800025a0:	854e                	mv	a0,s3
    800025a2:	fffff097          	auipc	ra,0xfffff
    800025a6:	910080e7          	jalr	-1776(ra) # 80000eb2 <release>
  acquire(&original_parent->lock);
    800025aa:	8526                	mv	a0,s1
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	836080e7          	jalr	-1994(ra) # 80000de2 <acquire>
  acquire(&p->lock);
    800025b4:	854e                	mv	a0,s3
    800025b6:	fffff097          	auipc	ra,0xfffff
    800025ba:	82c080e7          	jalr	-2004(ra) # 80000de2 <acquire>
  reparent(p);
    800025be:	854e                	mv	a0,s3
    800025c0:	00000097          	auipc	ra,0x0
    800025c4:	d34080e7          	jalr	-716(ra) # 800022f4 <reparent>
  wakeup1(original_parent);
    800025c8:	8526                	mv	a0,s1
    800025ca:	fffff097          	auipc	ra,0xfffff
    800025ce:	720080e7          	jalr	1824(ra) # 80001cea <wakeup1>
  p->xstate = status;
    800025d2:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800025d6:	4791                	li	a5,4
    800025d8:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800025dc:	8526                	mv	a0,s1
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	8d4080e7          	jalr	-1836(ra) # 80000eb2 <release>
  sched();
    800025e6:	00000097          	auipc	ra,0x0
    800025ea:	e38080e7          	jalr	-456(ra) # 8000241e <sched>
  panic("zombie exit");
    800025ee:	00006517          	auipc	a0,0x6
    800025f2:	cfa50513          	addi	a0,a0,-774 # 800082e8 <digits+0x2a8>
    800025f6:	ffffe097          	auipc	ra,0xffffe
    800025fa:	f5a080e7          	jalr	-166(ra) # 80000550 <panic>

00000000800025fe <yield>:
{
    800025fe:	1101                	addi	sp,sp,-32
    80002600:	ec06                	sd	ra,24(sp)
    80002602:	e822                	sd	s0,16(sp)
    80002604:	e426                	sd	s1,8(sp)
    80002606:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002608:	00000097          	auipc	ra,0x0
    8000260c:	822080e7          	jalr	-2014(ra) # 80001e2a <myproc>
    80002610:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	7d0080e7          	jalr	2000(ra) # 80000de2 <acquire>
  p->state = RUNNABLE;
    8000261a:	4789                	li	a5,2
    8000261c:	d09c                	sw	a5,32(s1)
  sched();
    8000261e:	00000097          	auipc	ra,0x0
    80002622:	e00080e7          	jalr	-512(ra) # 8000241e <sched>
  release(&p->lock);
    80002626:	8526                	mv	a0,s1
    80002628:	fffff097          	auipc	ra,0xfffff
    8000262c:	88a080e7          	jalr	-1910(ra) # 80000eb2 <release>
}
    80002630:	60e2                	ld	ra,24(sp)
    80002632:	6442                	ld	s0,16(sp)
    80002634:	64a2                	ld	s1,8(sp)
    80002636:	6105                	addi	sp,sp,32
    80002638:	8082                	ret

000000008000263a <sleep>:
{
    8000263a:	7179                	addi	sp,sp,-48
    8000263c:	f406                	sd	ra,40(sp)
    8000263e:	f022                	sd	s0,32(sp)
    80002640:	ec26                	sd	s1,24(sp)
    80002642:	e84a                	sd	s2,16(sp)
    80002644:	e44e                	sd	s3,8(sp)
    80002646:	1800                	addi	s0,sp,48
    80002648:	89aa                	mv	s3,a0
    8000264a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000264c:	fffff097          	auipc	ra,0xfffff
    80002650:	7de080e7          	jalr	2014(ra) # 80001e2a <myproc>
    80002654:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002656:	05250663          	beq	a0,s2,800026a2 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000265a:	ffffe097          	auipc	ra,0xffffe
    8000265e:	788080e7          	jalr	1928(ra) # 80000de2 <acquire>
    release(lk);
    80002662:	854a                	mv	a0,s2
    80002664:	fffff097          	auipc	ra,0xfffff
    80002668:	84e080e7          	jalr	-1970(ra) # 80000eb2 <release>
  p->chan = chan;
    8000266c:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    80002670:	4785                	li	a5,1
    80002672:	d09c                	sw	a5,32(s1)
  sched();
    80002674:	00000097          	auipc	ra,0x0
    80002678:	daa080e7          	jalr	-598(ra) # 8000241e <sched>
  p->chan = 0;
    8000267c:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    80002680:	8526                	mv	a0,s1
    80002682:	fffff097          	auipc	ra,0xfffff
    80002686:	830080e7          	jalr	-2000(ra) # 80000eb2 <release>
    acquire(lk);
    8000268a:	854a                	mv	a0,s2
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	756080e7          	jalr	1878(ra) # 80000de2 <acquire>
}
    80002694:	70a2                	ld	ra,40(sp)
    80002696:	7402                	ld	s0,32(sp)
    80002698:	64e2                	ld	s1,24(sp)
    8000269a:	6942                	ld	s2,16(sp)
    8000269c:	69a2                	ld	s3,8(sp)
    8000269e:	6145                	addi	sp,sp,48
    800026a0:	8082                	ret
  p->chan = chan;
    800026a2:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800026a6:	4785                	li	a5,1
    800026a8:	d11c                	sw	a5,32(a0)
  sched();
    800026aa:	00000097          	auipc	ra,0x0
    800026ae:	d74080e7          	jalr	-652(ra) # 8000241e <sched>
  p->chan = 0;
    800026b2:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800026b6:	bff9                	j	80002694 <sleep+0x5a>

00000000800026b8 <wait>:
{
    800026b8:	715d                	addi	sp,sp,-80
    800026ba:	e486                	sd	ra,72(sp)
    800026bc:	e0a2                	sd	s0,64(sp)
    800026be:	fc26                	sd	s1,56(sp)
    800026c0:	f84a                	sd	s2,48(sp)
    800026c2:	f44e                	sd	s3,40(sp)
    800026c4:	f052                	sd	s4,32(sp)
    800026c6:	ec56                	sd	s5,24(sp)
    800026c8:	e85a                	sd	s6,16(sp)
    800026ca:	e45e                	sd	s7,8(sp)
    800026cc:	e062                	sd	s8,0(sp)
    800026ce:	0880                	addi	s0,sp,80
    800026d0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	758080e7          	jalr	1880(ra) # 80001e2a <myproc>
    800026da:	892a                	mv	s2,a0
  acquire(&p->lock);
    800026dc:	8c2a                	mv	s8,a0
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	704080e7          	jalr	1796(ra) # 80000de2 <acquire>
    havekids = 0;
    800026e6:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800026e8:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800026ea:	00016997          	auipc	s3,0x16
    800026ee:	cbe98993          	addi	s3,s3,-834 # 800183a8 <tickslock>
        havekids = 1;
    800026f2:	4a85                	li	s5,1
    havekids = 0;
    800026f4:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800026f6:	00010497          	auipc	s1,0x10
    800026fa:	0b248493          	addi	s1,s1,178 # 800127a8 <proc>
    800026fe:	a08d                	j	80002760 <wait+0xa8>
          pid = np->pid;
    80002700:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002704:	000b0e63          	beqz	s6,80002720 <wait+0x68>
    80002708:	4691                	li	a3,4
    8000270a:	03c48613          	addi	a2,s1,60
    8000270e:	85da                	mv	a1,s6
    80002710:	05893503          	ld	a0,88(s2)
    80002714:	fffff097          	auipc	ra,0xfffff
    80002718:	40a080e7          	jalr	1034(ra) # 80001b1e <copyout>
    8000271c:	02054263          	bltz	a0,80002740 <wait+0x88>
          freeproc(np);
    80002720:	8526                	mv	a0,s1
    80002722:	00000097          	auipc	ra,0x0
    80002726:	8ba080e7          	jalr	-1862(ra) # 80001fdc <freeproc>
          release(&np->lock);
    8000272a:	8526                	mv	a0,s1
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	786080e7          	jalr	1926(ra) # 80000eb2 <release>
          release(&p->lock);
    80002734:	854a                	mv	a0,s2
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	77c080e7          	jalr	1916(ra) # 80000eb2 <release>
          return pid;
    8000273e:	a8a9                	j	80002798 <wait+0xe0>
            release(&np->lock);
    80002740:	8526                	mv	a0,s1
    80002742:	ffffe097          	auipc	ra,0xffffe
    80002746:	770080e7          	jalr	1904(ra) # 80000eb2 <release>
            release(&p->lock);
    8000274a:	854a                	mv	a0,s2
    8000274c:	ffffe097          	auipc	ra,0xffffe
    80002750:	766080e7          	jalr	1894(ra) # 80000eb2 <release>
            return -1;
    80002754:	59fd                	li	s3,-1
    80002756:	a089                	j	80002798 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002758:	17048493          	addi	s1,s1,368
    8000275c:	03348463          	beq	s1,s3,80002784 <wait+0xcc>
      if(np->parent == p){
    80002760:	749c                	ld	a5,40(s1)
    80002762:	ff279be3          	bne	a5,s2,80002758 <wait+0xa0>
        acquire(&np->lock);
    80002766:	8526                	mv	a0,s1
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	67a080e7          	jalr	1658(ra) # 80000de2 <acquire>
        if(np->state == ZOMBIE){
    80002770:	509c                	lw	a5,32(s1)
    80002772:	f94787e3          	beq	a5,s4,80002700 <wait+0x48>
        release(&np->lock);
    80002776:	8526                	mv	a0,s1
    80002778:	ffffe097          	auipc	ra,0xffffe
    8000277c:	73a080e7          	jalr	1850(ra) # 80000eb2 <release>
        havekids = 1;
    80002780:	8756                	mv	a4,s5
    80002782:	bfd9                	j	80002758 <wait+0xa0>
    if(!havekids || p->killed){
    80002784:	c701                	beqz	a4,8000278c <wait+0xd4>
    80002786:	03892783          	lw	a5,56(s2)
    8000278a:	c785                	beqz	a5,800027b2 <wait+0xfa>
      release(&p->lock);
    8000278c:	854a                	mv	a0,s2
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	724080e7          	jalr	1828(ra) # 80000eb2 <release>
      return -1;
    80002796:	59fd                	li	s3,-1
}
    80002798:	854e                	mv	a0,s3
    8000279a:	60a6                	ld	ra,72(sp)
    8000279c:	6406                	ld	s0,64(sp)
    8000279e:	74e2                	ld	s1,56(sp)
    800027a0:	7942                	ld	s2,48(sp)
    800027a2:	79a2                	ld	s3,40(sp)
    800027a4:	7a02                	ld	s4,32(sp)
    800027a6:	6ae2                	ld	s5,24(sp)
    800027a8:	6b42                	ld	s6,16(sp)
    800027aa:	6ba2                	ld	s7,8(sp)
    800027ac:	6c02                	ld	s8,0(sp)
    800027ae:	6161                	addi	sp,sp,80
    800027b0:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800027b2:	85e2                	mv	a1,s8
    800027b4:	854a                	mv	a0,s2
    800027b6:	00000097          	auipc	ra,0x0
    800027ba:	e84080e7          	jalr	-380(ra) # 8000263a <sleep>
    havekids = 0;
    800027be:	bf1d                	j	800026f4 <wait+0x3c>

00000000800027c0 <wakeup>:
{
    800027c0:	7139                	addi	sp,sp,-64
    800027c2:	fc06                	sd	ra,56(sp)
    800027c4:	f822                	sd	s0,48(sp)
    800027c6:	f426                	sd	s1,40(sp)
    800027c8:	f04a                	sd	s2,32(sp)
    800027ca:	ec4e                	sd	s3,24(sp)
    800027cc:	e852                	sd	s4,16(sp)
    800027ce:	e456                	sd	s5,8(sp)
    800027d0:	0080                	addi	s0,sp,64
    800027d2:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800027d4:	00010497          	auipc	s1,0x10
    800027d8:	fd448493          	addi	s1,s1,-44 # 800127a8 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800027dc:	4985                	li	s3,1
      p->state = RUNNABLE;
    800027de:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800027e0:	00016917          	auipc	s2,0x16
    800027e4:	bc890913          	addi	s2,s2,-1080 # 800183a8 <tickslock>
    800027e8:	a821                	j	80002800 <wakeup+0x40>
      p->state = RUNNABLE;
    800027ea:	0354a023          	sw	s5,32(s1)
    release(&p->lock);
    800027ee:	8526                	mv	a0,s1
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	6c2080e7          	jalr	1730(ra) # 80000eb2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800027f8:	17048493          	addi	s1,s1,368
    800027fc:	01248e63          	beq	s1,s2,80002818 <wakeup+0x58>
    acquire(&p->lock);
    80002800:	8526                	mv	a0,s1
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	5e0080e7          	jalr	1504(ra) # 80000de2 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000280a:	509c                	lw	a5,32(s1)
    8000280c:	ff3791e3          	bne	a5,s3,800027ee <wakeup+0x2e>
    80002810:	789c                	ld	a5,48(s1)
    80002812:	fd479ee3          	bne	a5,s4,800027ee <wakeup+0x2e>
    80002816:	bfd1                	j	800027ea <wakeup+0x2a>
}
    80002818:	70e2                	ld	ra,56(sp)
    8000281a:	7442                	ld	s0,48(sp)
    8000281c:	74a2                	ld	s1,40(sp)
    8000281e:	7902                	ld	s2,32(sp)
    80002820:	69e2                	ld	s3,24(sp)
    80002822:	6a42                	ld	s4,16(sp)
    80002824:	6aa2                	ld	s5,8(sp)
    80002826:	6121                	addi	sp,sp,64
    80002828:	8082                	ret

000000008000282a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000282a:	7179                	addi	sp,sp,-48
    8000282c:	f406                	sd	ra,40(sp)
    8000282e:	f022                	sd	s0,32(sp)
    80002830:	ec26                	sd	s1,24(sp)
    80002832:	e84a                	sd	s2,16(sp)
    80002834:	e44e                	sd	s3,8(sp)
    80002836:	1800                	addi	s0,sp,48
    80002838:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000283a:	00010497          	auipc	s1,0x10
    8000283e:	f6e48493          	addi	s1,s1,-146 # 800127a8 <proc>
    80002842:	00016997          	auipc	s3,0x16
    80002846:	b6698993          	addi	s3,s3,-1178 # 800183a8 <tickslock>
    acquire(&p->lock);
    8000284a:	8526                	mv	a0,s1
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	596080e7          	jalr	1430(ra) # 80000de2 <acquire>
    if(p->pid == pid){
    80002854:	40bc                	lw	a5,64(s1)
    80002856:	01278d63          	beq	a5,s2,80002870 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000285a:	8526                	mv	a0,s1
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	656080e7          	jalr	1622(ra) # 80000eb2 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002864:	17048493          	addi	s1,s1,368
    80002868:	ff3491e3          	bne	s1,s3,8000284a <kill+0x20>
  }
  return -1;
    8000286c:	557d                	li	a0,-1
    8000286e:	a821                	j	80002886 <kill+0x5c>
      p->killed = 1;
    80002870:	4785                	li	a5,1
    80002872:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    80002874:	5098                	lw	a4,32(s1)
    80002876:	00f70f63          	beq	a4,a5,80002894 <kill+0x6a>
      release(&p->lock);
    8000287a:	8526                	mv	a0,s1
    8000287c:	ffffe097          	auipc	ra,0xffffe
    80002880:	636080e7          	jalr	1590(ra) # 80000eb2 <release>
      return 0;
    80002884:	4501                	li	a0,0
}
    80002886:	70a2                	ld	ra,40(sp)
    80002888:	7402                	ld	s0,32(sp)
    8000288a:	64e2                	ld	s1,24(sp)
    8000288c:	6942                	ld	s2,16(sp)
    8000288e:	69a2                	ld	s3,8(sp)
    80002890:	6145                	addi	sp,sp,48
    80002892:	8082                	ret
        p->state = RUNNABLE;
    80002894:	4789                	li	a5,2
    80002896:	d09c                	sw	a5,32(s1)
    80002898:	b7cd                	j	8000287a <kill+0x50>

000000008000289a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000289a:	7179                	addi	sp,sp,-48
    8000289c:	f406                	sd	ra,40(sp)
    8000289e:	f022                	sd	s0,32(sp)
    800028a0:	ec26                	sd	s1,24(sp)
    800028a2:	e84a                	sd	s2,16(sp)
    800028a4:	e44e                	sd	s3,8(sp)
    800028a6:	e052                	sd	s4,0(sp)
    800028a8:	1800                	addi	s0,sp,48
    800028aa:	84aa                	mv	s1,a0
    800028ac:	892e                	mv	s2,a1
    800028ae:	89b2                	mv	s3,a2
    800028b0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028b2:	fffff097          	auipc	ra,0xfffff
    800028b6:	578080e7          	jalr	1400(ra) # 80001e2a <myproc>
  if(user_dst){
    800028ba:	c08d                	beqz	s1,800028dc <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800028bc:	86d2                	mv	a3,s4
    800028be:	864e                	mv	a2,s3
    800028c0:	85ca                	mv	a1,s2
    800028c2:	6d28                	ld	a0,88(a0)
    800028c4:	fffff097          	auipc	ra,0xfffff
    800028c8:	25a080e7          	jalr	602(ra) # 80001b1e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028cc:	70a2                	ld	ra,40(sp)
    800028ce:	7402                	ld	s0,32(sp)
    800028d0:	64e2                	ld	s1,24(sp)
    800028d2:	6942                	ld	s2,16(sp)
    800028d4:	69a2                	ld	s3,8(sp)
    800028d6:	6a02                	ld	s4,0(sp)
    800028d8:	6145                	addi	sp,sp,48
    800028da:	8082                	ret
    memmove((char *)dst, src, len);
    800028dc:	000a061b          	sext.w	a2,s4
    800028e0:	85ce                	mv	a1,s3
    800028e2:	854a                	mv	a0,s2
    800028e4:	fffff097          	auipc	ra,0xfffff
    800028e8:	93e080e7          	jalr	-1730(ra) # 80001222 <memmove>
    return 0;
    800028ec:	8526                	mv	a0,s1
    800028ee:	bff9                	j	800028cc <either_copyout+0x32>

00000000800028f0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028f0:	7179                	addi	sp,sp,-48
    800028f2:	f406                	sd	ra,40(sp)
    800028f4:	f022                	sd	s0,32(sp)
    800028f6:	ec26                	sd	s1,24(sp)
    800028f8:	e84a                	sd	s2,16(sp)
    800028fa:	e44e                	sd	s3,8(sp)
    800028fc:	e052                	sd	s4,0(sp)
    800028fe:	1800                	addi	s0,sp,48
    80002900:	892a                	mv	s2,a0
    80002902:	84ae                	mv	s1,a1
    80002904:	89b2                	mv	s3,a2
    80002906:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002908:	fffff097          	auipc	ra,0xfffff
    8000290c:	522080e7          	jalr	1314(ra) # 80001e2a <myproc>
  if(user_src){
    80002910:	c08d                	beqz	s1,80002932 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002912:	86d2                	mv	a3,s4
    80002914:	864e                	mv	a2,s3
    80002916:	85ca                	mv	a1,s2
    80002918:	6d28                	ld	a0,88(a0)
    8000291a:	fffff097          	auipc	ra,0xfffff
    8000291e:	290080e7          	jalr	656(ra) # 80001baa <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002922:	70a2                	ld	ra,40(sp)
    80002924:	7402                	ld	s0,32(sp)
    80002926:	64e2                	ld	s1,24(sp)
    80002928:	6942                	ld	s2,16(sp)
    8000292a:	69a2                	ld	s3,8(sp)
    8000292c:	6a02                	ld	s4,0(sp)
    8000292e:	6145                	addi	sp,sp,48
    80002930:	8082                	ret
    memmove(dst, (char*)src, len);
    80002932:	000a061b          	sext.w	a2,s4
    80002936:	85ce                	mv	a1,s3
    80002938:	854a                	mv	a0,s2
    8000293a:	fffff097          	auipc	ra,0xfffff
    8000293e:	8e8080e7          	jalr	-1816(ra) # 80001222 <memmove>
    return 0;
    80002942:	8526                	mv	a0,s1
    80002944:	bff9                	j	80002922 <either_copyin+0x32>

0000000080002946 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002946:	715d                	addi	sp,sp,-80
    80002948:	e486                	sd	ra,72(sp)
    8000294a:	e0a2                	sd	s0,64(sp)
    8000294c:	fc26                	sd	s1,56(sp)
    8000294e:	f84a                	sd	s2,48(sp)
    80002950:	f44e                	sd	s3,40(sp)
    80002952:	f052                	sd	s4,32(sp)
    80002954:	ec56                	sd	s5,24(sp)
    80002956:	e85a                	sd	s6,16(sp)
    80002958:	e45e                	sd	s7,8(sp)
    8000295a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000295c:	00006517          	auipc	a0,0x6
    80002960:	80450513          	addi	a0,a0,-2044 # 80008160 <digits+0x120>
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	c36080e7          	jalr	-970(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000296c:	00010497          	auipc	s1,0x10
    80002970:	f9c48493          	addi	s1,s1,-100 # 80012908 <proc+0x160>
    80002974:	00016917          	auipc	s2,0x16
    80002978:	b9490913          	addi	s2,s2,-1132 # 80018508 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000297c:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000297e:	00006997          	auipc	s3,0x6
    80002982:	97a98993          	addi	s3,s3,-1670 # 800082f8 <digits+0x2b8>
    printf("%d %s %s", p->pid, state, p->name);
    80002986:	00006a97          	auipc	s5,0x6
    8000298a:	97aa8a93          	addi	s5,s5,-1670 # 80008300 <digits+0x2c0>
    printf("\n");
    8000298e:	00005a17          	auipc	s4,0x5
    80002992:	7d2a0a13          	addi	s4,s4,2002 # 80008160 <digits+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002996:	00006b97          	auipc	s7,0x6
    8000299a:	9a2b8b93          	addi	s7,s7,-1630 # 80008338 <states.1712>
    8000299e:	a00d                	j	800029c0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800029a0:	ee06a583          	lw	a1,-288(a3)
    800029a4:	8556                	mv	a0,s5
    800029a6:	ffffe097          	auipc	ra,0xffffe
    800029aa:	bf4080e7          	jalr	-1036(ra) # 8000059a <printf>
    printf("\n");
    800029ae:	8552                	mv	a0,s4
    800029b0:	ffffe097          	auipc	ra,0xffffe
    800029b4:	bea080e7          	jalr	-1046(ra) # 8000059a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029b8:	17048493          	addi	s1,s1,368
    800029bc:	03248163          	beq	s1,s2,800029de <procdump+0x98>
    if(p->state == UNUSED)
    800029c0:	86a6                	mv	a3,s1
    800029c2:	ec04a783          	lw	a5,-320(s1)
    800029c6:	dbed                	beqz	a5,800029b8 <procdump+0x72>
      state = "???";
    800029c8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029ca:	fcfb6be3          	bltu	s6,a5,800029a0 <procdump+0x5a>
    800029ce:	1782                	slli	a5,a5,0x20
    800029d0:	9381                	srli	a5,a5,0x20
    800029d2:	078e                	slli	a5,a5,0x3
    800029d4:	97de                	add	a5,a5,s7
    800029d6:	6390                	ld	a2,0(a5)
    800029d8:	f661                	bnez	a2,800029a0 <procdump+0x5a>
      state = "???";
    800029da:	864e                	mv	a2,s3
    800029dc:	b7d1                	j	800029a0 <procdump+0x5a>
  }
}
    800029de:	60a6                	ld	ra,72(sp)
    800029e0:	6406                	ld	s0,64(sp)
    800029e2:	74e2                	ld	s1,56(sp)
    800029e4:	7942                	ld	s2,48(sp)
    800029e6:	79a2                	ld	s3,40(sp)
    800029e8:	7a02                	ld	s4,32(sp)
    800029ea:	6ae2                	ld	s5,24(sp)
    800029ec:	6b42                	ld	s6,16(sp)
    800029ee:	6ba2                	ld	s7,8(sp)
    800029f0:	6161                	addi	sp,sp,80
    800029f2:	8082                	ret

00000000800029f4 <swtch>:
    800029f4:	00153023          	sd	ra,0(a0)
    800029f8:	00253423          	sd	sp,8(a0)
    800029fc:	e900                	sd	s0,16(a0)
    800029fe:	ed04                	sd	s1,24(a0)
    80002a00:	03253023          	sd	s2,32(a0)
    80002a04:	03353423          	sd	s3,40(a0)
    80002a08:	03453823          	sd	s4,48(a0)
    80002a0c:	03553c23          	sd	s5,56(a0)
    80002a10:	05653023          	sd	s6,64(a0)
    80002a14:	05753423          	sd	s7,72(a0)
    80002a18:	05853823          	sd	s8,80(a0)
    80002a1c:	05953c23          	sd	s9,88(a0)
    80002a20:	07a53023          	sd	s10,96(a0)
    80002a24:	07b53423          	sd	s11,104(a0)
    80002a28:	0005b083          	ld	ra,0(a1)
    80002a2c:	0085b103          	ld	sp,8(a1)
    80002a30:	6980                	ld	s0,16(a1)
    80002a32:	6d84                	ld	s1,24(a1)
    80002a34:	0205b903          	ld	s2,32(a1)
    80002a38:	0285b983          	ld	s3,40(a1)
    80002a3c:	0305ba03          	ld	s4,48(a1)
    80002a40:	0385ba83          	ld	s5,56(a1)
    80002a44:	0405bb03          	ld	s6,64(a1)
    80002a48:	0485bb83          	ld	s7,72(a1)
    80002a4c:	0505bc03          	ld	s8,80(a1)
    80002a50:	0585bc83          	ld	s9,88(a1)
    80002a54:	0605bd03          	ld	s10,96(a1)
    80002a58:	0685bd83          	ld	s11,104(a1)
    80002a5c:	8082                	ret

0000000080002a5e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a5e:	1141                	addi	sp,sp,-16
    80002a60:	e406                	sd	ra,8(sp)
    80002a62:	e022                	sd	s0,0(sp)
    80002a64:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a66:	00006597          	auipc	a1,0x6
    80002a6a:	8fa58593          	addi	a1,a1,-1798 # 80008360 <states.1712+0x28>
    80002a6e:	00016517          	auipc	a0,0x16
    80002a72:	93a50513          	addi	a0,a0,-1734 # 800183a8 <tickslock>
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	4e8080e7          	jalr	1256(ra) # 80000f5e <initlock>
}
    80002a7e:	60a2                	ld	ra,8(sp)
    80002a80:	6402                	ld	s0,0(sp)
    80002a82:	0141                	addi	sp,sp,16
    80002a84:	8082                	ret

0000000080002a86 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a86:	1141                	addi	sp,sp,-16
    80002a88:	e422                	sd	s0,8(sp)
    80002a8a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a8c:	00003797          	auipc	a5,0x3
    80002a90:	4e478793          	addi	a5,a5,1252 # 80005f70 <kernelvec>
    80002a94:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a98:	6422                	ld	s0,8(sp)
    80002a9a:	0141                	addi	sp,sp,16
    80002a9c:	8082                	ret

0000000080002a9e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a9e:	1141                	addi	sp,sp,-16
    80002aa0:	e406                	sd	ra,8(sp)
    80002aa2:	e022                	sd	s0,0(sp)
    80002aa4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002aa6:	fffff097          	auipc	ra,0xfffff
    80002aaa:	384080e7          	jalr	900(ra) # 80001e2a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002ab2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ab4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002ab8:	00004617          	auipc	a2,0x4
    80002abc:	54860613          	addi	a2,a2,1352 # 80007000 <_trampoline>
    80002ac0:	00004697          	auipc	a3,0x4
    80002ac4:	54068693          	addi	a3,a3,1344 # 80007000 <_trampoline>
    80002ac8:	8e91                	sub	a3,a3,a2
    80002aca:	040007b7          	lui	a5,0x4000
    80002ace:	17fd                	addi	a5,a5,-1
    80002ad0:	07b2                	slli	a5,a5,0xc
    80002ad2:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ad4:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ad8:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ada:	180026f3          	csrr	a3,satp
    80002ade:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ae0:	7138                	ld	a4,96(a0)
    80002ae2:	6534                	ld	a3,72(a0)
    80002ae4:	6585                	lui	a1,0x1
    80002ae6:	96ae                	add	a3,a3,a1
    80002ae8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002aea:	7138                	ld	a4,96(a0)
    80002aec:	00000697          	auipc	a3,0x0
    80002af0:	13868693          	addi	a3,a3,312 # 80002c24 <usertrap>
    80002af4:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002af6:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002af8:	8692                	mv	a3,tp
    80002afa:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002afc:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b00:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b04:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b08:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b0c:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b0e:	6f18                	ld	a4,24(a4)
    80002b10:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b14:	6d2c                	ld	a1,88(a0)
    80002b16:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002b18:	00004717          	auipc	a4,0x4
    80002b1c:	57870713          	addi	a4,a4,1400 # 80007090 <userret>
    80002b20:	8f11                	sub	a4,a4,a2
    80002b22:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002b24:	577d                	li	a4,-1
    80002b26:	177e                	slli	a4,a4,0x3f
    80002b28:	8dd9                	or	a1,a1,a4
    80002b2a:	02000537          	lui	a0,0x2000
    80002b2e:	157d                	addi	a0,a0,-1
    80002b30:	0536                	slli	a0,a0,0xd
    80002b32:	9782                	jalr	a5
}
    80002b34:	60a2                	ld	ra,8(sp)
    80002b36:	6402                	ld	s0,0(sp)
    80002b38:	0141                	addi	sp,sp,16
    80002b3a:	8082                	ret

0000000080002b3c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b3c:	1101                	addi	sp,sp,-32
    80002b3e:	ec06                	sd	ra,24(sp)
    80002b40:	e822                	sd	s0,16(sp)
    80002b42:	e426                	sd	s1,8(sp)
    80002b44:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b46:	00016497          	auipc	s1,0x16
    80002b4a:	86248493          	addi	s1,s1,-1950 # 800183a8 <tickslock>
    80002b4e:	8526                	mv	a0,s1
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	292080e7          	jalr	658(ra) # 80000de2 <acquire>
  ticks++;
    80002b58:	00006517          	auipc	a0,0x6
    80002b5c:	4c850513          	addi	a0,a0,1224 # 80009020 <ticks>
    80002b60:	411c                	lw	a5,0(a0)
    80002b62:	2785                	addiw	a5,a5,1
    80002b64:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b66:	00000097          	auipc	ra,0x0
    80002b6a:	c5a080e7          	jalr	-934(ra) # 800027c0 <wakeup>
  release(&tickslock);
    80002b6e:	8526                	mv	a0,s1
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	342080e7          	jalr	834(ra) # 80000eb2 <release>
}
    80002b78:	60e2                	ld	ra,24(sp)
    80002b7a:	6442                	ld	s0,16(sp)
    80002b7c:	64a2                	ld	s1,8(sp)
    80002b7e:	6105                	addi	sp,sp,32
    80002b80:	8082                	ret

0000000080002b82 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b82:	1101                	addi	sp,sp,-32
    80002b84:	ec06                	sd	ra,24(sp)
    80002b86:	e822                	sd	s0,16(sp)
    80002b88:	e426                	sd	s1,8(sp)
    80002b8a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b8c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b90:	00074d63          	bltz	a4,80002baa <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b94:	57fd                	li	a5,-1
    80002b96:	17fe                	slli	a5,a5,0x3f
    80002b98:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b9a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b9c:	06f70363          	beq	a4,a5,80002c02 <devintr+0x80>
  }
}
    80002ba0:	60e2                	ld	ra,24(sp)
    80002ba2:	6442                	ld	s0,16(sp)
    80002ba4:	64a2                	ld	s1,8(sp)
    80002ba6:	6105                	addi	sp,sp,32
    80002ba8:	8082                	ret
     (scause & 0xff) == 9){
    80002baa:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002bae:	46a5                	li	a3,9
    80002bb0:	fed792e3          	bne	a5,a3,80002b94 <devintr+0x12>
    int irq = plic_claim();
    80002bb4:	00003097          	auipc	ra,0x3
    80002bb8:	4c4080e7          	jalr	1220(ra) # 80006078 <plic_claim>
    80002bbc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bbe:	47a9                	li	a5,10
    80002bc0:	02f50763          	beq	a0,a5,80002bee <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002bc4:	4785                	li	a5,1
    80002bc6:	02f50963          	beq	a0,a5,80002bf8 <devintr+0x76>
    return 1;
    80002bca:	4505                	li	a0,1
    } else if(irq){
    80002bcc:	d8f1                	beqz	s1,80002ba0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bce:	85a6                	mv	a1,s1
    80002bd0:	00005517          	auipc	a0,0x5
    80002bd4:	79850513          	addi	a0,a0,1944 # 80008368 <states.1712+0x30>
    80002bd8:	ffffe097          	auipc	ra,0xffffe
    80002bdc:	9c2080e7          	jalr	-1598(ra) # 8000059a <printf>
      plic_complete(irq);
    80002be0:	8526                	mv	a0,s1
    80002be2:	00003097          	auipc	ra,0x3
    80002be6:	4ba080e7          	jalr	1210(ra) # 8000609c <plic_complete>
    return 1;
    80002bea:	4505                	li	a0,1
    80002bec:	bf55                	j	80002ba0 <devintr+0x1e>
      uartintr();
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	dee080e7          	jalr	-530(ra) # 800009dc <uartintr>
    80002bf6:	b7ed                	j	80002be0 <devintr+0x5e>
      virtio_disk_intr();
    80002bf8:	00004097          	auipc	ra,0x4
    80002bfc:	94c080e7          	jalr	-1716(ra) # 80006544 <virtio_disk_intr>
    80002c00:	b7c5                	j	80002be0 <devintr+0x5e>
    if(cpuid() == 0){
    80002c02:	fffff097          	auipc	ra,0xfffff
    80002c06:	1fc080e7          	jalr	508(ra) # 80001dfe <cpuid>
    80002c0a:	c901                	beqz	a0,80002c1a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c0c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c10:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c12:	14479073          	csrw	sip,a5
    return 2;
    80002c16:	4509                	li	a0,2
    80002c18:	b761                	j	80002ba0 <devintr+0x1e>
      clockintr();
    80002c1a:	00000097          	auipc	ra,0x0
    80002c1e:	f22080e7          	jalr	-222(ra) # 80002b3c <clockintr>
    80002c22:	b7ed                	j	80002c0c <devintr+0x8a>

0000000080002c24 <usertrap>:
{
    80002c24:	1101                	addi	sp,sp,-32
    80002c26:	ec06                	sd	ra,24(sp)
    80002c28:	e822                	sd	s0,16(sp)
    80002c2a:	e426                	sd	s1,8(sp)
    80002c2c:	e04a                	sd	s2,0(sp)
    80002c2e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c30:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c34:	1007f793          	andi	a5,a5,256
    80002c38:	e3ad                	bnez	a5,80002c9a <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c3a:	00003797          	auipc	a5,0x3
    80002c3e:	33678793          	addi	a5,a5,822 # 80005f70 <kernelvec>
    80002c42:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c46:	fffff097          	auipc	ra,0xfffff
    80002c4a:	1e4080e7          	jalr	484(ra) # 80001e2a <myproc>
    80002c4e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c50:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c52:	14102773          	csrr	a4,sepc
    80002c56:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c58:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c5c:	47a1                	li	a5,8
    80002c5e:	04f71c63          	bne	a4,a5,80002cb6 <usertrap+0x92>
    if(p->killed)
    80002c62:	5d1c                	lw	a5,56(a0)
    80002c64:	e3b9                	bnez	a5,80002caa <usertrap+0x86>
    p->trapframe->epc += 4;
    80002c66:	70b8                	ld	a4,96(s1)
    80002c68:	6f1c                	ld	a5,24(a4)
    80002c6a:	0791                	addi	a5,a5,4
    80002c6c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c72:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c76:	10079073          	csrw	sstatus,a5
    syscall();
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	2e0080e7          	jalr	736(ra) # 80002f5a <syscall>
  if(p->killed)
    80002c82:	5c9c                	lw	a5,56(s1)
    80002c84:	ebc1                	bnez	a5,80002d14 <usertrap+0xf0>
  usertrapret();
    80002c86:	00000097          	auipc	ra,0x0
    80002c8a:	e18080e7          	jalr	-488(ra) # 80002a9e <usertrapret>
}
    80002c8e:	60e2                	ld	ra,24(sp)
    80002c90:	6442                	ld	s0,16(sp)
    80002c92:	64a2                	ld	s1,8(sp)
    80002c94:	6902                	ld	s2,0(sp)
    80002c96:	6105                	addi	sp,sp,32
    80002c98:	8082                	ret
    panic("usertrap: not from user mode");
    80002c9a:	00005517          	auipc	a0,0x5
    80002c9e:	6ee50513          	addi	a0,a0,1774 # 80008388 <states.1712+0x50>
    80002ca2:	ffffe097          	auipc	ra,0xffffe
    80002ca6:	8ae080e7          	jalr	-1874(ra) # 80000550 <panic>
      exit(-1);
    80002caa:	557d                	li	a0,-1
    80002cac:	00000097          	auipc	ra,0x0
    80002cb0:	848080e7          	jalr	-1976(ra) # 800024f4 <exit>
    80002cb4:	bf4d                	j	80002c66 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002cb6:	00000097          	auipc	ra,0x0
    80002cba:	ecc080e7          	jalr	-308(ra) # 80002b82 <devintr>
    80002cbe:	892a                	mv	s2,a0
    80002cc0:	c501                	beqz	a0,80002cc8 <usertrap+0xa4>
  if(p->killed)
    80002cc2:	5c9c                	lw	a5,56(s1)
    80002cc4:	c3a1                	beqz	a5,80002d04 <usertrap+0xe0>
    80002cc6:	a815                	j	80002cfa <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ccc:	40b0                	lw	a2,64(s1)
    80002cce:	00005517          	auipc	a0,0x5
    80002cd2:	6da50513          	addi	a0,a0,1754 # 800083a8 <states.1712+0x70>
    80002cd6:	ffffe097          	auipc	ra,0xffffe
    80002cda:	8c4080e7          	jalr	-1852(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cde:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ce2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ce6:	00005517          	auipc	a0,0x5
    80002cea:	6f250513          	addi	a0,a0,1778 # 800083d8 <states.1712+0xa0>
    80002cee:	ffffe097          	auipc	ra,0xffffe
    80002cf2:	8ac080e7          	jalr	-1876(ra) # 8000059a <printf>
    p->killed = 1;
    80002cf6:	4785                	li	a5,1
    80002cf8:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002cfa:	557d                	li	a0,-1
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	7f8080e7          	jalr	2040(ra) # 800024f4 <exit>
  if(which_dev == 2)
    80002d04:	4789                	li	a5,2
    80002d06:	f8f910e3          	bne	s2,a5,80002c86 <usertrap+0x62>
    yield();
    80002d0a:	00000097          	auipc	ra,0x0
    80002d0e:	8f4080e7          	jalr	-1804(ra) # 800025fe <yield>
    80002d12:	bf95                	j	80002c86 <usertrap+0x62>
  int which_dev = 0;
    80002d14:	4901                	li	s2,0
    80002d16:	b7d5                	j	80002cfa <usertrap+0xd6>

0000000080002d18 <kerneltrap>:
{
    80002d18:	7179                	addi	sp,sp,-48
    80002d1a:	f406                	sd	ra,40(sp)
    80002d1c:	f022                	sd	s0,32(sp)
    80002d1e:	ec26                	sd	s1,24(sp)
    80002d20:	e84a                	sd	s2,16(sp)
    80002d22:	e44e                	sd	s3,8(sp)
    80002d24:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d26:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d2a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d2e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d32:	1004f793          	andi	a5,s1,256
    80002d36:	cb85                	beqz	a5,80002d66 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d38:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d3c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d3e:	ef85                	bnez	a5,80002d76 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d40:	00000097          	auipc	ra,0x0
    80002d44:	e42080e7          	jalr	-446(ra) # 80002b82 <devintr>
    80002d48:	cd1d                	beqz	a0,80002d86 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d4a:	4789                	li	a5,2
    80002d4c:	06f50a63          	beq	a0,a5,80002dc0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d50:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d54:	10049073          	csrw	sstatus,s1
}
    80002d58:	70a2                	ld	ra,40(sp)
    80002d5a:	7402                	ld	s0,32(sp)
    80002d5c:	64e2                	ld	s1,24(sp)
    80002d5e:	6942                	ld	s2,16(sp)
    80002d60:	69a2                	ld	s3,8(sp)
    80002d62:	6145                	addi	sp,sp,48
    80002d64:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d66:	00005517          	auipc	a0,0x5
    80002d6a:	69250513          	addi	a0,a0,1682 # 800083f8 <states.1712+0xc0>
    80002d6e:	ffffd097          	auipc	ra,0xffffd
    80002d72:	7e2080e7          	jalr	2018(ra) # 80000550 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d76:	00005517          	auipc	a0,0x5
    80002d7a:	6aa50513          	addi	a0,a0,1706 # 80008420 <states.1712+0xe8>
    80002d7e:	ffffd097          	auipc	ra,0xffffd
    80002d82:	7d2080e7          	jalr	2002(ra) # 80000550 <panic>
    printf("scause %p\n", scause);
    80002d86:	85ce                	mv	a1,s3
    80002d88:	00005517          	auipc	a0,0x5
    80002d8c:	6b850513          	addi	a0,a0,1720 # 80008440 <states.1712+0x108>
    80002d90:	ffffe097          	auipc	ra,0xffffe
    80002d94:	80a080e7          	jalr	-2038(ra) # 8000059a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d98:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d9c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002da0:	00005517          	auipc	a0,0x5
    80002da4:	6b050513          	addi	a0,a0,1712 # 80008450 <states.1712+0x118>
    80002da8:	ffffd097          	auipc	ra,0xffffd
    80002dac:	7f2080e7          	jalr	2034(ra) # 8000059a <printf>
    panic("kerneltrap");
    80002db0:	00005517          	auipc	a0,0x5
    80002db4:	6b850513          	addi	a0,a0,1720 # 80008468 <states.1712+0x130>
    80002db8:	ffffd097          	auipc	ra,0xffffd
    80002dbc:	798080e7          	jalr	1944(ra) # 80000550 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dc0:	fffff097          	auipc	ra,0xfffff
    80002dc4:	06a080e7          	jalr	106(ra) # 80001e2a <myproc>
    80002dc8:	d541                	beqz	a0,80002d50 <kerneltrap+0x38>
    80002dca:	fffff097          	auipc	ra,0xfffff
    80002dce:	060080e7          	jalr	96(ra) # 80001e2a <myproc>
    80002dd2:	5118                	lw	a4,32(a0)
    80002dd4:	478d                	li	a5,3
    80002dd6:	f6f71de3          	bne	a4,a5,80002d50 <kerneltrap+0x38>
    yield();
    80002dda:	00000097          	auipc	ra,0x0
    80002dde:	824080e7          	jalr	-2012(ra) # 800025fe <yield>
    80002de2:	b7bd                	j	80002d50 <kerneltrap+0x38>

0000000080002de4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	e426                	sd	s1,8(sp)
    80002dec:	1000                	addi	s0,sp,32
    80002dee:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	03a080e7          	jalr	58(ra) # 80001e2a <myproc>
  switch (n) {
    80002df8:	4795                	li	a5,5
    80002dfa:	0497e163          	bltu	a5,s1,80002e3c <argraw+0x58>
    80002dfe:	048a                	slli	s1,s1,0x2
    80002e00:	00005717          	auipc	a4,0x5
    80002e04:	6a070713          	addi	a4,a4,1696 # 800084a0 <states.1712+0x168>
    80002e08:	94ba                	add	s1,s1,a4
    80002e0a:	409c                	lw	a5,0(s1)
    80002e0c:	97ba                	add	a5,a5,a4
    80002e0e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002e10:	713c                	ld	a5,96(a0)
    80002e12:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e14:	60e2                	ld	ra,24(sp)
    80002e16:	6442                	ld	s0,16(sp)
    80002e18:	64a2                	ld	s1,8(sp)
    80002e1a:	6105                	addi	sp,sp,32
    80002e1c:	8082                	ret
    return p->trapframe->a1;
    80002e1e:	713c                	ld	a5,96(a0)
    80002e20:	7fa8                	ld	a0,120(a5)
    80002e22:	bfcd                	j	80002e14 <argraw+0x30>
    return p->trapframe->a2;
    80002e24:	713c                	ld	a5,96(a0)
    80002e26:	63c8                	ld	a0,128(a5)
    80002e28:	b7f5                	j	80002e14 <argraw+0x30>
    return p->trapframe->a3;
    80002e2a:	713c                	ld	a5,96(a0)
    80002e2c:	67c8                	ld	a0,136(a5)
    80002e2e:	b7dd                	j	80002e14 <argraw+0x30>
    return p->trapframe->a4;
    80002e30:	713c                	ld	a5,96(a0)
    80002e32:	6bc8                	ld	a0,144(a5)
    80002e34:	b7c5                	j	80002e14 <argraw+0x30>
    return p->trapframe->a5;
    80002e36:	713c                	ld	a5,96(a0)
    80002e38:	6fc8                	ld	a0,152(a5)
    80002e3a:	bfe9                	j	80002e14 <argraw+0x30>
  panic("argraw");
    80002e3c:	00005517          	auipc	a0,0x5
    80002e40:	63c50513          	addi	a0,a0,1596 # 80008478 <states.1712+0x140>
    80002e44:	ffffd097          	auipc	ra,0xffffd
    80002e48:	70c080e7          	jalr	1804(ra) # 80000550 <panic>

0000000080002e4c <fetchaddr>:
{
    80002e4c:	1101                	addi	sp,sp,-32
    80002e4e:	ec06                	sd	ra,24(sp)
    80002e50:	e822                	sd	s0,16(sp)
    80002e52:	e426                	sd	s1,8(sp)
    80002e54:	e04a                	sd	s2,0(sp)
    80002e56:	1000                	addi	s0,sp,32
    80002e58:	84aa                	mv	s1,a0
    80002e5a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	fce080e7          	jalr	-50(ra) # 80001e2a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002e64:	693c                	ld	a5,80(a0)
    80002e66:	02f4f863          	bgeu	s1,a5,80002e96 <fetchaddr+0x4a>
    80002e6a:	00848713          	addi	a4,s1,8
    80002e6e:	02e7e663          	bltu	a5,a4,80002e9a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e72:	46a1                	li	a3,8
    80002e74:	8626                	mv	a2,s1
    80002e76:	85ca                	mv	a1,s2
    80002e78:	6d28                	ld	a0,88(a0)
    80002e7a:	fffff097          	auipc	ra,0xfffff
    80002e7e:	d30080e7          	jalr	-720(ra) # 80001baa <copyin>
    80002e82:	00a03533          	snez	a0,a0
    80002e86:	40a00533          	neg	a0,a0
}
    80002e8a:	60e2                	ld	ra,24(sp)
    80002e8c:	6442                	ld	s0,16(sp)
    80002e8e:	64a2                	ld	s1,8(sp)
    80002e90:	6902                	ld	s2,0(sp)
    80002e92:	6105                	addi	sp,sp,32
    80002e94:	8082                	ret
    return -1;
    80002e96:	557d                	li	a0,-1
    80002e98:	bfcd                	j	80002e8a <fetchaddr+0x3e>
    80002e9a:	557d                	li	a0,-1
    80002e9c:	b7fd                	j	80002e8a <fetchaddr+0x3e>

0000000080002e9e <fetchstr>:
{
    80002e9e:	7179                	addi	sp,sp,-48
    80002ea0:	f406                	sd	ra,40(sp)
    80002ea2:	f022                	sd	s0,32(sp)
    80002ea4:	ec26                	sd	s1,24(sp)
    80002ea6:	e84a                	sd	s2,16(sp)
    80002ea8:	e44e                	sd	s3,8(sp)
    80002eaa:	1800                	addi	s0,sp,48
    80002eac:	892a                	mv	s2,a0
    80002eae:	84ae                	mv	s1,a1
    80002eb0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002eb2:	fffff097          	auipc	ra,0xfffff
    80002eb6:	f78080e7          	jalr	-136(ra) # 80001e2a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002eba:	86ce                	mv	a3,s3
    80002ebc:	864a                	mv	a2,s2
    80002ebe:	85a6                	mv	a1,s1
    80002ec0:	6d28                	ld	a0,88(a0)
    80002ec2:	fffff097          	auipc	ra,0xfffff
    80002ec6:	d74080e7          	jalr	-652(ra) # 80001c36 <copyinstr>
  if(err < 0)
    80002eca:	00054763          	bltz	a0,80002ed8 <fetchstr+0x3a>
  return strlen(buf);
    80002ece:	8526                	mv	a0,s1
    80002ed0:	ffffe097          	auipc	ra,0xffffe
    80002ed4:	47a080e7          	jalr	1146(ra) # 8000134a <strlen>
}
    80002ed8:	70a2                	ld	ra,40(sp)
    80002eda:	7402                	ld	s0,32(sp)
    80002edc:	64e2                	ld	s1,24(sp)
    80002ede:	6942                	ld	s2,16(sp)
    80002ee0:	69a2                	ld	s3,8(sp)
    80002ee2:	6145                	addi	sp,sp,48
    80002ee4:	8082                	ret

0000000080002ee6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002ee6:	1101                	addi	sp,sp,-32
    80002ee8:	ec06                	sd	ra,24(sp)
    80002eea:	e822                	sd	s0,16(sp)
    80002eec:	e426                	sd	s1,8(sp)
    80002eee:	1000                	addi	s0,sp,32
    80002ef0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ef2:	00000097          	auipc	ra,0x0
    80002ef6:	ef2080e7          	jalr	-270(ra) # 80002de4 <argraw>
    80002efa:	c088                	sw	a0,0(s1)
  return 0;
}
    80002efc:	4501                	li	a0,0
    80002efe:	60e2                	ld	ra,24(sp)
    80002f00:	6442                	ld	s0,16(sp)
    80002f02:	64a2                	ld	s1,8(sp)
    80002f04:	6105                	addi	sp,sp,32
    80002f06:	8082                	ret

0000000080002f08 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002f08:	1101                	addi	sp,sp,-32
    80002f0a:	ec06                	sd	ra,24(sp)
    80002f0c:	e822                	sd	s0,16(sp)
    80002f0e:	e426                	sd	s1,8(sp)
    80002f10:	1000                	addi	s0,sp,32
    80002f12:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f14:	00000097          	auipc	ra,0x0
    80002f18:	ed0080e7          	jalr	-304(ra) # 80002de4 <argraw>
    80002f1c:	e088                	sd	a0,0(s1)
  return 0;
}
    80002f1e:	4501                	li	a0,0
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	64a2                	ld	s1,8(sp)
    80002f26:	6105                	addi	sp,sp,32
    80002f28:	8082                	ret

0000000080002f2a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	e426                	sd	s1,8(sp)
    80002f32:	e04a                	sd	s2,0(sp)
    80002f34:	1000                	addi	s0,sp,32
    80002f36:	84ae                	mv	s1,a1
    80002f38:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002f3a:	00000097          	auipc	ra,0x0
    80002f3e:	eaa080e7          	jalr	-342(ra) # 80002de4 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002f42:	864a                	mv	a2,s2
    80002f44:	85a6                	mv	a1,s1
    80002f46:	00000097          	auipc	ra,0x0
    80002f4a:	f58080e7          	jalr	-168(ra) # 80002e9e <fetchstr>
}
    80002f4e:	60e2                	ld	ra,24(sp)
    80002f50:	6442                	ld	s0,16(sp)
    80002f52:	64a2                	ld	s1,8(sp)
    80002f54:	6902                	ld	s2,0(sp)
    80002f56:	6105                	addi	sp,sp,32
    80002f58:	8082                	ret

0000000080002f5a <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002f5a:	1101                	addi	sp,sp,-32
    80002f5c:	ec06                	sd	ra,24(sp)
    80002f5e:	e822                	sd	s0,16(sp)
    80002f60:	e426                	sd	s1,8(sp)
    80002f62:	e04a                	sd	s2,0(sp)
    80002f64:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f66:	fffff097          	auipc	ra,0xfffff
    80002f6a:	ec4080e7          	jalr	-316(ra) # 80001e2a <myproc>
    80002f6e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f70:	06053903          	ld	s2,96(a0)
    80002f74:	0a893783          	ld	a5,168(s2)
    80002f78:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f7c:	37fd                	addiw	a5,a5,-1
    80002f7e:	4751                	li	a4,20
    80002f80:	00f76f63          	bltu	a4,a5,80002f9e <syscall+0x44>
    80002f84:	00369713          	slli	a4,a3,0x3
    80002f88:	00005797          	auipc	a5,0x5
    80002f8c:	53078793          	addi	a5,a5,1328 # 800084b8 <syscalls>
    80002f90:	97ba                	add	a5,a5,a4
    80002f92:	639c                	ld	a5,0(a5)
    80002f94:	c789                	beqz	a5,80002f9e <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002f96:	9782                	jalr	a5
    80002f98:	06a93823          	sd	a0,112(s2)
    80002f9c:	a839                	j	80002fba <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f9e:	16048613          	addi	a2,s1,352
    80002fa2:	40ac                	lw	a1,64(s1)
    80002fa4:	00005517          	auipc	a0,0x5
    80002fa8:	4dc50513          	addi	a0,a0,1244 # 80008480 <states.1712+0x148>
    80002fac:	ffffd097          	auipc	ra,0xffffd
    80002fb0:	5ee080e7          	jalr	1518(ra) # 8000059a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002fb4:	70bc                	ld	a5,96(s1)
    80002fb6:	577d                	li	a4,-1
    80002fb8:	fbb8                	sd	a4,112(a5)
  }
}
    80002fba:	60e2                	ld	ra,24(sp)
    80002fbc:	6442                	ld	s0,16(sp)
    80002fbe:	64a2                	ld	s1,8(sp)
    80002fc0:	6902                	ld	s2,0(sp)
    80002fc2:	6105                	addi	sp,sp,32
    80002fc4:	8082                	ret

0000000080002fc6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002fc6:	1101                	addi	sp,sp,-32
    80002fc8:	ec06                	sd	ra,24(sp)
    80002fca:	e822                	sd	s0,16(sp)
    80002fcc:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002fce:	fec40593          	addi	a1,s0,-20
    80002fd2:	4501                	li	a0,0
    80002fd4:	00000097          	auipc	ra,0x0
    80002fd8:	f12080e7          	jalr	-238(ra) # 80002ee6 <argint>
    return -1;
    80002fdc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002fde:	00054963          	bltz	a0,80002ff0 <sys_exit+0x2a>
  exit(n);
    80002fe2:	fec42503          	lw	a0,-20(s0)
    80002fe6:	fffff097          	auipc	ra,0xfffff
    80002fea:	50e080e7          	jalr	1294(ra) # 800024f4 <exit>
  return 0;  // not reached
    80002fee:	4781                	li	a5,0
}
    80002ff0:	853e                	mv	a0,a5
    80002ff2:	60e2                	ld	ra,24(sp)
    80002ff4:	6442                	ld	s0,16(sp)
    80002ff6:	6105                	addi	sp,sp,32
    80002ff8:	8082                	ret

0000000080002ffa <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ffa:	1141                	addi	sp,sp,-16
    80002ffc:	e406                	sd	ra,8(sp)
    80002ffe:	e022                	sd	s0,0(sp)
    80003000:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003002:	fffff097          	auipc	ra,0xfffff
    80003006:	e28080e7          	jalr	-472(ra) # 80001e2a <myproc>
}
    8000300a:	4128                	lw	a0,64(a0)
    8000300c:	60a2                	ld	ra,8(sp)
    8000300e:	6402                	ld	s0,0(sp)
    80003010:	0141                	addi	sp,sp,16
    80003012:	8082                	ret

0000000080003014 <sys_fork>:

uint64
sys_fork(void)
{
    80003014:	1141                	addi	sp,sp,-16
    80003016:	e406                	sd	ra,8(sp)
    80003018:	e022                	sd	s0,0(sp)
    8000301a:	0800                	addi	s0,sp,16
  return fork();
    8000301c:	fffff097          	auipc	ra,0xfffff
    80003020:	1ce080e7          	jalr	462(ra) # 800021ea <fork>
}
    80003024:	60a2                	ld	ra,8(sp)
    80003026:	6402                	ld	s0,0(sp)
    80003028:	0141                	addi	sp,sp,16
    8000302a:	8082                	ret

000000008000302c <sys_wait>:

uint64
sys_wait(void)
{
    8000302c:	1101                	addi	sp,sp,-32
    8000302e:	ec06                	sd	ra,24(sp)
    80003030:	e822                	sd	s0,16(sp)
    80003032:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003034:	fe840593          	addi	a1,s0,-24
    80003038:	4501                	li	a0,0
    8000303a:	00000097          	auipc	ra,0x0
    8000303e:	ece080e7          	jalr	-306(ra) # 80002f08 <argaddr>
    80003042:	87aa                	mv	a5,a0
    return -1;
    80003044:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003046:	0007c863          	bltz	a5,80003056 <sys_wait+0x2a>
  return wait(p);
    8000304a:	fe843503          	ld	a0,-24(s0)
    8000304e:	fffff097          	auipc	ra,0xfffff
    80003052:	66a080e7          	jalr	1642(ra) # 800026b8 <wait>
}
    80003056:	60e2                	ld	ra,24(sp)
    80003058:	6442                	ld	s0,16(sp)
    8000305a:	6105                	addi	sp,sp,32
    8000305c:	8082                	ret

000000008000305e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000305e:	7179                	addi	sp,sp,-48
    80003060:	f406                	sd	ra,40(sp)
    80003062:	f022                	sd	s0,32(sp)
    80003064:	ec26                	sd	s1,24(sp)
    80003066:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003068:	fdc40593          	addi	a1,s0,-36
    8000306c:	4501                	li	a0,0
    8000306e:	00000097          	auipc	ra,0x0
    80003072:	e78080e7          	jalr	-392(ra) # 80002ee6 <argint>
    80003076:	87aa                	mv	a5,a0
    return -1;
    80003078:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    8000307a:	0207c063          	bltz	a5,8000309a <sys_sbrk+0x3c>
  addr = myproc()->sz;
    8000307e:	fffff097          	auipc	ra,0xfffff
    80003082:	dac080e7          	jalr	-596(ra) # 80001e2a <myproc>
    80003086:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80003088:	fdc42503          	lw	a0,-36(s0)
    8000308c:	fffff097          	auipc	ra,0xfffff
    80003090:	0ea080e7          	jalr	234(ra) # 80002176 <growproc>
    80003094:	00054863          	bltz	a0,800030a4 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003098:	8526                	mv	a0,s1
}
    8000309a:	70a2                	ld	ra,40(sp)
    8000309c:	7402                	ld	s0,32(sp)
    8000309e:	64e2                	ld	s1,24(sp)
    800030a0:	6145                	addi	sp,sp,48
    800030a2:	8082                	ret
    return -1;
    800030a4:	557d                	li	a0,-1
    800030a6:	bfd5                	j	8000309a <sys_sbrk+0x3c>

00000000800030a8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800030a8:	7139                	addi	sp,sp,-64
    800030aa:	fc06                	sd	ra,56(sp)
    800030ac:	f822                	sd	s0,48(sp)
    800030ae:	f426                	sd	s1,40(sp)
    800030b0:	f04a                	sd	s2,32(sp)
    800030b2:	ec4e                	sd	s3,24(sp)
    800030b4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800030b6:	fcc40593          	addi	a1,s0,-52
    800030ba:	4501                	li	a0,0
    800030bc:	00000097          	auipc	ra,0x0
    800030c0:	e2a080e7          	jalr	-470(ra) # 80002ee6 <argint>
    return -1;
    800030c4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800030c6:	06054563          	bltz	a0,80003130 <sys_sleep+0x88>
  acquire(&tickslock);
    800030ca:	00015517          	auipc	a0,0x15
    800030ce:	2de50513          	addi	a0,a0,734 # 800183a8 <tickslock>
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	d10080e7          	jalr	-752(ra) # 80000de2 <acquire>
  ticks0 = ticks;
    800030da:	00006917          	auipc	s2,0x6
    800030de:	f4692903          	lw	s2,-186(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    800030e2:	fcc42783          	lw	a5,-52(s0)
    800030e6:	cf85                	beqz	a5,8000311e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800030e8:	00015997          	auipc	s3,0x15
    800030ec:	2c098993          	addi	s3,s3,704 # 800183a8 <tickslock>
    800030f0:	00006497          	auipc	s1,0x6
    800030f4:	f3048493          	addi	s1,s1,-208 # 80009020 <ticks>
    if(myproc()->killed){
    800030f8:	fffff097          	auipc	ra,0xfffff
    800030fc:	d32080e7          	jalr	-718(ra) # 80001e2a <myproc>
    80003100:	5d1c                	lw	a5,56(a0)
    80003102:	ef9d                	bnez	a5,80003140 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003104:	85ce                	mv	a1,s3
    80003106:	8526                	mv	a0,s1
    80003108:	fffff097          	auipc	ra,0xfffff
    8000310c:	532080e7          	jalr	1330(ra) # 8000263a <sleep>
  while(ticks - ticks0 < n){
    80003110:	409c                	lw	a5,0(s1)
    80003112:	412787bb          	subw	a5,a5,s2
    80003116:	fcc42703          	lw	a4,-52(s0)
    8000311a:	fce7efe3          	bltu	a5,a4,800030f8 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000311e:	00015517          	auipc	a0,0x15
    80003122:	28a50513          	addi	a0,a0,650 # 800183a8 <tickslock>
    80003126:	ffffe097          	auipc	ra,0xffffe
    8000312a:	d8c080e7          	jalr	-628(ra) # 80000eb2 <release>
  return 0;
    8000312e:	4781                	li	a5,0
}
    80003130:	853e                	mv	a0,a5
    80003132:	70e2                	ld	ra,56(sp)
    80003134:	7442                	ld	s0,48(sp)
    80003136:	74a2                	ld	s1,40(sp)
    80003138:	7902                	ld	s2,32(sp)
    8000313a:	69e2                	ld	s3,24(sp)
    8000313c:	6121                	addi	sp,sp,64
    8000313e:	8082                	ret
      release(&tickslock);
    80003140:	00015517          	auipc	a0,0x15
    80003144:	26850513          	addi	a0,a0,616 # 800183a8 <tickslock>
    80003148:	ffffe097          	auipc	ra,0xffffe
    8000314c:	d6a080e7          	jalr	-662(ra) # 80000eb2 <release>
      return -1;
    80003150:	57fd                	li	a5,-1
    80003152:	bff9                	j	80003130 <sys_sleep+0x88>

0000000080003154 <sys_kill>:

uint64
sys_kill(void)
{
    80003154:	1101                	addi	sp,sp,-32
    80003156:	ec06                	sd	ra,24(sp)
    80003158:	e822                	sd	s0,16(sp)
    8000315a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000315c:	fec40593          	addi	a1,s0,-20
    80003160:	4501                	li	a0,0
    80003162:	00000097          	auipc	ra,0x0
    80003166:	d84080e7          	jalr	-636(ra) # 80002ee6 <argint>
    8000316a:	87aa                	mv	a5,a0
    return -1;
    8000316c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000316e:	0007c863          	bltz	a5,8000317e <sys_kill+0x2a>
  return kill(pid);
    80003172:	fec42503          	lw	a0,-20(s0)
    80003176:	fffff097          	auipc	ra,0xfffff
    8000317a:	6b4080e7          	jalr	1716(ra) # 8000282a <kill>
}
    8000317e:	60e2                	ld	ra,24(sp)
    80003180:	6442                	ld	s0,16(sp)
    80003182:	6105                	addi	sp,sp,32
    80003184:	8082                	ret

0000000080003186 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003186:	1101                	addi	sp,sp,-32
    80003188:	ec06                	sd	ra,24(sp)
    8000318a:	e822                	sd	s0,16(sp)
    8000318c:	e426                	sd	s1,8(sp)
    8000318e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003190:	00015517          	auipc	a0,0x15
    80003194:	21850513          	addi	a0,a0,536 # 800183a8 <tickslock>
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	c4a080e7          	jalr	-950(ra) # 80000de2 <acquire>
  xticks = ticks;
    800031a0:	00006497          	auipc	s1,0x6
    800031a4:	e804a483          	lw	s1,-384(s1) # 80009020 <ticks>
  release(&tickslock);
    800031a8:	00015517          	auipc	a0,0x15
    800031ac:	20050513          	addi	a0,a0,512 # 800183a8 <tickslock>
    800031b0:	ffffe097          	auipc	ra,0xffffe
    800031b4:	d02080e7          	jalr	-766(ra) # 80000eb2 <release>
  return xticks;
}
    800031b8:	02049513          	slli	a0,s1,0x20
    800031bc:	9101                	srli	a0,a0,0x20
    800031be:	60e2                	ld	ra,24(sp)
    800031c0:	6442                	ld	s0,16(sp)
    800031c2:	64a2                	ld	s1,8(sp)
    800031c4:	6105                	addi	sp,sp,32
    800031c6:	8082                	ret

00000000800031c8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800031c8:	7179                	addi	sp,sp,-48
    800031ca:	f406                	sd	ra,40(sp)
    800031cc:	f022                	sd	s0,32(sp)
    800031ce:	ec26                	sd	s1,24(sp)
    800031d0:	e84a                	sd	s2,16(sp)
    800031d2:	e44e                	sd	s3,8(sp)
    800031d4:	e052                	sd	s4,0(sp)
    800031d6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800031d8:	00005597          	auipc	a1,0x5
    800031dc:	f2858593          	addi	a1,a1,-216 # 80008100 <digits+0xc0>
    800031e0:	00015517          	auipc	a0,0x15
    800031e4:	1e850513          	addi	a0,a0,488 # 800183c8 <bcache>
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	d76080e7          	jalr	-650(ra) # 80000f5e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800031f0:	0001d797          	auipc	a5,0x1d
    800031f4:	1d878793          	addi	a5,a5,472 # 800203c8 <bcache+0x8000>
    800031f8:	0001d717          	auipc	a4,0x1d
    800031fc:	53070713          	addi	a4,a4,1328 # 80020728 <bcache+0x8360>
    80003200:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80003204:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003208:	00015497          	auipc	s1,0x15
    8000320c:	1e048493          	addi	s1,s1,480 # 800183e8 <bcache+0x20>
    b->next = bcache.head.next;
    80003210:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003212:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003214:	00005a17          	auipc	s4,0x5
    80003218:	354a0a13          	addi	s4,s4,852 # 80008568 <syscalls+0xb0>
    b->next = bcache.head.next;
    8000321c:	3b893783          	ld	a5,952(s2)
    80003220:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80003222:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80003226:	85d2                	mv	a1,s4
    80003228:	01048513          	addi	a0,s1,16
    8000322c:	00001097          	auipc	ra,0x1
    80003230:	4c2080e7          	jalr	1218(ra) # 800046ee <initsleeplock>
    bcache.head.next->prev = b;
    80003234:	3b893783          	ld	a5,952(s2)
    80003238:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    8000323a:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000323e:	46048493          	addi	s1,s1,1120
    80003242:	fd349de3          	bne	s1,s3,8000321c <binit+0x54>
  }
}
    80003246:	70a2                	ld	ra,40(sp)
    80003248:	7402                	ld	s0,32(sp)
    8000324a:	64e2                	ld	s1,24(sp)
    8000324c:	6942                	ld	s2,16(sp)
    8000324e:	69a2                	ld	s3,8(sp)
    80003250:	6a02                	ld	s4,0(sp)
    80003252:	6145                	addi	sp,sp,48
    80003254:	8082                	ret

0000000080003256 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003256:	7179                	addi	sp,sp,-48
    80003258:	f406                	sd	ra,40(sp)
    8000325a:	f022                	sd	s0,32(sp)
    8000325c:	ec26                	sd	s1,24(sp)
    8000325e:	e84a                	sd	s2,16(sp)
    80003260:	e44e                	sd	s3,8(sp)
    80003262:	1800                	addi	s0,sp,48
    80003264:	89aa                	mv	s3,a0
    80003266:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003268:	00015517          	auipc	a0,0x15
    8000326c:	16050513          	addi	a0,a0,352 # 800183c8 <bcache>
    80003270:	ffffe097          	auipc	ra,0xffffe
    80003274:	b72080e7          	jalr	-1166(ra) # 80000de2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003278:	0001d497          	auipc	s1,0x1d
    8000327c:	5084b483          	ld	s1,1288(s1) # 80020780 <bcache+0x83b8>
    80003280:	0001d797          	auipc	a5,0x1d
    80003284:	4a878793          	addi	a5,a5,1192 # 80020728 <bcache+0x8360>
    80003288:	02f48f63          	beq	s1,a5,800032c6 <bread+0x70>
    8000328c:	873e                	mv	a4,a5
    8000328e:	a021                	j	80003296 <bread+0x40>
    80003290:	6ca4                	ld	s1,88(s1)
    80003292:	02e48a63          	beq	s1,a4,800032c6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003296:	449c                	lw	a5,8(s1)
    80003298:	ff379ce3          	bne	a5,s3,80003290 <bread+0x3a>
    8000329c:	44dc                	lw	a5,12(s1)
    8000329e:	ff2799e3          	bne	a5,s2,80003290 <bread+0x3a>
      b->refcnt++;
    800032a2:	44bc                	lw	a5,72(s1)
    800032a4:	2785                	addiw	a5,a5,1
    800032a6:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800032a8:	00015517          	auipc	a0,0x15
    800032ac:	12050513          	addi	a0,a0,288 # 800183c8 <bcache>
    800032b0:	ffffe097          	auipc	ra,0xffffe
    800032b4:	c02080e7          	jalr	-1022(ra) # 80000eb2 <release>
      acquiresleep(&b->lock);
    800032b8:	01048513          	addi	a0,s1,16
    800032bc:	00001097          	auipc	ra,0x1
    800032c0:	46c080e7          	jalr	1132(ra) # 80004728 <acquiresleep>
      return b;
    800032c4:	a8b9                	j	80003322 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032c6:	0001d497          	auipc	s1,0x1d
    800032ca:	4b24b483          	ld	s1,1202(s1) # 80020778 <bcache+0x83b0>
    800032ce:	0001d797          	auipc	a5,0x1d
    800032d2:	45a78793          	addi	a5,a5,1114 # 80020728 <bcache+0x8360>
    800032d6:	00f48863          	beq	s1,a5,800032e6 <bread+0x90>
    800032da:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800032dc:	44bc                	lw	a5,72(s1)
    800032de:	cf81                	beqz	a5,800032f6 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032e0:	68a4                	ld	s1,80(s1)
    800032e2:	fee49de3          	bne	s1,a4,800032dc <bread+0x86>
  panic("bget: no buffers");
    800032e6:	00005517          	auipc	a0,0x5
    800032ea:	28a50513          	addi	a0,a0,650 # 80008570 <syscalls+0xb8>
    800032ee:	ffffd097          	auipc	ra,0xffffd
    800032f2:	262080e7          	jalr	610(ra) # 80000550 <panic>
      b->dev = dev;
    800032f6:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800032fa:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800032fe:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003302:	4785                	li	a5,1
    80003304:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80003306:	00015517          	auipc	a0,0x15
    8000330a:	0c250513          	addi	a0,a0,194 # 800183c8 <bcache>
    8000330e:	ffffe097          	auipc	ra,0xffffe
    80003312:	ba4080e7          	jalr	-1116(ra) # 80000eb2 <release>
      acquiresleep(&b->lock);
    80003316:	01048513          	addi	a0,s1,16
    8000331a:	00001097          	auipc	ra,0x1
    8000331e:	40e080e7          	jalr	1038(ra) # 80004728 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003322:	409c                	lw	a5,0(s1)
    80003324:	cb89                	beqz	a5,80003336 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003326:	8526                	mv	a0,s1
    80003328:	70a2                	ld	ra,40(sp)
    8000332a:	7402                	ld	s0,32(sp)
    8000332c:	64e2                	ld	s1,24(sp)
    8000332e:	6942                	ld	s2,16(sp)
    80003330:	69a2                	ld	s3,8(sp)
    80003332:	6145                	addi	sp,sp,48
    80003334:	8082                	ret
    virtio_disk_rw(b, 0);
    80003336:	4581                	li	a1,0
    80003338:	8526                	mv	a0,s1
    8000333a:	00003097          	auipc	ra,0x3
    8000333e:	f6c080e7          	jalr	-148(ra) # 800062a6 <virtio_disk_rw>
    b->valid = 1;
    80003342:	4785                	li	a5,1
    80003344:	c09c                	sw	a5,0(s1)
  return b;
    80003346:	b7c5                	j	80003326 <bread+0xd0>

0000000080003348 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	e426                	sd	s1,8(sp)
    80003350:	1000                	addi	s0,sp,32
    80003352:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003354:	0541                	addi	a0,a0,16
    80003356:	00001097          	auipc	ra,0x1
    8000335a:	46c080e7          	jalr	1132(ra) # 800047c2 <holdingsleep>
    8000335e:	cd01                	beqz	a0,80003376 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003360:	4585                	li	a1,1
    80003362:	8526                	mv	a0,s1
    80003364:	00003097          	auipc	ra,0x3
    80003368:	f42080e7          	jalr	-190(ra) # 800062a6 <virtio_disk_rw>
}
    8000336c:	60e2                	ld	ra,24(sp)
    8000336e:	6442                	ld	s0,16(sp)
    80003370:	64a2                	ld	s1,8(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret
    panic("bwrite");
    80003376:	00005517          	auipc	a0,0x5
    8000337a:	21250513          	addi	a0,a0,530 # 80008588 <syscalls+0xd0>
    8000337e:	ffffd097          	auipc	ra,0xffffd
    80003382:	1d2080e7          	jalr	466(ra) # 80000550 <panic>

0000000080003386 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003386:	1101                	addi	sp,sp,-32
    80003388:	ec06                	sd	ra,24(sp)
    8000338a:	e822                	sd	s0,16(sp)
    8000338c:	e426                	sd	s1,8(sp)
    8000338e:	e04a                	sd	s2,0(sp)
    80003390:	1000                	addi	s0,sp,32
    80003392:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003394:	01050913          	addi	s2,a0,16
    80003398:	854a                	mv	a0,s2
    8000339a:	00001097          	auipc	ra,0x1
    8000339e:	428080e7          	jalr	1064(ra) # 800047c2 <holdingsleep>
    800033a2:	c92d                	beqz	a0,80003414 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800033a4:	854a                	mv	a0,s2
    800033a6:	00001097          	auipc	ra,0x1
    800033aa:	3d8080e7          	jalr	984(ra) # 8000477e <releasesleep>

  acquire(&bcache.lock);
    800033ae:	00015517          	auipc	a0,0x15
    800033b2:	01a50513          	addi	a0,a0,26 # 800183c8 <bcache>
    800033b6:	ffffe097          	auipc	ra,0xffffe
    800033ba:	a2c080e7          	jalr	-1492(ra) # 80000de2 <acquire>
  b->refcnt--;
    800033be:	44bc                	lw	a5,72(s1)
    800033c0:	37fd                	addiw	a5,a5,-1
    800033c2:	0007871b          	sext.w	a4,a5
    800033c6:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    800033c8:	eb05                	bnez	a4,800033f8 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800033ca:	6cbc                	ld	a5,88(s1)
    800033cc:	68b8                	ld	a4,80(s1)
    800033ce:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    800033d0:	68bc                	ld	a5,80(s1)
    800033d2:	6cb8                	ld	a4,88(s1)
    800033d4:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    800033d6:	0001d797          	auipc	a5,0x1d
    800033da:	ff278793          	addi	a5,a5,-14 # 800203c8 <bcache+0x8000>
    800033de:	3b87b703          	ld	a4,952(a5)
    800033e2:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    800033e4:	0001d717          	auipc	a4,0x1d
    800033e8:	34470713          	addi	a4,a4,836 # 80020728 <bcache+0x8360>
    800033ec:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    800033ee:	3b87b703          	ld	a4,952(a5)
    800033f2:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    800033f4:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    800033f8:	00015517          	auipc	a0,0x15
    800033fc:	fd050513          	addi	a0,a0,-48 # 800183c8 <bcache>
    80003400:	ffffe097          	auipc	ra,0xffffe
    80003404:	ab2080e7          	jalr	-1358(ra) # 80000eb2 <release>
}
    80003408:	60e2                	ld	ra,24(sp)
    8000340a:	6442                	ld	s0,16(sp)
    8000340c:	64a2                	ld	s1,8(sp)
    8000340e:	6902                	ld	s2,0(sp)
    80003410:	6105                	addi	sp,sp,32
    80003412:	8082                	ret
    panic("brelse");
    80003414:	00005517          	auipc	a0,0x5
    80003418:	17c50513          	addi	a0,a0,380 # 80008590 <syscalls+0xd8>
    8000341c:	ffffd097          	auipc	ra,0xffffd
    80003420:	134080e7          	jalr	308(ra) # 80000550 <panic>

0000000080003424 <bpin>:

void
bpin(struct buf *b) {
    80003424:	1101                	addi	sp,sp,-32
    80003426:	ec06                	sd	ra,24(sp)
    80003428:	e822                	sd	s0,16(sp)
    8000342a:	e426                	sd	s1,8(sp)
    8000342c:	1000                	addi	s0,sp,32
    8000342e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003430:	00015517          	auipc	a0,0x15
    80003434:	f9850513          	addi	a0,a0,-104 # 800183c8 <bcache>
    80003438:	ffffe097          	auipc	ra,0xffffe
    8000343c:	9aa080e7          	jalr	-1622(ra) # 80000de2 <acquire>
  b->refcnt++;
    80003440:	44bc                	lw	a5,72(s1)
    80003442:	2785                	addiw	a5,a5,1
    80003444:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003446:	00015517          	auipc	a0,0x15
    8000344a:	f8250513          	addi	a0,a0,-126 # 800183c8 <bcache>
    8000344e:	ffffe097          	auipc	ra,0xffffe
    80003452:	a64080e7          	jalr	-1436(ra) # 80000eb2 <release>
}
    80003456:	60e2                	ld	ra,24(sp)
    80003458:	6442                	ld	s0,16(sp)
    8000345a:	64a2                	ld	s1,8(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret

0000000080003460 <bunpin>:

void
bunpin(struct buf *b) {
    80003460:	1101                	addi	sp,sp,-32
    80003462:	ec06                	sd	ra,24(sp)
    80003464:	e822                	sd	s0,16(sp)
    80003466:	e426                	sd	s1,8(sp)
    80003468:	1000                	addi	s0,sp,32
    8000346a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000346c:	00015517          	auipc	a0,0x15
    80003470:	f5c50513          	addi	a0,a0,-164 # 800183c8 <bcache>
    80003474:	ffffe097          	auipc	ra,0xffffe
    80003478:	96e080e7          	jalr	-1682(ra) # 80000de2 <acquire>
  b->refcnt--;
    8000347c:	44bc                	lw	a5,72(s1)
    8000347e:	37fd                	addiw	a5,a5,-1
    80003480:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003482:	00015517          	auipc	a0,0x15
    80003486:	f4650513          	addi	a0,a0,-186 # 800183c8 <bcache>
    8000348a:	ffffe097          	auipc	ra,0xffffe
    8000348e:	a28080e7          	jalr	-1496(ra) # 80000eb2 <release>
}
    80003492:	60e2                	ld	ra,24(sp)
    80003494:	6442                	ld	s0,16(sp)
    80003496:	64a2                	ld	s1,8(sp)
    80003498:	6105                	addi	sp,sp,32
    8000349a:	8082                	ret

000000008000349c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000349c:	1101                	addi	sp,sp,-32
    8000349e:	ec06                	sd	ra,24(sp)
    800034a0:	e822                	sd	s0,16(sp)
    800034a2:	e426                	sd	s1,8(sp)
    800034a4:	e04a                	sd	s2,0(sp)
    800034a6:	1000                	addi	s0,sp,32
    800034a8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800034aa:	00d5d59b          	srliw	a1,a1,0xd
    800034ae:	0001d797          	auipc	a5,0x1d
    800034b2:	6f67a783          	lw	a5,1782(a5) # 80020ba4 <sb+0x1c>
    800034b6:	9dbd                	addw	a1,a1,a5
    800034b8:	00000097          	auipc	ra,0x0
    800034bc:	d9e080e7          	jalr	-610(ra) # 80003256 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800034c0:	0074f713          	andi	a4,s1,7
    800034c4:	4785                	li	a5,1
    800034c6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800034ca:	14ce                	slli	s1,s1,0x33
    800034cc:	90d9                	srli	s1,s1,0x36
    800034ce:	00950733          	add	a4,a0,s1
    800034d2:	06074703          	lbu	a4,96(a4)
    800034d6:	00e7f6b3          	and	a3,a5,a4
    800034da:	c69d                	beqz	a3,80003508 <bfree+0x6c>
    800034dc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800034de:	94aa                	add	s1,s1,a0
    800034e0:	fff7c793          	not	a5,a5
    800034e4:	8ff9                	and	a5,a5,a4
    800034e6:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800034ea:	00001097          	auipc	ra,0x1
    800034ee:	116080e7          	jalr	278(ra) # 80004600 <log_write>
  brelse(bp);
    800034f2:	854a                	mv	a0,s2
    800034f4:	00000097          	auipc	ra,0x0
    800034f8:	e92080e7          	jalr	-366(ra) # 80003386 <brelse>
}
    800034fc:	60e2                	ld	ra,24(sp)
    800034fe:	6442                	ld	s0,16(sp)
    80003500:	64a2                	ld	s1,8(sp)
    80003502:	6902                	ld	s2,0(sp)
    80003504:	6105                	addi	sp,sp,32
    80003506:	8082                	ret
    panic("freeing free block");
    80003508:	00005517          	auipc	a0,0x5
    8000350c:	09050513          	addi	a0,a0,144 # 80008598 <syscalls+0xe0>
    80003510:	ffffd097          	auipc	ra,0xffffd
    80003514:	040080e7          	jalr	64(ra) # 80000550 <panic>

0000000080003518 <balloc>:
{
    80003518:	711d                	addi	sp,sp,-96
    8000351a:	ec86                	sd	ra,88(sp)
    8000351c:	e8a2                	sd	s0,80(sp)
    8000351e:	e4a6                	sd	s1,72(sp)
    80003520:	e0ca                	sd	s2,64(sp)
    80003522:	fc4e                	sd	s3,56(sp)
    80003524:	f852                	sd	s4,48(sp)
    80003526:	f456                	sd	s5,40(sp)
    80003528:	f05a                	sd	s6,32(sp)
    8000352a:	ec5e                	sd	s7,24(sp)
    8000352c:	e862                	sd	s8,16(sp)
    8000352e:	e466                	sd	s9,8(sp)
    80003530:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003532:	0001d797          	auipc	a5,0x1d
    80003536:	65a7a783          	lw	a5,1626(a5) # 80020b8c <sb+0x4>
    8000353a:	cbd1                	beqz	a5,800035ce <balloc+0xb6>
    8000353c:	8baa                	mv	s7,a0
    8000353e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003540:	0001db17          	auipc	s6,0x1d
    80003544:	648b0b13          	addi	s6,s6,1608 # 80020b88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003548:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000354a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000354c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000354e:	6c89                	lui	s9,0x2
    80003550:	a831                	j	8000356c <balloc+0x54>
    brelse(bp);
    80003552:	854a                	mv	a0,s2
    80003554:	00000097          	auipc	ra,0x0
    80003558:	e32080e7          	jalr	-462(ra) # 80003386 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000355c:	015c87bb          	addw	a5,s9,s5
    80003560:	00078a9b          	sext.w	s5,a5
    80003564:	004b2703          	lw	a4,4(s6)
    80003568:	06eaf363          	bgeu	s5,a4,800035ce <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000356c:	41fad79b          	sraiw	a5,s5,0x1f
    80003570:	0137d79b          	srliw	a5,a5,0x13
    80003574:	015787bb          	addw	a5,a5,s5
    80003578:	40d7d79b          	sraiw	a5,a5,0xd
    8000357c:	01cb2583          	lw	a1,28(s6)
    80003580:	9dbd                	addw	a1,a1,a5
    80003582:	855e                	mv	a0,s7
    80003584:	00000097          	auipc	ra,0x0
    80003588:	cd2080e7          	jalr	-814(ra) # 80003256 <bread>
    8000358c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000358e:	004b2503          	lw	a0,4(s6)
    80003592:	000a849b          	sext.w	s1,s5
    80003596:	8662                	mv	a2,s8
    80003598:	faa4fde3          	bgeu	s1,a0,80003552 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000359c:	41f6579b          	sraiw	a5,a2,0x1f
    800035a0:	01d7d69b          	srliw	a3,a5,0x1d
    800035a4:	00c6873b          	addw	a4,a3,a2
    800035a8:	00777793          	andi	a5,a4,7
    800035ac:	9f95                	subw	a5,a5,a3
    800035ae:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800035b2:	4037571b          	sraiw	a4,a4,0x3
    800035b6:	00e906b3          	add	a3,s2,a4
    800035ba:	0606c683          	lbu	a3,96(a3)
    800035be:	00d7f5b3          	and	a1,a5,a3
    800035c2:	cd91                	beqz	a1,800035de <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035c4:	2605                	addiw	a2,a2,1
    800035c6:	2485                	addiw	s1,s1,1
    800035c8:	fd4618e3          	bne	a2,s4,80003598 <balloc+0x80>
    800035cc:	b759                	j	80003552 <balloc+0x3a>
  panic("balloc: out of blocks");
    800035ce:	00005517          	auipc	a0,0x5
    800035d2:	fe250513          	addi	a0,a0,-30 # 800085b0 <syscalls+0xf8>
    800035d6:	ffffd097          	auipc	ra,0xffffd
    800035da:	f7a080e7          	jalr	-134(ra) # 80000550 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800035de:	974a                	add	a4,a4,s2
    800035e0:	8fd5                	or	a5,a5,a3
    800035e2:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800035e6:	854a                	mv	a0,s2
    800035e8:	00001097          	auipc	ra,0x1
    800035ec:	018080e7          	jalr	24(ra) # 80004600 <log_write>
        brelse(bp);
    800035f0:	854a                	mv	a0,s2
    800035f2:	00000097          	auipc	ra,0x0
    800035f6:	d94080e7          	jalr	-620(ra) # 80003386 <brelse>
  bp = bread(dev, bno);
    800035fa:	85a6                	mv	a1,s1
    800035fc:	855e                	mv	a0,s7
    800035fe:	00000097          	auipc	ra,0x0
    80003602:	c58080e7          	jalr	-936(ra) # 80003256 <bread>
    80003606:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003608:	40000613          	li	a2,1024
    8000360c:	4581                	li	a1,0
    8000360e:	06050513          	addi	a0,a0,96
    80003612:	ffffe097          	auipc	ra,0xffffe
    80003616:	bb0080e7          	jalr	-1104(ra) # 800011c2 <memset>
  log_write(bp);
    8000361a:	854a                	mv	a0,s2
    8000361c:	00001097          	auipc	ra,0x1
    80003620:	fe4080e7          	jalr	-28(ra) # 80004600 <log_write>
  brelse(bp);
    80003624:	854a                	mv	a0,s2
    80003626:	00000097          	auipc	ra,0x0
    8000362a:	d60080e7          	jalr	-672(ra) # 80003386 <brelse>
}
    8000362e:	8526                	mv	a0,s1
    80003630:	60e6                	ld	ra,88(sp)
    80003632:	6446                	ld	s0,80(sp)
    80003634:	64a6                	ld	s1,72(sp)
    80003636:	6906                	ld	s2,64(sp)
    80003638:	79e2                	ld	s3,56(sp)
    8000363a:	7a42                	ld	s4,48(sp)
    8000363c:	7aa2                	ld	s5,40(sp)
    8000363e:	7b02                	ld	s6,32(sp)
    80003640:	6be2                	ld	s7,24(sp)
    80003642:	6c42                	ld	s8,16(sp)
    80003644:	6ca2                	ld	s9,8(sp)
    80003646:	6125                	addi	sp,sp,96
    80003648:	8082                	ret

000000008000364a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000364a:	7179                	addi	sp,sp,-48
    8000364c:	f406                	sd	ra,40(sp)
    8000364e:	f022                	sd	s0,32(sp)
    80003650:	ec26                	sd	s1,24(sp)
    80003652:	e84a                	sd	s2,16(sp)
    80003654:	e44e                	sd	s3,8(sp)
    80003656:	e052                	sd	s4,0(sp)
    80003658:	1800                	addi	s0,sp,48
    8000365a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000365c:	47ad                	li	a5,11
    8000365e:	04b7fe63          	bgeu	a5,a1,800036ba <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003662:	ff45849b          	addiw	s1,a1,-12
    80003666:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000366a:	0ff00793          	li	a5,255
    8000366e:	0ae7e363          	bltu	a5,a4,80003714 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003672:	08852583          	lw	a1,136(a0)
    80003676:	c5ad                	beqz	a1,800036e0 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003678:	00092503          	lw	a0,0(s2)
    8000367c:	00000097          	auipc	ra,0x0
    80003680:	bda080e7          	jalr	-1062(ra) # 80003256 <bread>
    80003684:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003686:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    8000368a:	02049593          	slli	a1,s1,0x20
    8000368e:	9181                	srli	a1,a1,0x20
    80003690:	058a                	slli	a1,a1,0x2
    80003692:	00b784b3          	add	s1,a5,a1
    80003696:	0004a983          	lw	s3,0(s1)
    8000369a:	04098d63          	beqz	s3,800036f4 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000369e:	8552                	mv	a0,s4
    800036a0:	00000097          	auipc	ra,0x0
    800036a4:	ce6080e7          	jalr	-794(ra) # 80003386 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800036a8:	854e                	mv	a0,s3
    800036aa:	70a2                	ld	ra,40(sp)
    800036ac:	7402                	ld	s0,32(sp)
    800036ae:	64e2                	ld	s1,24(sp)
    800036b0:	6942                	ld	s2,16(sp)
    800036b2:	69a2                	ld	s3,8(sp)
    800036b4:	6a02                	ld	s4,0(sp)
    800036b6:	6145                	addi	sp,sp,48
    800036b8:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800036ba:	02059493          	slli	s1,a1,0x20
    800036be:	9081                	srli	s1,s1,0x20
    800036c0:	048a                	slli	s1,s1,0x2
    800036c2:	94aa                	add	s1,s1,a0
    800036c4:	0584a983          	lw	s3,88(s1)
    800036c8:	fe0990e3          	bnez	s3,800036a8 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800036cc:	4108                	lw	a0,0(a0)
    800036ce:	00000097          	auipc	ra,0x0
    800036d2:	e4a080e7          	jalr	-438(ra) # 80003518 <balloc>
    800036d6:	0005099b          	sext.w	s3,a0
    800036da:	0534ac23          	sw	s3,88(s1)
    800036de:	b7e9                	j	800036a8 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800036e0:	4108                	lw	a0,0(a0)
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	e36080e7          	jalr	-458(ra) # 80003518 <balloc>
    800036ea:	0005059b          	sext.w	a1,a0
    800036ee:	08b92423          	sw	a1,136(s2)
    800036f2:	b759                	j	80003678 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800036f4:	00092503          	lw	a0,0(s2)
    800036f8:	00000097          	auipc	ra,0x0
    800036fc:	e20080e7          	jalr	-480(ra) # 80003518 <balloc>
    80003700:	0005099b          	sext.w	s3,a0
    80003704:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003708:	8552                	mv	a0,s4
    8000370a:	00001097          	auipc	ra,0x1
    8000370e:	ef6080e7          	jalr	-266(ra) # 80004600 <log_write>
    80003712:	b771                	j	8000369e <bmap+0x54>
  panic("bmap: out of range");
    80003714:	00005517          	auipc	a0,0x5
    80003718:	eb450513          	addi	a0,a0,-332 # 800085c8 <syscalls+0x110>
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	e34080e7          	jalr	-460(ra) # 80000550 <panic>

0000000080003724 <iget>:
{
    80003724:	7179                	addi	sp,sp,-48
    80003726:	f406                	sd	ra,40(sp)
    80003728:	f022                	sd	s0,32(sp)
    8000372a:	ec26                	sd	s1,24(sp)
    8000372c:	e84a                	sd	s2,16(sp)
    8000372e:	e44e                	sd	s3,8(sp)
    80003730:	e052                	sd	s4,0(sp)
    80003732:	1800                	addi	s0,sp,48
    80003734:	89aa                	mv	s3,a0
    80003736:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003738:	0001d517          	auipc	a0,0x1d
    8000373c:	47050513          	addi	a0,a0,1136 # 80020ba8 <icache>
    80003740:	ffffd097          	auipc	ra,0xffffd
    80003744:	6a2080e7          	jalr	1698(ra) # 80000de2 <acquire>
  empty = 0;
    80003748:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000374a:	0001d497          	auipc	s1,0x1d
    8000374e:	47e48493          	addi	s1,s1,1150 # 80020bc8 <icache+0x20>
    80003752:	0001f697          	auipc	a3,0x1f
    80003756:	09668693          	addi	a3,a3,150 # 800227e8 <log>
    8000375a:	a039                	j	80003768 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000375c:	02090b63          	beqz	s2,80003792 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003760:	09048493          	addi	s1,s1,144
    80003764:	02d48a63          	beq	s1,a3,80003798 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003768:	449c                	lw	a5,8(s1)
    8000376a:	fef059e3          	blez	a5,8000375c <iget+0x38>
    8000376e:	4098                	lw	a4,0(s1)
    80003770:	ff3716e3          	bne	a4,s3,8000375c <iget+0x38>
    80003774:	40d8                	lw	a4,4(s1)
    80003776:	ff4713e3          	bne	a4,s4,8000375c <iget+0x38>
      ip->ref++;
    8000377a:	2785                	addiw	a5,a5,1
    8000377c:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000377e:	0001d517          	auipc	a0,0x1d
    80003782:	42a50513          	addi	a0,a0,1066 # 80020ba8 <icache>
    80003786:	ffffd097          	auipc	ra,0xffffd
    8000378a:	72c080e7          	jalr	1836(ra) # 80000eb2 <release>
      return ip;
    8000378e:	8926                	mv	s2,s1
    80003790:	a03d                	j	800037be <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003792:	f7f9                	bnez	a5,80003760 <iget+0x3c>
    80003794:	8926                	mv	s2,s1
    80003796:	b7e9                	j	80003760 <iget+0x3c>
  if(empty == 0)
    80003798:	02090c63          	beqz	s2,800037d0 <iget+0xac>
  ip->dev = dev;
    8000379c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800037a0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800037a4:	4785                	li	a5,1
    800037a6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800037aa:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    800037ae:	0001d517          	auipc	a0,0x1d
    800037b2:	3fa50513          	addi	a0,a0,1018 # 80020ba8 <icache>
    800037b6:	ffffd097          	auipc	ra,0xffffd
    800037ba:	6fc080e7          	jalr	1788(ra) # 80000eb2 <release>
}
    800037be:	854a                	mv	a0,s2
    800037c0:	70a2                	ld	ra,40(sp)
    800037c2:	7402                	ld	s0,32(sp)
    800037c4:	64e2                	ld	s1,24(sp)
    800037c6:	6942                	ld	s2,16(sp)
    800037c8:	69a2                	ld	s3,8(sp)
    800037ca:	6a02                	ld	s4,0(sp)
    800037cc:	6145                	addi	sp,sp,48
    800037ce:	8082                	ret
    panic("iget: no inodes");
    800037d0:	00005517          	auipc	a0,0x5
    800037d4:	e1050513          	addi	a0,a0,-496 # 800085e0 <syscalls+0x128>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	d78080e7          	jalr	-648(ra) # 80000550 <panic>

00000000800037e0 <fsinit>:
fsinit(int dev) {
    800037e0:	7179                	addi	sp,sp,-48
    800037e2:	f406                	sd	ra,40(sp)
    800037e4:	f022                	sd	s0,32(sp)
    800037e6:	ec26                	sd	s1,24(sp)
    800037e8:	e84a                	sd	s2,16(sp)
    800037ea:	e44e                	sd	s3,8(sp)
    800037ec:	1800                	addi	s0,sp,48
    800037ee:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037f0:	4585                	li	a1,1
    800037f2:	00000097          	auipc	ra,0x0
    800037f6:	a64080e7          	jalr	-1436(ra) # 80003256 <bread>
    800037fa:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037fc:	0001d997          	auipc	s3,0x1d
    80003800:	38c98993          	addi	s3,s3,908 # 80020b88 <sb>
    80003804:	02000613          	li	a2,32
    80003808:	06050593          	addi	a1,a0,96
    8000380c:	854e                	mv	a0,s3
    8000380e:	ffffe097          	auipc	ra,0xffffe
    80003812:	a14080e7          	jalr	-1516(ra) # 80001222 <memmove>
  brelse(bp);
    80003816:	8526                	mv	a0,s1
    80003818:	00000097          	auipc	ra,0x0
    8000381c:	b6e080e7          	jalr	-1170(ra) # 80003386 <brelse>
  if(sb.magic != FSMAGIC)
    80003820:	0009a703          	lw	a4,0(s3)
    80003824:	102037b7          	lui	a5,0x10203
    80003828:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000382c:	02f71263          	bne	a4,a5,80003850 <fsinit+0x70>
  initlog(dev, &sb);
    80003830:	0001d597          	auipc	a1,0x1d
    80003834:	35858593          	addi	a1,a1,856 # 80020b88 <sb>
    80003838:	854a                	mv	a0,s2
    8000383a:	00001097          	auipc	ra,0x1
    8000383e:	b4a080e7          	jalr	-1206(ra) # 80004384 <initlog>
}
    80003842:	70a2                	ld	ra,40(sp)
    80003844:	7402                	ld	s0,32(sp)
    80003846:	64e2                	ld	s1,24(sp)
    80003848:	6942                	ld	s2,16(sp)
    8000384a:	69a2                	ld	s3,8(sp)
    8000384c:	6145                	addi	sp,sp,48
    8000384e:	8082                	ret
    panic("invalid file system");
    80003850:	00005517          	auipc	a0,0x5
    80003854:	da050513          	addi	a0,a0,-608 # 800085f0 <syscalls+0x138>
    80003858:	ffffd097          	auipc	ra,0xffffd
    8000385c:	cf8080e7          	jalr	-776(ra) # 80000550 <panic>

0000000080003860 <iinit>:
{
    80003860:	7179                	addi	sp,sp,-48
    80003862:	f406                	sd	ra,40(sp)
    80003864:	f022                	sd	s0,32(sp)
    80003866:	ec26                	sd	s1,24(sp)
    80003868:	e84a                	sd	s2,16(sp)
    8000386a:	e44e                	sd	s3,8(sp)
    8000386c:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000386e:	00005597          	auipc	a1,0x5
    80003872:	d9a58593          	addi	a1,a1,-614 # 80008608 <syscalls+0x150>
    80003876:	0001d517          	auipc	a0,0x1d
    8000387a:	33250513          	addi	a0,a0,818 # 80020ba8 <icache>
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	6e0080e7          	jalr	1760(ra) # 80000f5e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003886:	0001d497          	auipc	s1,0x1d
    8000388a:	35248493          	addi	s1,s1,850 # 80020bd8 <icache+0x30>
    8000388e:	0001f997          	auipc	s3,0x1f
    80003892:	f6a98993          	addi	s3,s3,-150 # 800227f8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003896:	00005917          	auipc	s2,0x5
    8000389a:	d7a90913          	addi	s2,s2,-646 # 80008610 <syscalls+0x158>
    8000389e:	85ca                	mv	a1,s2
    800038a0:	8526                	mv	a0,s1
    800038a2:	00001097          	auipc	ra,0x1
    800038a6:	e4c080e7          	jalr	-436(ra) # 800046ee <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800038aa:	09048493          	addi	s1,s1,144
    800038ae:	ff3498e3          	bne	s1,s3,8000389e <iinit+0x3e>
}
    800038b2:	70a2                	ld	ra,40(sp)
    800038b4:	7402                	ld	s0,32(sp)
    800038b6:	64e2                	ld	s1,24(sp)
    800038b8:	6942                	ld	s2,16(sp)
    800038ba:	69a2                	ld	s3,8(sp)
    800038bc:	6145                	addi	sp,sp,48
    800038be:	8082                	ret

00000000800038c0 <ialloc>:
{
    800038c0:	715d                	addi	sp,sp,-80
    800038c2:	e486                	sd	ra,72(sp)
    800038c4:	e0a2                	sd	s0,64(sp)
    800038c6:	fc26                	sd	s1,56(sp)
    800038c8:	f84a                	sd	s2,48(sp)
    800038ca:	f44e                	sd	s3,40(sp)
    800038cc:	f052                	sd	s4,32(sp)
    800038ce:	ec56                	sd	s5,24(sp)
    800038d0:	e85a                	sd	s6,16(sp)
    800038d2:	e45e                	sd	s7,8(sp)
    800038d4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800038d6:	0001d717          	auipc	a4,0x1d
    800038da:	2be72703          	lw	a4,702(a4) # 80020b94 <sb+0xc>
    800038de:	4785                	li	a5,1
    800038e0:	04e7fa63          	bgeu	a5,a4,80003934 <ialloc+0x74>
    800038e4:	8aaa                	mv	s5,a0
    800038e6:	8bae                	mv	s7,a1
    800038e8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800038ea:	0001da17          	auipc	s4,0x1d
    800038ee:	29ea0a13          	addi	s4,s4,670 # 80020b88 <sb>
    800038f2:	00048b1b          	sext.w	s6,s1
    800038f6:	0044d593          	srli	a1,s1,0x4
    800038fa:	018a2783          	lw	a5,24(s4)
    800038fe:	9dbd                	addw	a1,a1,a5
    80003900:	8556                	mv	a0,s5
    80003902:	00000097          	auipc	ra,0x0
    80003906:	954080e7          	jalr	-1708(ra) # 80003256 <bread>
    8000390a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000390c:	06050993          	addi	s3,a0,96
    80003910:	00f4f793          	andi	a5,s1,15
    80003914:	079a                	slli	a5,a5,0x6
    80003916:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003918:	00099783          	lh	a5,0(s3)
    8000391c:	c785                	beqz	a5,80003944 <ialloc+0x84>
    brelse(bp);
    8000391e:	00000097          	auipc	ra,0x0
    80003922:	a68080e7          	jalr	-1432(ra) # 80003386 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003926:	0485                	addi	s1,s1,1
    80003928:	00ca2703          	lw	a4,12(s4)
    8000392c:	0004879b          	sext.w	a5,s1
    80003930:	fce7e1e3          	bltu	a5,a4,800038f2 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003934:	00005517          	auipc	a0,0x5
    80003938:	ce450513          	addi	a0,a0,-796 # 80008618 <syscalls+0x160>
    8000393c:	ffffd097          	auipc	ra,0xffffd
    80003940:	c14080e7          	jalr	-1004(ra) # 80000550 <panic>
      memset(dip, 0, sizeof(*dip));
    80003944:	04000613          	li	a2,64
    80003948:	4581                	li	a1,0
    8000394a:	854e                	mv	a0,s3
    8000394c:	ffffe097          	auipc	ra,0xffffe
    80003950:	876080e7          	jalr	-1930(ra) # 800011c2 <memset>
      dip->type = type;
    80003954:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003958:	854a                	mv	a0,s2
    8000395a:	00001097          	auipc	ra,0x1
    8000395e:	ca6080e7          	jalr	-858(ra) # 80004600 <log_write>
      brelse(bp);
    80003962:	854a                	mv	a0,s2
    80003964:	00000097          	auipc	ra,0x0
    80003968:	a22080e7          	jalr	-1502(ra) # 80003386 <brelse>
      return iget(dev, inum);
    8000396c:	85da                	mv	a1,s6
    8000396e:	8556                	mv	a0,s5
    80003970:	00000097          	auipc	ra,0x0
    80003974:	db4080e7          	jalr	-588(ra) # 80003724 <iget>
}
    80003978:	60a6                	ld	ra,72(sp)
    8000397a:	6406                	ld	s0,64(sp)
    8000397c:	74e2                	ld	s1,56(sp)
    8000397e:	7942                	ld	s2,48(sp)
    80003980:	79a2                	ld	s3,40(sp)
    80003982:	7a02                	ld	s4,32(sp)
    80003984:	6ae2                	ld	s5,24(sp)
    80003986:	6b42                	ld	s6,16(sp)
    80003988:	6ba2                	ld	s7,8(sp)
    8000398a:	6161                	addi	sp,sp,80
    8000398c:	8082                	ret

000000008000398e <iupdate>:
{
    8000398e:	1101                	addi	sp,sp,-32
    80003990:	ec06                	sd	ra,24(sp)
    80003992:	e822                	sd	s0,16(sp)
    80003994:	e426                	sd	s1,8(sp)
    80003996:	e04a                	sd	s2,0(sp)
    80003998:	1000                	addi	s0,sp,32
    8000399a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000399c:	415c                	lw	a5,4(a0)
    8000399e:	0047d79b          	srliw	a5,a5,0x4
    800039a2:	0001d597          	auipc	a1,0x1d
    800039a6:	1fe5a583          	lw	a1,510(a1) # 80020ba0 <sb+0x18>
    800039aa:	9dbd                	addw	a1,a1,a5
    800039ac:	4108                	lw	a0,0(a0)
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	8a8080e7          	jalr	-1880(ra) # 80003256 <bread>
    800039b6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039b8:	06050793          	addi	a5,a0,96
    800039bc:	40c8                	lw	a0,4(s1)
    800039be:	893d                	andi	a0,a0,15
    800039c0:	051a                	slli	a0,a0,0x6
    800039c2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800039c4:	04c49703          	lh	a4,76(s1)
    800039c8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800039cc:	04e49703          	lh	a4,78(s1)
    800039d0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800039d4:	05049703          	lh	a4,80(s1)
    800039d8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800039dc:	05249703          	lh	a4,82(s1)
    800039e0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800039e4:	48f8                	lw	a4,84(s1)
    800039e6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039e8:	03400613          	li	a2,52
    800039ec:	05848593          	addi	a1,s1,88
    800039f0:	0531                	addi	a0,a0,12
    800039f2:	ffffe097          	auipc	ra,0xffffe
    800039f6:	830080e7          	jalr	-2000(ra) # 80001222 <memmove>
  log_write(bp);
    800039fa:	854a                	mv	a0,s2
    800039fc:	00001097          	auipc	ra,0x1
    80003a00:	c04080e7          	jalr	-1020(ra) # 80004600 <log_write>
  brelse(bp);
    80003a04:	854a                	mv	a0,s2
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	980080e7          	jalr	-1664(ra) # 80003386 <brelse>
}
    80003a0e:	60e2                	ld	ra,24(sp)
    80003a10:	6442                	ld	s0,16(sp)
    80003a12:	64a2                	ld	s1,8(sp)
    80003a14:	6902                	ld	s2,0(sp)
    80003a16:	6105                	addi	sp,sp,32
    80003a18:	8082                	ret

0000000080003a1a <idup>:
{
    80003a1a:	1101                	addi	sp,sp,-32
    80003a1c:	ec06                	sd	ra,24(sp)
    80003a1e:	e822                	sd	s0,16(sp)
    80003a20:	e426                	sd	s1,8(sp)
    80003a22:	1000                	addi	s0,sp,32
    80003a24:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a26:	0001d517          	auipc	a0,0x1d
    80003a2a:	18250513          	addi	a0,a0,386 # 80020ba8 <icache>
    80003a2e:	ffffd097          	auipc	ra,0xffffd
    80003a32:	3b4080e7          	jalr	948(ra) # 80000de2 <acquire>
  ip->ref++;
    80003a36:	449c                	lw	a5,8(s1)
    80003a38:	2785                	addiw	a5,a5,1
    80003a3a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a3c:	0001d517          	auipc	a0,0x1d
    80003a40:	16c50513          	addi	a0,a0,364 # 80020ba8 <icache>
    80003a44:	ffffd097          	auipc	ra,0xffffd
    80003a48:	46e080e7          	jalr	1134(ra) # 80000eb2 <release>
}
    80003a4c:	8526                	mv	a0,s1
    80003a4e:	60e2                	ld	ra,24(sp)
    80003a50:	6442                	ld	s0,16(sp)
    80003a52:	64a2                	ld	s1,8(sp)
    80003a54:	6105                	addi	sp,sp,32
    80003a56:	8082                	ret

0000000080003a58 <ilock>:
{
    80003a58:	1101                	addi	sp,sp,-32
    80003a5a:	ec06                	sd	ra,24(sp)
    80003a5c:	e822                	sd	s0,16(sp)
    80003a5e:	e426                	sd	s1,8(sp)
    80003a60:	e04a                	sd	s2,0(sp)
    80003a62:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a64:	c115                	beqz	a0,80003a88 <ilock+0x30>
    80003a66:	84aa                	mv	s1,a0
    80003a68:	451c                	lw	a5,8(a0)
    80003a6a:	00f05f63          	blez	a5,80003a88 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a6e:	0541                	addi	a0,a0,16
    80003a70:	00001097          	auipc	ra,0x1
    80003a74:	cb8080e7          	jalr	-840(ra) # 80004728 <acquiresleep>
  if(ip->valid == 0){
    80003a78:	44bc                	lw	a5,72(s1)
    80003a7a:	cf99                	beqz	a5,80003a98 <ilock+0x40>
}
    80003a7c:	60e2                	ld	ra,24(sp)
    80003a7e:	6442                	ld	s0,16(sp)
    80003a80:	64a2                	ld	s1,8(sp)
    80003a82:	6902                	ld	s2,0(sp)
    80003a84:	6105                	addi	sp,sp,32
    80003a86:	8082                	ret
    panic("ilock");
    80003a88:	00005517          	auipc	a0,0x5
    80003a8c:	ba850513          	addi	a0,a0,-1112 # 80008630 <syscalls+0x178>
    80003a90:	ffffd097          	auipc	ra,0xffffd
    80003a94:	ac0080e7          	jalr	-1344(ra) # 80000550 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a98:	40dc                	lw	a5,4(s1)
    80003a9a:	0047d79b          	srliw	a5,a5,0x4
    80003a9e:	0001d597          	auipc	a1,0x1d
    80003aa2:	1025a583          	lw	a1,258(a1) # 80020ba0 <sb+0x18>
    80003aa6:	9dbd                	addw	a1,a1,a5
    80003aa8:	4088                	lw	a0,0(s1)
    80003aaa:	fffff097          	auipc	ra,0xfffff
    80003aae:	7ac080e7          	jalr	1964(ra) # 80003256 <bread>
    80003ab2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ab4:	06050593          	addi	a1,a0,96
    80003ab8:	40dc                	lw	a5,4(s1)
    80003aba:	8bbd                	andi	a5,a5,15
    80003abc:	079a                	slli	a5,a5,0x6
    80003abe:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ac0:	00059783          	lh	a5,0(a1)
    80003ac4:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003ac8:	00259783          	lh	a5,2(a1)
    80003acc:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003ad0:	00459783          	lh	a5,4(a1)
    80003ad4:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003ad8:	00659783          	lh	a5,6(a1)
    80003adc:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003ae0:	459c                	lw	a5,8(a1)
    80003ae2:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ae4:	03400613          	li	a2,52
    80003ae8:	05b1                	addi	a1,a1,12
    80003aea:	05848513          	addi	a0,s1,88
    80003aee:	ffffd097          	auipc	ra,0xffffd
    80003af2:	734080e7          	jalr	1844(ra) # 80001222 <memmove>
    brelse(bp);
    80003af6:	854a                	mv	a0,s2
    80003af8:	00000097          	auipc	ra,0x0
    80003afc:	88e080e7          	jalr	-1906(ra) # 80003386 <brelse>
    ip->valid = 1;
    80003b00:	4785                	li	a5,1
    80003b02:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003b04:	04c49783          	lh	a5,76(s1)
    80003b08:	fbb5                	bnez	a5,80003a7c <ilock+0x24>
      panic("ilock: no type");
    80003b0a:	00005517          	auipc	a0,0x5
    80003b0e:	b2e50513          	addi	a0,a0,-1234 # 80008638 <syscalls+0x180>
    80003b12:	ffffd097          	auipc	ra,0xffffd
    80003b16:	a3e080e7          	jalr	-1474(ra) # 80000550 <panic>

0000000080003b1a <iunlock>:
{
    80003b1a:	1101                	addi	sp,sp,-32
    80003b1c:	ec06                	sd	ra,24(sp)
    80003b1e:	e822                	sd	s0,16(sp)
    80003b20:	e426                	sd	s1,8(sp)
    80003b22:	e04a                	sd	s2,0(sp)
    80003b24:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b26:	c905                	beqz	a0,80003b56 <iunlock+0x3c>
    80003b28:	84aa                	mv	s1,a0
    80003b2a:	01050913          	addi	s2,a0,16
    80003b2e:	854a                	mv	a0,s2
    80003b30:	00001097          	auipc	ra,0x1
    80003b34:	c92080e7          	jalr	-878(ra) # 800047c2 <holdingsleep>
    80003b38:	cd19                	beqz	a0,80003b56 <iunlock+0x3c>
    80003b3a:	449c                	lw	a5,8(s1)
    80003b3c:	00f05d63          	blez	a5,80003b56 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b40:	854a                	mv	a0,s2
    80003b42:	00001097          	auipc	ra,0x1
    80003b46:	c3c080e7          	jalr	-964(ra) # 8000477e <releasesleep>
}
    80003b4a:	60e2                	ld	ra,24(sp)
    80003b4c:	6442                	ld	s0,16(sp)
    80003b4e:	64a2                	ld	s1,8(sp)
    80003b50:	6902                	ld	s2,0(sp)
    80003b52:	6105                	addi	sp,sp,32
    80003b54:	8082                	ret
    panic("iunlock");
    80003b56:	00005517          	auipc	a0,0x5
    80003b5a:	af250513          	addi	a0,a0,-1294 # 80008648 <syscalls+0x190>
    80003b5e:	ffffd097          	auipc	ra,0xffffd
    80003b62:	9f2080e7          	jalr	-1550(ra) # 80000550 <panic>

0000000080003b66 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b66:	7179                	addi	sp,sp,-48
    80003b68:	f406                	sd	ra,40(sp)
    80003b6a:	f022                	sd	s0,32(sp)
    80003b6c:	ec26                	sd	s1,24(sp)
    80003b6e:	e84a                	sd	s2,16(sp)
    80003b70:	e44e                	sd	s3,8(sp)
    80003b72:	e052                	sd	s4,0(sp)
    80003b74:	1800                	addi	s0,sp,48
    80003b76:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b78:	05850493          	addi	s1,a0,88
    80003b7c:	08850913          	addi	s2,a0,136
    80003b80:	a021                	j	80003b88 <itrunc+0x22>
    80003b82:	0491                	addi	s1,s1,4
    80003b84:	01248d63          	beq	s1,s2,80003b9e <itrunc+0x38>
    if(ip->addrs[i]){
    80003b88:	408c                	lw	a1,0(s1)
    80003b8a:	dde5                	beqz	a1,80003b82 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b8c:	0009a503          	lw	a0,0(s3)
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	90c080e7          	jalr	-1780(ra) # 8000349c <bfree>
      ip->addrs[i] = 0;
    80003b98:	0004a023          	sw	zero,0(s1)
    80003b9c:	b7dd                	j	80003b82 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b9e:	0889a583          	lw	a1,136(s3)
    80003ba2:	e185                	bnez	a1,80003bc2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ba4:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003ba8:	854e                	mv	a0,s3
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	de4080e7          	jalr	-540(ra) # 8000398e <iupdate>
}
    80003bb2:	70a2                	ld	ra,40(sp)
    80003bb4:	7402                	ld	s0,32(sp)
    80003bb6:	64e2                	ld	s1,24(sp)
    80003bb8:	6942                	ld	s2,16(sp)
    80003bba:	69a2                	ld	s3,8(sp)
    80003bbc:	6a02                	ld	s4,0(sp)
    80003bbe:	6145                	addi	sp,sp,48
    80003bc0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003bc2:	0009a503          	lw	a0,0(s3)
    80003bc6:	fffff097          	auipc	ra,0xfffff
    80003bca:	690080e7          	jalr	1680(ra) # 80003256 <bread>
    80003bce:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003bd0:	06050493          	addi	s1,a0,96
    80003bd4:	46050913          	addi	s2,a0,1120
    80003bd8:	a811                	j	80003bec <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003bda:	0009a503          	lw	a0,0(s3)
    80003bde:	00000097          	auipc	ra,0x0
    80003be2:	8be080e7          	jalr	-1858(ra) # 8000349c <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003be6:	0491                	addi	s1,s1,4
    80003be8:	01248563          	beq	s1,s2,80003bf2 <itrunc+0x8c>
      if(a[j])
    80003bec:	408c                	lw	a1,0(s1)
    80003bee:	dde5                	beqz	a1,80003be6 <itrunc+0x80>
    80003bf0:	b7ed                	j	80003bda <itrunc+0x74>
    brelse(bp);
    80003bf2:	8552                	mv	a0,s4
    80003bf4:	fffff097          	auipc	ra,0xfffff
    80003bf8:	792080e7          	jalr	1938(ra) # 80003386 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003bfc:	0889a583          	lw	a1,136(s3)
    80003c00:	0009a503          	lw	a0,0(s3)
    80003c04:	00000097          	auipc	ra,0x0
    80003c08:	898080e7          	jalr	-1896(ra) # 8000349c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c0c:	0809a423          	sw	zero,136(s3)
    80003c10:	bf51                	j	80003ba4 <itrunc+0x3e>

0000000080003c12 <iput>:
{
    80003c12:	1101                	addi	sp,sp,-32
    80003c14:	ec06                	sd	ra,24(sp)
    80003c16:	e822                	sd	s0,16(sp)
    80003c18:	e426                	sd	s1,8(sp)
    80003c1a:	e04a                	sd	s2,0(sp)
    80003c1c:	1000                	addi	s0,sp,32
    80003c1e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003c20:	0001d517          	auipc	a0,0x1d
    80003c24:	f8850513          	addi	a0,a0,-120 # 80020ba8 <icache>
    80003c28:	ffffd097          	auipc	ra,0xffffd
    80003c2c:	1ba080e7          	jalr	442(ra) # 80000de2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c30:	4498                	lw	a4,8(s1)
    80003c32:	4785                	li	a5,1
    80003c34:	02f70363          	beq	a4,a5,80003c5a <iput+0x48>
  ip->ref--;
    80003c38:	449c                	lw	a5,8(s1)
    80003c3a:	37fd                	addiw	a5,a5,-1
    80003c3c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003c3e:	0001d517          	auipc	a0,0x1d
    80003c42:	f6a50513          	addi	a0,a0,-150 # 80020ba8 <icache>
    80003c46:	ffffd097          	auipc	ra,0xffffd
    80003c4a:	26c080e7          	jalr	620(ra) # 80000eb2 <release>
}
    80003c4e:	60e2                	ld	ra,24(sp)
    80003c50:	6442                	ld	s0,16(sp)
    80003c52:	64a2                	ld	s1,8(sp)
    80003c54:	6902                	ld	s2,0(sp)
    80003c56:	6105                	addi	sp,sp,32
    80003c58:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c5a:	44bc                	lw	a5,72(s1)
    80003c5c:	dff1                	beqz	a5,80003c38 <iput+0x26>
    80003c5e:	05249783          	lh	a5,82(s1)
    80003c62:	fbf9                	bnez	a5,80003c38 <iput+0x26>
    acquiresleep(&ip->lock);
    80003c64:	01048913          	addi	s2,s1,16
    80003c68:	854a                	mv	a0,s2
    80003c6a:	00001097          	auipc	ra,0x1
    80003c6e:	abe080e7          	jalr	-1346(ra) # 80004728 <acquiresleep>
    release(&icache.lock);
    80003c72:	0001d517          	auipc	a0,0x1d
    80003c76:	f3650513          	addi	a0,a0,-202 # 80020ba8 <icache>
    80003c7a:	ffffd097          	auipc	ra,0xffffd
    80003c7e:	238080e7          	jalr	568(ra) # 80000eb2 <release>
    itrunc(ip);
    80003c82:	8526                	mv	a0,s1
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	ee2080e7          	jalr	-286(ra) # 80003b66 <itrunc>
    ip->type = 0;
    80003c8c:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003c90:	8526                	mv	a0,s1
    80003c92:	00000097          	auipc	ra,0x0
    80003c96:	cfc080e7          	jalr	-772(ra) # 8000398e <iupdate>
    ip->valid = 0;
    80003c9a:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003c9e:	854a                	mv	a0,s2
    80003ca0:	00001097          	auipc	ra,0x1
    80003ca4:	ade080e7          	jalr	-1314(ra) # 8000477e <releasesleep>
    acquire(&icache.lock);
    80003ca8:	0001d517          	auipc	a0,0x1d
    80003cac:	f0050513          	addi	a0,a0,-256 # 80020ba8 <icache>
    80003cb0:	ffffd097          	auipc	ra,0xffffd
    80003cb4:	132080e7          	jalr	306(ra) # 80000de2 <acquire>
    80003cb8:	b741                	j	80003c38 <iput+0x26>

0000000080003cba <iunlockput>:
{
    80003cba:	1101                	addi	sp,sp,-32
    80003cbc:	ec06                	sd	ra,24(sp)
    80003cbe:	e822                	sd	s0,16(sp)
    80003cc0:	e426                	sd	s1,8(sp)
    80003cc2:	1000                	addi	s0,sp,32
    80003cc4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003cc6:	00000097          	auipc	ra,0x0
    80003cca:	e54080e7          	jalr	-428(ra) # 80003b1a <iunlock>
  iput(ip);
    80003cce:	8526                	mv	a0,s1
    80003cd0:	00000097          	auipc	ra,0x0
    80003cd4:	f42080e7          	jalr	-190(ra) # 80003c12 <iput>
}
    80003cd8:	60e2                	ld	ra,24(sp)
    80003cda:	6442                	ld	s0,16(sp)
    80003cdc:	64a2                	ld	s1,8(sp)
    80003cde:	6105                	addi	sp,sp,32
    80003ce0:	8082                	ret

0000000080003ce2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ce2:	1141                	addi	sp,sp,-16
    80003ce4:	e422                	sd	s0,8(sp)
    80003ce6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ce8:	411c                	lw	a5,0(a0)
    80003cea:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003cec:	415c                	lw	a5,4(a0)
    80003cee:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003cf0:	04c51783          	lh	a5,76(a0)
    80003cf4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003cf8:	05251783          	lh	a5,82(a0)
    80003cfc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d00:	05456783          	lwu	a5,84(a0)
    80003d04:	e99c                	sd	a5,16(a1)
}
    80003d06:	6422                	ld	s0,8(sp)
    80003d08:	0141                	addi	sp,sp,16
    80003d0a:	8082                	ret

0000000080003d0c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d0c:	497c                	lw	a5,84(a0)
    80003d0e:	0ed7e963          	bltu	a5,a3,80003e00 <readi+0xf4>
{
    80003d12:	7159                	addi	sp,sp,-112
    80003d14:	f486                	sd	ra,104(sp)
    80003d16:	f0a2                	sd	s0,96(sp)
    80003d18:	eca6                	sd	s1,88(sp)
    80003d1a:	e8ca                	sd	s2,80(sp)
    80003d1c:	e4ce                	sd	s3,72(sp)
    80003d1e:	e0d2                	sd	s4,64(sp)
    80003d20:	fc56                	sd	s5,56(sp)
    80003d22:	f85a                	sd	s6,48(sp)
    80003d24:	f45e                	sd	s7,40(sp)
    80003d26:	f062                	sd	s8,32(sp)
    80003d28:	ec66                	sd	s9,24(sp)
    80003d2a:	e86a                	sd	s10,16(sp)
    80003d2c:	e46e                	sd	s11,8(sp)
    80003d2e:	1880                	addi	s0,sp,112
    80003d30:	8baa                	mv	s7,a0
    80003d32:	8c2e                	mv	s8,a1
    80003d34:	8ab2                	mv	s5,a2
    80003d36:	84b6                	mv	s1,a3
    80003d38:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d3a:	9f35                	addw	a4,a4,a3
    return 0;
    80003d3c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d3e:	0ad76063          	bltu	a4,a3,80003dde <readi+0xd2>
  if(off + n > ip->size)
    80003d42:	00e7f463          	bgeu	a5,a4,80003d4a <readi+0x3e>
    n = ip->size - off;
    80003d46:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d4a:	0a0b0963          	beqz	s6,80003dfc <readi+0xf0>
    80003d4e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d50:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d54:	5cfd                	li	s9,-1
    80003d56:	a82d                	j	80003d90 <readi+0x84>
    80003d58:	020a1d93          	slli	s11,s4,0x20
    80003d5c:	020ddd93          	srli	s11,s11,0x20
    80003d60:	06090613          	addi	a2,s2,96
    80003d64:	86ee                	mv	a3,s11
    80003d66:	963a                	add	a2,a2,a4
    80003d68:	85d6                	mv	a1,s5
    80003d6a:	8562                	mv	a0,s8
    80003d6c:	fffff097          	auipc	ra,0xfffff
    80003d70:	b2e080e7          	jalr	-1234(ra) # 8000289a <either_copyout>
    80003d74:	05950d63          	beq	a0,s9,80003dce <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d78:	854a                	mv	a0,s2
    80003d7a:	fffff097          	auipc	ra,0xfffff
    80003d7e:	60c080e7          	jalr	1548(ra) # 80003386 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d82:	013a09bb          	addw	s3,s4,s3
    80003d86:	009a04bb          	addw	s1,s4,s1
    80003d8a:	9aee                	add	s5,s5,s11
    80003d8c:	0569f763          	bgeu	s3,s6,80003dda <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d90:	000ba903          	lw	s2,0(s7)
    80003d94:	00a4d59b          	srliw	a1,s1,0xa
    80003d98:	855e                	mv	a0,s7
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	8b0080e7          	jalr	-1872(ra) # 8000364a <bmap>
    80003da2:	0005059b          	sext.w	a1,a0
    80003da6:	854a                	mv	a0,s2
    80003da8:	fffff097          	auipc	ra,0xfffff
    80003dac:	4ae080e7          	jalr	1198(ra) # 80003256 <bread>
    80003db0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003db2:	3ff4f713          	andi	a4,s1,1023
    80003db6:	40ed07bb          	subw	a5,s10,a4
    80003dba:	413b06bb          	subw	a3,s6,s3
    80003dbe:	8a3e                	mv	s4,a5
    80003dc0:	2781                	sext.w	a5,a5
    80003dc2:	0006861b          	sext.w	a2,a3
    80003dc6:	f8f679e3          	bgeu	a2,a5,80003d58 <readi+0x4c>
    80003dca:	8a36                	mv	s4,a3
    80003dcc:	b771                	j	80003d58 <readi+0x4c>
      brelse(bp);
    80003dce:	854a                	mv	a0,s2
    80003dd0:	fffff097          	auipc	ra,0xfffff
    80003dd4:	5b6080e7          	jalr	1462(ra) # 80003386 <brelse>
      tot = -1;
    80003dd8:	59fd                	li	s3,-1
  }
  return tot;
    80003dda:	0009851b          	sext.w	a0,s3
}
    80003dde:	70a6                	ld	ra,104(sp)
    80003de0:	7406                	ld	s0,96(sp)
    80003de2:	64e6                	ld	s1,88(sp)
    80003de4:	6946                	ld	s2,80(sp)
    80003de6:	69a6                	ld	s3,72(sp)
    80003de8:	6a06                	ld	s4,64(sp)
    80003dea:	7ae2                	ld	s5,56(sp)
    80003dec:	7b42                	ld	s6,48(sp)
    80003dee:	7ba2                	ld	s7,40(sp)
    80003df0:	7c02                	ld	s8,32(sp)
    80003df2:	6ce2                	ld	s9,24(sp)
    80003df4:	6d42                	ld	s10,16(sp)
    80003df6:	6da2                	ld	s11,8(sp)
    80003df8:	6165                	addi	sp,sp,112
    80003dfa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dfc:	89da                	mv	s3,s6
    80003dfe:	bff1                	j	80003dda <readi+0xce>
    return 0;
    80003e00:	4501                	li	a0,0
}
    80003e02:	8082                	ret

0000000080003e04 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e04:	497c                	lw	a5,84(a0)
    80003e06:	10d7e763          	bltu	a5,a3,80003f14 <writei+0x110>
{
    80003e0a:	7159                	addi	sp,sp,-112
    80003e0c:	f486                	sd	ra,104(sp)
    80003e0e:	f0a2                	sd	s0,96(sp)
    80003e10:	eca6                	sd	s1,88(sp)
    80003e12:	e8ca                	sd	s2,80(sp)
    80003e14:	e4ce                	sd	s3,72(sp)
    80003e16:	e0d2                	sd	s4,64(sp)
    80003e18:	fc56                	sd	s5,56(sp)
    80003e1a:	f85a                	sd	s6,48(sp)
    80003e1c:	f45e                	sd	s7,40(sp)
    80003e1e:	f062                	sd	s8,32(sp)
    80003e20:	ec66                	sd	s9,24(sp)
    80003e22:	e86a                	sd	s10,16(sp)
    80003e24:	e46e                	sd	s11,8(sp)
    80003e26:	1880                	addi	s0,sp,112
    80003e28:	8baa                	mv	s7,a0
    80003e2a:	8c2e                	mv	s8,a1
    80003e2c:	8ab2                	mv	s5,a2
    80003e2e:	8936                	mv	s2,a3
    80003e30:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e32:	00e687bb          	addw	a5,a3,a4
    80003e36:	0ed7e163          	bltu	a5,a3,80003f18 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e3a:	00043737          	lui	a4,0x43
    80003e3e:	0cf76f63          	bltu	a4,a5,80003f1c <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e42:	0a0b0863          	beqz	s6,80003ef2 <writei+0xee>
    80003e46:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e48:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e4c:	5cfd                	li	s9,-1
    80003e4e:	a091                	j	80003e92 <writei+0x8e>
    80003e50:	02099d93          	slli	s11,s3,0x20
    80003e54:	020ddd93          	srli	s11,s11,0x20
    80003e58:	06048513          	addi	a0,s1,96
    80003e5c:	86ee                	mv	a3,s11
    80003e5e:	8656                	mv	a2,s5
    80003e60:	85e2                	mv	a1,s8
    80003e62:	953a                	add	a0,a0,a4
    80003e64:	fffff097          	auipc	ra,0xfffff
    80003e68:	a8c080e7          	jalr	-1396(ra) # 800028f0 <either_copyin>
    80003e6c:	07950263          	beq	a0,s9,80003ed0 <writei+0xcc>
      brelse(bp);
      n = -1;
      break;
    }
    log_write(bp);
    80003e70:	8526                	mv	a0,s1
    80003e72:	00000097          	auipc	ra,0x0
    80003e76:	78e080e7          	jalr	1934(ra) # 80004600 <log_write>
    brelse(bp);
    80003e7a:	8526                	mv	a0,s1
    80003e7c:	fffff097          	auipc	ra,0xfffff
    80003e80:	50a080e7          	jalr	1290(ra) # 80003386 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e84:	01498a3b          	addw	s4,s3,s4
    80003e88:	0129893b          	addw	s2,s3,s2
    80003e8c:	9aee                	add	s5,s5,s11
    80003e8e:	056a7763          	bgeu	s4,s6,80003edc <writei+0xd8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e92:	000ba483          	lw	s1,0(s7)
    80003e96:	00a9559b          	srliw	a1,s2,0xa
    80003e9a:	855e                	mv	a0,s7
    80003e9c:	fffff097          	auipc	ra,0xfffff
    80003ea0:	7ae080e7          	jalr	1966(ra) # 8000364a <bmap>
    80003ea4:	0005059b          	sext.w	a1,a0
    80003ea8:	8526                	mv	a0,s1
    80003eaa:	fffff097          	auipc	ra,0xfffff
    80003eae:	3ac080e7          	jalr	940(ra) # 80003256 <bread>
    80003eb2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003eb4:	3ff97713          	andi	a4,s2,1023
    80003eb8:	40ed07bb          	subw	a5,s10,a4
    80003ebc:	414b06bb          	subw	a3,s6,s4
    80003ec0:	89be                	mv	s3,a5
    80003ec2:	2781                	sext.w	a5,a5
    80003ec4:	0006861b          	sext.w	a2,a3
    80003ec8:	f8f674e3          	bgeu	a2,a5,80003e50 <writei+0x4c>
    80003ecc:	89b6                	mv	s3,a3
    80003ece:	b749                	j	80003e50 <writei+0x4c>
      brelse(bp);
    80003ed0:	8526                	mv	a0,s1
    80003ed2:	fffff097          	auipc	ra,0xfffff
    80003ed6:	4b4080e7          	jalr	1204(ra) # 80003386 <brelse>
      n = -1;
    80003eda:	5b7d                	li	s6,-1
  }

  if(n > 0){
    if(off > ip->size)
    80003edc:	054ba783          	lw	a5,84(s7)
    80003ee0:	0127f463          	bgeu	a5,s2,80003ee8 <writei+0xe4>
      ip->size = off;
    80003ee4:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003ee8:	855e                	mv	a0,s7
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	aa4080e7          	jalr	-1372(ra) # 8000398e <iupdate>
  }

  return n;
    80003ef2:	000b051b          	sext.w	a0,s6
}
    80003ef6:	70a6                	ld	ra,104(sp)
    80003ef8:	7406                	ld	s0,96(sp)
    80003efa:	64e6                	ld	s1,88(sp)
    80003efc:	6946                	ld	s2,80(sp)
    80003efe:	69a6                	ld	s3,72(sp)
    80003f00:	6a06                	ld	s4,64(sp)
    80003f02:	7ae2                	ld	s5,56(sp)
    80003f04:	7b42                	ld	s6,48(sp)
    80003f06:	7ba2                	ld	s7,40(sp)
    80003f08:	7c02                	ld	s8,32(sp)
    80003f0a:	6ce2                	ld	s9,24(sp)
    80003f0c:	6d42                	ld	s10,16(sp)
    80003f0e:	6da2                	ld	s11,8(sp)
    80003f10:	6165                	addi	sp,sp,112
    80003f12:	8082                	ret
    return -1;
    80003f14:	557d                	li	a0,-1
}
    80003f16:	8082                	ret
    return -1;
    80003f18:	557d                	li	a0,-1
    80003f1a:	bff1                	j	80003ef6 <writei+0xf2>
    return -1;
    80003f1c:	557d                	li	a0,-1
    80003f1e:	bfe1                	j	80003ef6 <writei+0xf2>

0000000080003f20 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f20:	1141                	addi	sp,sp,-16
    80003f22:	e406                	sd	ra,8(sp)
    80003f24:	e022                	sd	s0,0(sp)
    80003f26:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f28:	4639                	li	a2,14
    80003f2a:	ffffd097          	auipc	ra,0xffffd
    80003f2e:	374080e7          	jalr	884(ra) # 8000129e <strncmp>
}
    80003f32:	60a2                	ld	ra,8(sp)
    80003f34:	6402                	ld	s0,0(sp)
    80003f36:	0141                	addi	sp,sp,16
    80003f38:	8082                	ret

0000000080003f3a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f3a:	7139                	addi	sp,sp,-64
    80003f3c:	fc06                	sd	ra,56(sp)
    80003f3e:	f822                	sd	s0,48(sp)
    80003f40:	f426                	sd	s1,40(sp)
    80003f42:	f04a                	sd	s2,32(sp)
    80003f44:	ec4e                	sd	s3,24(sp)
    80003f46:	e852                	sd	s4,16(sp)
    80003f48:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f4a:	04c51703          	lh	a4,76(a0)
    80003f4e:	4785                	li	a5,1
    80003f50:	00f71a63          	bne	a4,a5,80003f64 <dirlookup+0x2a>
    80003f54:	892a                	mv	s2,a0
    80003f56:	89ae                	mv	s3,a1
    80003f58:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f5a:	497c                	lw	a5,84(a0)
    80003f5c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f5e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f60:	e79d                	bnez	a5,80003f8e <dirlookup+0x54>
    80003f62:	a8a5                	j	80003fda <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f64:	00004517          	auipc	a0,0x4
    80003f68:	6ec50513          	addi	a0,a0,1772 # 80008650 <syscalls+0x198>
    80003f6c:	ffffc097          	auipc	ra,0xffffc
    80003f70:	5e4080e7          	jalr	1508(ra) # 80000550 <panic>
      panic("dirlookup read");
    80003f74:	00004517          	auipc	a0,0x4
    80003f78:	6f450513          	addi	a0,a0,1780 # 80008668 <syscalls+0x1b0>
    80003f7c:	ffffc097          	auipc	ra,0xffffc
    80003f80:	5d4080e7          	jalr	1492(ra) # 80000550 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f84:	24c1                	addiw	s1,s1,16
    80003f86:	05492783          	lw	a5,84(s2)
    80003f8a:	04f4f763          	bgeu	s1,a5,80003fd8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f8e:	4741                	li	a4,16
    80003f90:	86a6                	mv	a3,s1
    80003f92:	fc040613          	addi	a2,s0,-64
    80003f96:	4581                	li	a1,0
    80003f98:	854a                	mv	a0,s2
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	d72080e7          	jalr	-654(ra) # 80003d0c <readi>
    80003fa2:	47c1                	li	a5,16
    80003fa4:	fcf518e3          	bne	a0,a5,80003f74 <dirlookup+0x3a>
    if(de.inum == 0)
    80003fa8:	fc045783          	lhu	a5,-64(s0)
    80003fac:	dfe1                	beqz	a5,80003f84 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003fae:	fc240593          	addi	a1,s0,-62
    80003fb2:	854e                	mv	a0,s3
    80003fb4:	00000097          	auipc	ra,0x0
    80003fb8:	f6c080e7          	jalr	-148(ra) # 80003f20 <namecmp>
    80003fbc:	f561                	bnez	a0,80003f84 <dirlookup+0x4a>
      if(poff)
    80003fbe:	000a0463          	beqz	s4,80003fc6 <dirlookup+0x8c>
        *poff = off;
    80003fc2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003fc6:	fc045583          	lhu	a1,-64(s0)
    80003fca:	00092503          	lw	a0,0(s2)
    80003fce:	fffff097          	auipc	ra,0xfffff
    80003fd2:	756080e7          	jalr	1878(ra) # 80003724 <iget>
    80003fd6:	a011                	j	80003fda <dirlookup+0xa0>
  return 0;
    80003fd8:	4501                	li	a0,0
}
    80003fda:	70e2                	ld	ra,56(sp)
    80003fdc:	7442                	ld	s0,48(sp)
    80003fde:	74a2                	ld	s1,40(sp)
    80003fe0:	7902                	ld	s2,32(sp)
    80003fe2:	69e2                	ld	s3,24(sp)
    80003fe4:	6a42                	ld	s4,16(sp)
    80003fe6:	6121                	addi	sp,sp,64
    80003fe8:	8082                	ret

0000000080003fea <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fea:	711d                	addi	sp,sp,-96
    80003fec:	ec86                	sd	ra,88(sp)
    80003fee:	e8a2                	sd	s0,80(sp)
    80003ff0:	e4a6                	sd	s1,72(sp)
    80003ff2:	e0ca                	sd	s2,64(sp)
    80003ff4:	fc4e                	sd	s3,56(sp)
    80003ff6:	f852                	sd	s4,48(sp)
    80003ff8:	f456                	sd	s5,40(sp)
    80003ffa:	f05a                	sd	s6,32(sp)
    80003ffc:	ec5e                	sd	s7,24(sp)
    80003ffe:	e862                	sd	s8,16(sp)
    80004000:	e466                	sd	s9,8(sp)
    80004002:	1080                	addi	s0,sp,96
    80004004:	84aa                	mv	s1,a0
    80004006:	8b2e                	mv	s6,a1
    80004008:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000400a:	00054703          	lbu	a4,0(a0)
    8000400e:	02f00793          	li	a5,47
    80004012:	02f70363          	beq	a4,a5,80004038 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004016:	ffffe097          	auipc	ra,0xffffe
    8000401a:	e14080e7          	jalr	-492(ra) # 80001e2a <myproc>
    8000401e:	15853503          	ld	a0,344(a0)
    80004022:	00000097          	auipc	ra,0x0
    80004026:	9f8080e7          	jalr	-1544(ra) # 80003a1a <idup>
    8000402a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000402c:	02f00913          	li	s2,47
  len = path - s;
    80004030:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004032:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004034:	4c05                	li	s8,1
    80004036:	a865                	j	800040ee <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004038:	4585                	li	a1,1
    8000403a:	4505                	li	a0,1
    8000403c:	fffff097          	auipc	ra,0xfffff
    80004040:	6e8080e7          	jalr	1768(ra) # 80003724 <iget>
    80004044:	89aa                	mv	s3,a0
    80004046:	b7dd                	j	8000402c <namex+0x42>
      iunlockput(ip);
    80004048:	854e                	mv	a0,s3
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	c70080e7          	jalr	-912(ra) # 80003cba <iunlockput>
      return 0;
    80004052:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004054:	854e                	mv	a0,s3
    80004056:	60e6                	ld	ra,88(sp)
    80004058:	6446                	ld	s0,80(sp)
    8000405a:	64a6                	ld	s1,72(sp)
    8000405c:	6906                	ld	s2,64(sp)
    8000405e:	79e2                	ld	s3,56(sp)
    80004060:	7a42                	ld	s4,48(sp)
    80004062:	7aa2                	ld	s5,40(sp)
    80004064:	7b02                	ld	s6,32(sp)
    80004066:	6be2                	ld	s7,24(sp)
    80004068:	6c42                	ld	s8,16(sp)
    8000406a:	6ca2                	ld	s9,8(sp)
    8000406c:	6125                	addi	sp,sp,96
    8000406e:	8082                	ret
      iunlock(ip);
    80004070:	854e                	mv	a0,s3
    80004072:	00000097          	auipc	ra,0x0
    80004076:	aa8080e7          	jalr	-1368(ra) # 80003b1a <iunlock>
      return ip;
    8000407a:	bfe9                	j	80004054 <namex+0x6a>
      iunlockput(ip);
    8000407c:	854e                	mv	a0,s3
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	c3c080e7          	jalr	-964(ra) # 80003cba <iunlockput>
      return 0;
    80004086:	89d2                	mv	s3,s4
    80004088:	b7f1                	j	80004054 <namex+0x6a>
  len = path - s;
    8000408a:	40b48633          	sub	a2,s1,a1
    8000408e:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004092:	094cd463          	bge	s9,s4,8000411a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004096:	4639                	li	a2,14
    80004098:	8556                	mv	a0,s5
    8000409a:	ffffd097          	auipc	ra,0xffffd
    8000409e:	188080e7          	jalr	392(ra) # 80001222 <memmove>
  while(*path == '/')
    800040a2:	0004c783          	lbu	a5,0(s1)
    800040a6:	01279763          	bne	a5,s2,800040b4 <namex+0xca>
    path++;
    800040aa:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040ac:	0004c783          	lbu	a5,0(s1)
    800040b0:	ff278de3          	beq	a5,s2,800040aa <namex+0xc0>
    ilock(ip);
    800040b4:	854e                	mv	a0,s3
    800040b6:	00000097          	auipc	ra,0x0
    800040ba:	9a2080e7          	jalr	-1630(ra) # 80003a58 <ilock>
    if(ip->type != T_DIR){
    800040be:	04c99783          	lh	a5,76(s3)
    800040c2:	f98793e3          	bne	a5,s8,80004048 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800040c6:	000b0563          	beqz	s6,800040d0 <namex+0xe6>
    800040ca:	0004c783          	lbu	a5,0(s1)
    800040ce:	d3cd                	beqz	a5,80004070 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800040d0:	865e                	mv	a2,s7
    800040d2:	85d6                	mv	a1,s5
    800040d4:	854e                	mv	a0,s3
    800040d6:	00000097          	auipc	ra,0x0
    800040da:	e64080e7          	jalr	-412(ra) # 80003f3a <dirlookup>
    800040de:	8a2a                	mv	s4,a0
    800040e0:	dd51                	beqz	a0,8000407c <namex+0x92>
    iunlockput(ip);
    800040e2:	854e                	mv	a0,s3
    800040e4:	00000097          	auipc	ra,0x0
    800040e8:	bd6080e7          	jalr	-1066(ra) # 80003cba <iunlockput>
    ip = next;
    800040ec:	89d2                	mv	s3,s4
  while(*path == '/')
    800040ee:	0004c783          	lbu	a5,0(s1)
    800040f2:	05279763          	bne	a5,s2,80004140 <namex+0x156>
    path++;
    800040f6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040f8:	0004c783          	lbu	a5,0(s1)
    800040fc:	ff278de3          	beq	a5,s2,800040f6 <namex+0x10c>
  if(*path == 0)
    80004100:	c79d                	beqz	a5,8000412e <namex+0x144>
    path++;
    80004102:	85a6                	mv	a1,s1
  len = path - s;
    80004104:	8a5e                	mv	s4,s7
    80004106:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004108:	01278963          	beq	a5,s2,8000411a <namex+0x130>
    8000410c:	dfbd                	beqz	a5,8000408a <namex+0xa0>
    path++;
    8000410e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004110:	0004c783          	lbu	a5,0(s1)
    80004114:	ff279ce3          	bne	a5,s2,8000410c <namex+0x122>
    80004118:	bf8d                	j	8000408a <namex+0xa0>
    memmove(name, s, len);
    8000411a:	2601                	sext.w	a2,a2
    8000411c:	8556                	mv	a0,s5
    8000411e:	ffffd097          	auipc	ra,0xffffd
    80004122:	104080e7          	jalr	260(ra) # 80001222 <memmove>
    name[len] = 0;
    80004126:	9a56                	add	s4,s4,s5
    80004128:	000a0023          	sb	zero,0(s4)
    8000412c:	bf9d                	j	800040a2 <namex+0xb8>
  if(nameiparent){
    8000412e:	f20b03e3          	beqz	s6,80004054 <namex+0x6a>
    iput(ip);
    80004132:	854e                	mv	a0,s3
    80004134:	00000097          	auipc	ra,0x0
    80004138:	ade080e7          	jalr	-1314(ra) # 80003c12 <iput>
    return 0;
    8000413c:	4981                	li	s3,0
    8000413e:	bf19                	j	80004054 <namex+0x6a>
  if(*path == 0)
    80004140:	d7fd                	beqz	a5,8000412e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004142:	0004c783          	lbu	a5,0(s1)
    80004146:	85a6                	mv	a1,s1
    80004148:	b7d1                	j	8000410c <namex+0x122>

000000008000414a <dirlink>:
{
    8000414a:	7139                	addi	sp,sp,-64
    8000414c:	fc06                	sd	ra,56(sp)
    8000414e:	f822                	sd	s0,48(sp)
    80004150:	f426                	sd	s1,40(sp)
    80004152:	f04a                	sd	s2,32(sp)
    80004154:	ec4e                	sd	s3,24(sp)
    80004156:	e852                	sd	s4,16(sp)
    80004158:	0080                	addi	s0,sp,64
    8000415a:	892a                	mv	s2,a0
    8000415c:	8a2e                	mv	s4,a1
    8000415e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004160:	4601                	li	a2,0
    80004162:	00000097          	auipc	ra,0x0
    80004166:	dd8080e7          	jalr	-552(ra) # 80003f3a <dirlookup>
    8000416a:	e93d                	bnez	a0,800041e0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000416c:	05492483          	lw	s1,84(s2)
    80004170:	c49d                	beqz	s1,8000419e <dirlink+0x54>
    80004172:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004174:	4741                	li	a4,16
    80004176:	86a6                	mv	a3,s1
    80004178:	fc040613          	addi	a2,s0,-64
    8000417c:	4581                	li	a1,0
    8000417e:	854a                	mv	a0,s2
    80004180:	00000097          	auipc	ra,0x0
    80004184:	b8c080e7          	jalr	-1140(ra) # 80003d0c <readi>
    80004188:	47c1                	li	a5,16
    8000418a:	06f51163          	bne	a0,a5,800041ec <dirlink+0xa2>
    if(de.inum == 0)
    8000418e:	fc045783          	lhu	a5,-64(s0)
    80004192:	c791                	beqz	a5,8000419e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004194:	24c1                	addiw	s1,s1,16
    80004196:	05492783          	lw	a5,84(s2)
    8000419a:	fcf4ede3          	bltu	s1,a5,80004174 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000419e:	4639                	li	a2,14
    800041a0:	85d2                	mv	a1,s4
    800041a2:	fc240513          	addi	a0,s0,-62
    800041a6:	ffffd097          	auipc	ra,0xffffd
    800041aa:	134080e7          	jalr	308(ra) # 800012da <strncpy>
  de.inum = inum;
    800041ae:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041b2:	4741                	li	a4,16
    800041b4:	86a6                	mv	a3,s1
    800041b6:	fc040613          	addi	a2,s0,-64
    800041ba:	4581                	li	a1,0
    800041bc:	854a                	mv	a0,s2
    800041be:	00000097          	auipc	ra,0x0
    800041c2:	c46080e7          	jalr	-954(ra) # 80003e04 <writei>
    800041c6:	872a                	mv	a4,a0
    800041c8:	47c1                	li	a5,16
  return 0;
    800041ca:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041cc:	02f71863          	bne	a4,a5,800041fc <dirlink+0xb2>
}
    800041d0:	70e2                	ld	ra,56(sp)
    800041d2:	7442                	ld	s0,48(sp)
    800041d4:	74a2                	ld	s1,40(sp)
    800041d6:	7902                	ld	s2,32(sp)
    800041d8:	69e2                	ld	s3,24(sp)
    800041da:	6a42                	ld	s4,16(sp)
    800041dc:	6121                	addi	sp,sp,64
    800041de:	8082                	ret
    iput(ip);
    800041e0:	00000097          	auipc	ra,0x0
    800041e4:	a32080e7          	jalr	-1486(ra) # 80003c12 <iput>
    return -1;
    800041e8:	557d                	li	a0,-1
    800041ea:	b7dd                	j	800041d0 <dirlink+0x86>
      panic("dirlink read");
    800041ec:	00004517          	auipc	a0,0x4
    800041f0:	48c50513          	addi	a0,a0,1164 # 80008678 <syscalls+0x1c0>
    800041f4:	ffffc097          	auipc	ra,0xffffc
    800041f8:	35c080e7          	jalr	860(ra) # 80000550 <panic>
    panic("dirlink");
    800041fc:	00004517          	auipc	a0,0x4
    80004200:	59c50513          	addi	a0,a0,1436 # 80008798 <syscalls+0x2e0>
    80004204:	ffffc097          	auipc	ra,0xffffc
    80004208:	34c080e7          	jalr	844(ra) # 80000550 <panic>

000000008000420c <namei>:

struct inode*
namei(char *path)
{
    8000420c:	1101                	addi	sp,sp,-32
    8000420e:	ec06                	sd	ra,24(sp)
    80004210:	e822                	sd	s0,16(sp)
    80004212:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004214:	fe040613          	addi	a2,s0,-32
    80004218:	4581                	li	a1,0
    8000421a:	00000097          	auipc	ra,0x0
    8000421e:	dd0080e7          	jalr	-560(ra) # 80003fea <namex>
}
    80004222:	60e2                	ld	ra,24(sp)
    80004224:	6442                	ld	s0,16(sp)
    80004226:	6105                	addi	sp,sp,32
    80004228:	8082                	ret

000000008000422a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000422a:	1141                	addi	sp,sp,-16
    8000422c:	e406                	sd	ra,8(sp)
    8000422e:	e022                	sd	s0,0(sp)
    80004230:	0800                	addi	s0,sp,16
    80004232:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004234:	4585                	li	a1,1
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	db4080e7          	jalr	-588(ra) # 80003fea <namex>
}
    8000423e:	60a2                	ld	ra,8(sp)
    80004240:	6402                	ld	s0,0(sp)
    80004242:	0141                	addi	sp,sp,16
    80004244:	8082                	ret

0000000080004246 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004246:	1101                	addi	sp,sp,-32
    80004248:	ec06                	sd	ra,24(sp)
    8000424a:	e822                	sd	s0,16(sp)
    8000424c:	e426                	sd	s1,8(sp)
    8000424e:	e04a                	sd	s2,0(sp)
    80004250:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004252:	0001e917          	auipc	s2,0x1e
    80004256:	59690913          	addi	s2,s2,1430 # 800227e8 <log>
    8000425a:	02092583          	lw	a1,32(s2)
    8000425e:	03092503          	lw	a0,48(s2)
    80004262:	fffff097          	auipc	ra,0xfffff
    80004266:	ff4080e7          	jalr	-12(ra) # 80003256 <bread>
    8000426a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000426c:	03492683          	lw	a3,52(s2)
    80004270:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004272:	02d05763          	blez	a3,800042a0 <write_head+0x5a>
    80004276:	0001e797          	auipc	a5,0x1e
    8000427a:	5aa78793          	addi	a5,a5,1450 # 80022820 <log+0x38>
    8000427e:	06450713          	addi	a4,a0,100
    80004282:	36fd                	addiw	a3,a3,-1
    80004284:	1682                	slli	a3,a3,0x20
    80004286:	9281                	srli	a3,a3,0x20
    80004288:	068a                	slli	a3,a3,0x2
    8000428a:	0001e617          	auipc	a2,0x1e
    8000428e:	59a60613          	addi	a2,a2,1434 # 80022824 <log+0x3c>
    80004292:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004294:	4390                	lw	a2,0(a5)
    80004296:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004298:	0791                	addi	a5,a5,4
    8000429a:	0711                	addi	a4,a4,4
    8000429c:	fed79ce3          	bne	a5,a3,80004294 <write_head+0x4e>
  }
  bwrite(buf);
    800042a0:	8526                	mv	a0,s1
    800042a2:	fffff097          	auipc	ra,0xfffff
    800042a6:	0a6080e7          	jalr	166(ra) # 80003348 <bwrite>
  brelse(buf);
    800042aa:	8526                	mv	a0,s1
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	0da080e7          	jalr	218(ra) # 80003386 <brelse>
}
    800042b4:	60e2                	ld	ra,24(sp)
    800042b6:	6442                	ld	s0,16(sp)
    800042b8:	64a2                	ld	s1,8(sp)
    800042ba:	6902                	ld	s2,0(sp)
    800042bc:	6105                	addi	sp,sp,32
    800042be:	8082                	ret

00000000800042c0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800042c0:	0001e797          	auipc	a5,0x1e
    800042c4:	55c7a783          	lw	a5,1372(a5) # 8002281c <log+0x34>
    800042c8:	0af05d63          	blez	a5,80004382 <install_trans+0xc2>
{
    800042cc:	7139                	addi	sp,sp,-64
    800042ce:	fc06                	sd	ra,56(sp)
    800042d0:	f822                	sd	s0,48(sp)
    800042d2:	f426                	sd	s1,40(sp)
    800042d4:	f04a                	sd	s2,32(sp)
    800042d6:	ec4e                	sd	s3,24(sp)
    800042d8:	e852                	sd	s4,16(sp)
    800042da:	e456                	sd	s5,8(sp)
    800042dc:	e05a                	sd	s6,0(sp)
    800042de:	0080                	addi	s0,sp,64
    800042e0:	8b2a                	mv	s6,a0
    800042e2:	0001ea97          	auipc	s5,0x1e
    800042e6:	53ea8a93          	addi	s5,s5,1342 # 80022820 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ea:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042ec:	0001e997          	auipc	s3,0x1e
    800042f0:	4fc98993          	addi	s3,s3,1276 # 800227e8 <log>
    800042f4:	a035                	j	80004320 <install_trans+0x60>
      bunpin(dbuf);
    800042f6:	8526                	mv	a0,s1
    800042f8:	fffff097          	auipc	ra,0xfffff
    800042fc:	168080e7          	jalr	360(ra) # 80003460 <bunpin>
    brelse(lbuf);
    80004300:	854a                	mv	a0,s2
    80004302:	fffff097          	auipc	ra,0xfffff
    80004306:	084080e7          	jalr	132(ra) # 80003386 <brelse>
    brelse(dbuf);
    8000430a:	8526                	mv	a0,s1
    8000430c:	fffff097          	auipc	ra,0xfffff
    80004310:	07a080e7          	jalr	122(ra) # 80003386 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004314:	2a05                	addiw	s4,s4,1
    80004316:	0a91                	addi	s5,s5,4
    80004318:	0349a783          	lw	a5,52(s3)
    8000431c:	04fa5963          	bge	s4,a5,8000436e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004320:	0209a583          	lw	a1,32(s3)
    80004324:	014585bb          	addw	a1,a1,s4
    80004328:	2585                	addiw	a1,a1,1
    8000432a:	0309a503          	lw	a0,48(s3)
    8000432e:	fffff097          	auipc	ra,0xfffff
    80004332:	f28080e7          	jalr	-216(ra) # 80003256 <bread>
    80004336:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004338:	000aa583          	lw	a1,0(s5)
    8000433c:	0309a503          	lw	a0,48(s3)
    80004340:	fffff097          	auipc	ra,0xfffff
    80004344:	f16080e7          	jalr	-234(ra) # 80003256 <bread>
    80004348:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000434a:	40000613          	li	a2,1024
    8000434e:	06090593          	addi	a1,s2,96
    80004352:	06050513          	addi	a0,a0,96
    80004356:	ffffd097          	auipc	ra,0xffffd
    8000435a:	ecc080e7          	jalr	-308(ra) # 80001222 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000435e:	8526                	mv	a0,s1
    80004360:	fffff097          	auipc	ra,0xfffff
    80004364:	fe8080e7          	jalr	-24(ra) # 80003348 <bwrite>
    if(recovering == 0)
    80004368:	f80b1ce3          	bnez	s6,80004300 <install_trans+0x40>
    8000436c:	b769                	j	800042f6 <install_trans+0x36>
}
    8000436e:	70e2                	ld	ra,56(sp)
    80004370:	7442                	ld	s0,48(sp)
    80004372:	74a2                	ld	s1,40(sp)
    80004374:	7902                	ld	s2,32(sp)
    80004376:	69e2                	ld	s3,24(sp)
    80004378:	6a42                	ld	s4,16(sp)
    8000437a:	6aa2                	ld	s5,8(sp)
    8000437c:	6b02                	ld	s6,0(sp)
    8000437e:	6121                	addi	sp,sp,64
    80004380:	8082                	ret
    80004382:	8082                	ret

0000000080004384 <initlog>:
{
    80004384:	7179                	addi	sp,sp,-48
    80004386:	f406                	sd	ra,40(sp)
    80004388:	f022                	sd	s0,32(sp)
    8000438a:	ec26                	sd	s1,24(sp)
    8000438c:	e84a                	sd	s2,16(sp)
    8000438e:	e44e                	sd	s3,8(sp)
    80004390:	1800                	addi	s0,sp,48
    80004392:	892a                	mv	s2,a0
    80004394:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004396:	0001e497          	auipc	s1,0x1e
    8000439a:	45248493          	addi	s1,s1,1106 # 800227e8 <log>
    8000439e:	00004597          	auipc	a1,0x4
    800043a2:	2ea58593          	addi	a1,a1,746 # 80008688 <syscalls+0x1d0>
    800043a6:	8526                	mv	a0,s1
    800043a8:	ffffd097          	auipc	ra,0xffffd
    800043ac:	bb6080e7          	jalr	-1098(ra) # 80000f5e <initlock>
  log.start = sb->logstart;
    800043b0:	0149a583          	lw	a1,20(s3)
    800043b4:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    800043b6:	0109a783          	lw	a5,16(s3)
    800043ba:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    800043bc:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    800043c0:	854a                	mv	a0,s2
    800043c2:	fffff097          	auipc	ra,0xfffff
    800043c6:	e94080e7          	jalr	-364(ra) # 80003256 <bread>
  log.lh.n = lh->n;
    800043ca:	513c                	lw	a5,96(a0)
    800043cc:	d8dc                	sw	a5,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    800043ce:	02f05563          	blez	a5,800043f8 <initlog+0x74>
    800043d2:	06450713          	addi	a4,a0,100
    800043d6:	0001e697          	auipc	a3,0x1e
    800043da:	44a68693          	addi	a3,a3,1098 # 80022820 <log+0x38>
    800043de:	37fd                	addiw	a5,a5,-1
    800043e0:	1782                	slli	a5,a5,0x20
    800043e2:	9381                	srli	a5,a5,0x20
    800043e4:	078a                	slli	a5,a5,0x2
    800043e6:	06850613          	addi	a2,a0,104
    800043ea:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800043ec:	4310                	lw	a2,0(a4)
    800043ee:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800043f0:	0711                	addi	a4,a4,4
    800043f2:	0691                	addi	a3,a3,4
    800043f4:	fef71ce3          	bne	a4,a5,800043ec <initlog+0x68>
  brelse(buf);
    800043f8:	fffff097          	auipc	ra,0xfffff
    800043fc:	f8e080e7          	jalr	-114(ra) # 80003386 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004400:	4505                	li	a0,1
    80004402:	00000097          	auipc	ra,0x0
    80004406:	ebe080e7          	jalr	-322(ra) # 800042c0 <install_trans>
  log.lh.n = 0;
    8000440a:	0001e797          	auipc	a5,0x1e
    8000440e:	4007a923          	sw	zero,1042(a5) # 8002281c <log+0x34>
  write_head(); // clear the log
    80004412:	00000097          	auipc	ra,0x0
    80004416:	e34080e7          	jalr	-460(ra) # 80004246 <write_head>
}
    8000441a:	70a2                	ld	ra,40(sp)
    8000441c:	7402                	ld	s0,32(sp)
    8000441e:	64e2                	ld	s1,24(sp)
    80004420:	6942                	ld	s2,16(sp)
    80004422:	69a2                	ld	s3,8(sp)
    80004424:	6145                	addi	sp,sp,48
    80004426:	8082                	ret

0000000080004428 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004428:	1101                	addi	sp,sp,-32
    8000442a:	ec06                	sd	ra,24(sp)
    8000442c:	e822                	sd	s0,16(sp)
    8000442e:	e426                	sd	s1,8(sp)
    80004430:	e04a                	sd	s2,0(sp)
    80004432:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004434:	0001e517          	auipc	a0,0x1e
    80004438:	3b450513          	addi	a0,a0,948 # 800227e8 <log>
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	9a6080e7          	jalr	-1626(ra) # 80000de2 <acquire>
  while(1){
    if(log.committing){
    80004444:	0001e497          	auipc	s1,0x1e
    80004448:	3a448493          	addi	s1,s1,932 # 800227e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000444c:	4979                	li	s2,30
    8000444e:	a039                	j	8000445c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004450:	85a6                	mv	a1,s1
    80004452:	8526                	mv	a0,s1
    80004454:	ffffe097          	auipc	ra,0xffffe
    80004458:	1e6080e7          	jalr	486(ra) # 8000263a <sleep>
    if(log.committing){
    8000445c:	54dc                	lw	a5,44(s1)
    8000445e:	fbed                	bnez	a5,80004450 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004460:	549c                	lw	a5,40(s1)
    80004462:	0017871b          	addiw	a4,a5,1
    80004466:	0007069b          	sext.w	a3,a4
    8000446a:	0027179b          	slliw	a5,a4,0x2
    8000446e:	9fb9                	addw	a5,a5,a4
    80004470:	0017979b          	slliw	a5,a5,0x1
    80004474:	58d8                	lw	a4,52(s1)
    80004476:	9fb9                	addw	a5,a5,a4
    80004478:	00f95963          	bge	s2,a5,8000448a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000447c:	85a6                	mv	a1,s1
    8000447e:	8526                	mv	a0,s1
    80004480:	ffffe097          	auipc	ra,0xffffe
    80004484:	1ba080e7          	jalr	442(ra) # 8000263a <sleep>
    80004488:	bfd1                	j	8000445c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000448a:	0001e517          	auipc	a0,0x1e
    8000448e:	35e50513          	addi	a0,a0,862 # 800227e8 <log>
    80004492:	d514                	sw	a3,40(a0)
      release(&log.lock);
    80004494:	ffffd097          	auipc	ra,0xffffd
    80004498:	a1e080e7          	jalr	-1506(ra) # 80000eb2 <release>
      break;
    }
  }
}
    8000449c:	60e2                	ld	ra,24(sp)
    8000449e:	6442                	ld	s0,16(sp)
    800044a0:	64a2                	ld	s1,8(sp)
    800044a2:	6902                	ld	s2,0(sp)
    800044a4:	6105                	addi	sp,sp,32
    800044a6:	8082                	ret

00000000800044a8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800044a8:	7139                	addi	sp,sp,-64
    800044aa:	fc06                	sd	ra,56(sp)
    800044ac:	f822                	sd	s0,48(sp)
    800044ae:	f426                	sd	s1,40(sp)
    800044b0:	f04a                	sd	s2,32(sp)
    800044b2:	ec4e                	sd	s3,24(sp)
    800044b4:	e852                	sd	s4,16(sp)
    800044b6:	e456                	sd	s5,8(sp)
    800044b8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800044ba:	0001e497          	auipc	s1,0x1e
    800044be:	32e48493          	addi	s1,s1,814 # 800227e8 <log>
    800044c2:	8526                	mv	a0,s1
    800044c4:	ffffd097          	auipc	ra,0xffffd
    800044c8:	91e080e7          	jalr	-1762(ra) # 80000de2 <acquire>
  log.outstanding -= 1;
    800044cc:	549c                	lw	a5,40(s1)
    800044ce:	37fd                	addiw	a5,a5,-1
    800044d0:	0007891b          	sext.w	s2,a5
    800044d4:	d49c                	sw	a5,40(s1)
  if(log.committing)
    800044d6:	54dc                	lw	a5,44(s1)
    800044d8:	efb9                	bnez	a5,80004536 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800044da:	06091663          	bnez	s2,80004546 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800044de:	0001e497          	auipc	s1,0x1e
    800044e2:	30a48493          	addi	s1,s1,778 # 800227e8 <log>
    800044e6:	4785                	li	a5,1
    800044e8:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800044ea:	8526                	mv	a0,s1
    800044ec:	ffffd097          	auipc	ra,0xffffd
    800044f0:	9c6080e7          	jalr	-1594(ra) # 80000eb2 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800044f4:	58dc                	lw	a5,52(s1)
    800044f6:	06f04763          	bgtz	a5,80004564 <end_op+0xbc>
    acquire(&log.lock);
    800044fa:	0001e497          	auipc	s1,0x1e
    800044fe:	2ee48493          	addi	s1,s1,750 # 800227e8 <log>
    80004502:	8526                	mv	a0,s1
    80004504:	ffffd097          	auipc	ra,0xffffd
    80004508:	8de080e7          	jalr	-1826(ra) # 80000de2 <acquire>
    log.committing = 0;
    8000450c:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    80004510:	8526                	mv	a0,s1
    80004512:	ffffe097          	auipc	ra,0xffffe
    80004516:	2ae080e7          	jalr	686(ra) # 800027c0 <wakeup>
    release(&log.lock);
    8000451a:	8526                	mv	a0,s1
    8000451c:	ffffd097          	auipc	ra,0xffffd
    80004520:	996080e7          	jalr	-1642(ra) # 80000eb2 <release>
}
    80004524:	70e2                	ld	ra,56(sp)
    80004526:	7442                	ld	s0,48(sp)
    80004528:	74a2                	ld	s1,40(sp)
    8000452a:	7902                	ld	s2,32(sp)
    8000452c:	69e2                	ld	s3,24(sp)
    8000452e:	6a42                	ld	s4,16(sp)
    80004530:	6aa2                	ld	s5,8(sp)
    80004532:	6121                	addi	sp,sp,64
    80004534:	8082                	ret
    panic("log.committing");
    80004536:	00004517          	auipc	a0,0x4
    8000453a:	15a50513          	addi	a0,a0,346 # 80008690 <syscalls+0x1d8>
    8000453e:	ffffc097          	auipc	ra,0xffffc
    80004542:	012080e7          	jalr	18(ra) # 80000550 <panic>
    wakeup(&log);
    80004546:	0001e497          	auipc	s1,0x1e
    8000454a:	2a248493          	addi	s1,s1,674 # 800227e8 <log>
    8000454e:	8526                	mv	a0,s1
    80004550:	ffffe097          	auipc	ra,0xffffe
    80004554:	270080e7          	jalr	624(ra) # 800027c0 <wakeup>
  release(&log.lock);
    80004558:	8526                	mv	a0,s1
    8000455a:	ffffd097          	auipc	ra,0xffffd
    8000455e:	958080e7          	jalr	-1704(ra) # 80000eb2 <release>
  if(do_commit){
    80004562:	b7c9                	j	80004524 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004564:	0001ea97          	auipc	s5,0x1e
    80004568:	2bca8a93          	addi	s5,s5,700 # 80022820 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000456c:	0001ea17          	auipc	s4,0x1e
    80004570:	27ca0a13          	addi	s4,s4,636 # 800227e8 <log>
    80004574:	020a2583          	lw	a1,32(s4)
    80004578:	012585bb          	addw	a1,a1,s2
    8000457c:	2585                	addiw	a1,a1,1
    8000457e:	030a2503          	lw	a0,48(s4)
    80004582:	fffff097          	auipc	ra,0xfffff
    80004586:	cd4080e7          	jalr	-812(ra) # 80003256 <bread>
    8000458a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000458c:	000aa583          	lw	a1,0(s5)
    80004590:	030a2503          	lw	a0,48(s4)
    80004594:	fffff097          	auipc	ra,0xfffff
    80004598:	cc2080e7          	jalr	-830(ra) # 80003256 <bread>
    8000459c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000459e:	40000613          	li	a2,1024
    800045a2:	06050593          	addi	a1,a0,96
    800045a6:	06048513          	addi	a0,s1,96
    800045aa:	ffffd097          	auipc	ra,0xffffd
    800045ae:	c78080e7          	jalr	-904(ra) # 80001222 <memmove>
    bwrite(to);  // write the log
    800045b2:	8526                	mv	a0,s1
    800045b4:	fffff097          	auipc	ra,0xfffff
    800045b8:	d94080e7          	jalr	-620(ra) # 80003348 <bwrite>
    brelse(from);
    800045bc:	854e                	mv	a0,s3
    800045be:	fffff097          	auipc	ra,0xfffff
    800045c2:	dc8080e7          	jalr	-568(ra) # 80003386 <brelse>
    brelse(to);
    800045c6:	8526                	mv	a0,s1
    800045c8:	fffff097          	auipc	ra,0xfffff
    800045cc:	dbe080e7          	jalr	-578(ra) # 80003386 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045d0:	2905                	addiw	s2,s2,1
    800045d2:	0a91                	addi	s5,s5,4
    800045d4:	034a2783          	lw	a5,52(s4)
    800045d8:	f8f94ee3          	blt	s2,a5,80004574 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800045dc:	00000097          	auipc	ra,0x0
    800045e0:	c6a080e7          	jalr	-918(ra) # 80004246 <write_head>
    install_trans(0); // Now install writes to home locations
    800045e4:	4501                	li	a0,0
    800045e6:	00000097          	auipc	ra,0x0
    800045ea:	cda080e7          	jalr	-806(ra) # 800042c0 <install_trans>
    log.lh.n = 0;
    800045ee:	0001e797          	auipc	a5,0x1e
    800045f2:	2207a723          	sw	zero,558(a5) # 8002281c <log+0x34>
    write_head();    // Erase the transaction from the log
    800045f6:	00000097          	auipc	ra,0x0
    800045fa:	c50080e7          	jalr	-944(ra) # 80004246 <write_head>
    800045fe:	bdf5                	j	800044fa <end_op+0x52>

0000000080004600 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004600:	1101                	addi	sp,sp,-32
    80004602:	ec06                	sd	ra,24(sp)
    80004604:	e822                	sd	s0,16(sp)
    80004606:	e426                	sd	s1,8(sp)
    80004608:	e04a                	sd	s2,0(sp)
    8000460a:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000460c:	0001e717          	auipc	a4,0x1e
    80004610:	21072703          	lw	a4,528(a4) # 8002281c <log+0x34>
    80004614:	47f5                	li	a5,29
    80004616:	08e7c063          	blt	a5,a4,80004696 <log_write+0x96>
    8000461a:	84aa                	mv	s1,a0
    8000461c:	0001e797          	auipc	a5,0x1e
    80004620:	1f07a783          	lw	a5,496(a5) # 8002280c <log+0x24>
    80004624:	37fd                	addiw	a5,a5,-1
    80004626:	06f75863          	bge	a4,a5,80004696 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000462a:	0001e797          	auipc	a5,0x1e
    8000462e:	1e67a783          	lw	a5,486(a5) # 80022810 <log+0x28>
    80004632:	06f05a63          	blez	a5,800046a6 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004636:	0001e917          	auipc	s2,0x1e
    8000463a:	1b290913          	addi	s2,s2,434 # 800227e8 <log>
    8000463e:	854a                	mv	a0,s2
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	7a2080e7          	jalr	1954(ra) # 80000de2 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004648:	03492603          	lw	a2,52(s2)
    8000464c:	06c05563          	blez	a2,800046b6 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004650:	44cc                	lw	a1,12(s1)
    80004652:	0001e717          	auipc	a4,0x1e
    80004656:	1ce70713          	addi	a4,a4,462 # 80022820 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    8000465a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000465c:	4314                	lw	a3,0(a4)
    8000465e:	04b68d63          	beq	a3,a1,800046b8 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004662:	2785                	addiw	a5,a5,1
    80004664:	0711                	addi	a4,a4,4
    80004666:	fec79be3          	bne	a5,a2,8000465c <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000466a:	0631                	addi	a2,a2,12
    8000466c:	060a                	slli	a2,a2,0x2
    8000466e:	0001e797          	auipc	a5,0x1e
    80004672:	17a78793          	addi	a5,a5,378 # 800227e8 <log>
    80004676:	963e                	add	a2,a2,a5
    80004678:	44dc                	lw	a5,12(s1)
    8000467a:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000467c:	8526                	mv	a0,s1
    8000467e:	fffff097          	auipc	ra,0xfffff
    80004682:	da6080e7          	jalr	-602(ra) # 80003424 <bpin>
    log.lh.n++;
    80004686:	0001e717          	auipc	a4,0x1e
    8000468a:	16270713          	addi	a4,a4,354 # 800227e8 <log>
    8000468e:	5b5c                	lw	a5,52(a4)
    80004690:	2785                	addiw	a5,a5,1
    80004692:	db5c                	sw	a5,52(a4)
    80004694:	a83d                	j	800046d2 <log_write+0xd2>
    panic("too big a transaction");
    80004696:	00004517          	auipc	a0,0x4
    8000469a:	00a50513          	addi	a0,a0,10 # 800086a0 <syscalls+0x1e8>
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	eb2080e7          	jalr	-334(ra) # 80000550 <panic>
    panic("log_write outside of trans");
    800046a6:	00004517          	auipc	a0,0x4
    800046aa:	01250513          	addi	a0,a0,18 # 800086b8 <syscalls+0x200>
    800046ae:	ffffc097          	auipc	ra,0xffffc
    800046b2:	ea2080e7          	jalr	-350(ra) # 80000550 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800046b6:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800046b8:	00c78713          	addi	a4,a5,12
    800046bc:	00271693          	slli	a3,a4,0x2
    800046c0:	0001e717          	auipc	a4,0x1e
    800046c4:	12870713          	addi	a4,a4,296 # 800227e8 <log>
    800046c8:	9736                	add	a4,a4,a3
    800046ca:	44d4                	lw	a3,12(s1)
    800046cc:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800046ce:	faf607e3          	beq	a2,a5,8000467c <log_write+0x7c>
  }
  release(&log.lock);
    800046d2:	0001e517          	auipc	a0,0x1e
    800046d6:	11650513          	addi	a0,a0,278 # 800227e8 <log>
    800046da:	ffffc097          	auipc	ra,0xffffc
    800046de:	7d8080e7          	jalr	2008(ra) # 80000eb2 <release>
}
    800046e2:	60e2                	ld	ra,24(sp)
    800046e4:	6442                	ld	s0,16(sp)
    800046e6:	64a2                	ld	s1,8(sp)
    800046e8:	6902                	ld	s2,0(sp)
    800046ea:	6105                	addi	sp,sp,32
    800046ec:	8082                	ret

00000000800046ee <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800046ee:	1101                	addi	sp,sp,-32
    800046f0:	ec06                	sd	ra,24(sp)
    800046f2:	e822                	sd	s0,16(sp)
    800046f4:	e426                	sd	s1,8(sp)
    800046f6:	e04a                	sd	s2,0(sp)
    800046f8:	1000                	addi	s0,sp,32
    800046fa:	84aa                	mv	s1,a0
    800046fc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800046fe:	00004597          	auipc	a1,0x4
    80004702:	fda58593          	addi	a1,a1,-38 # 800086d8 <syscalls+0x220>
    80004706:	0521                	addi	a0,a0,8
    80004708:	ffffd097          	auipc	ra,0xffffd
    8000470c:	856080e7          	jalr	-1962(ra) # 80000f5e <initlock>
  lk->name = name;
    80004710:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004714:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004718:	0204a823          	sw	zero,48(s1)
}
    8000471c:	60e2                	ld	ra,24(sp)
    8000471e:	6442                	ld	s0,16(sp)
    80004720:	64a2                	ld	s1,8(sp)
    80004722:	6902                	ld	s2,0(sp)
    80004724:	6105                	addi	sp,sp,32
    80004726:	8082                	ret

0000000080004728 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004728:	1101                	addi	sp,sp,-32
    8000472a:	ec06                	sd	ra,24(sp)
    8000472c:	e822                	sd	s0,16(sp)
    8000472e:	e426                	sd	s1,8(sp)
    80004730:	e04a                	sd	s2,0(sp)
    80004732:	1000                	addi	s0,sp,32
    80004734:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004736:	00850913          	addi	s2,a0,8
    8000473a:	854a                	mv	a0,s2
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	6a6080e7          	jalr	1702(ra) # 80000de2 <acquire>
  while (lk->locked) {
    80004744:	409c                	lw	a5,0(s1)
    80004746:	cb89                	beqz	a5,80004758 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004748:	85ca                	mv	a1,s2
    8000474a:	8526                	mv	a0,s1
    8000474c:	ffffe097          	auipc	ra,0xffffe
    80004750:	eee080e7          	jalr	-274(ra) # 8000263a <sleep>
  while (lk->locked) {
    80004754:	409c                	lw	a5,0(s1)
    80004756:	fbed                	bnez	a5,80004748 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004758:	4785                	li	a5,1
    8000475a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000475c:	ffffd097          	auipc	ra,0xffffd
    80004760:	6ce080e7          	jalr	1742(ra) # 80001e2a <myproc>
    80004764:	413c                	lw	a5,64(a0)
    80004766:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    80004768:	854a                	mv	a0,s2
    8000476a:	ffffc097          	auipc	ra,0xffffc
    8000476e:	748080e7          	jalr	1864(ra) # 80000eb2 <release>
}
    80004772:	60e2                	ld	ra,24(sp)
    80004774:	6442                	ld	s0,16(sp)
    80004776:	64a2                	ld	s1,8(sp)
    80004778:	6902                	ld	s2,0(sp)
    8000477a:	6105                	addi	sp,sp,32
    8000477c:	8082                	ret

000000008000477e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000477e:	1101                	addi	sp,sp,-32
    80004780:	ec06                	sd	ra,24(sp)
    80004782:	e822                	sd	s0,16(sp)
    80004784:	e426                	sd	s1,8(sp)
    80004786:	e04a                	sd	s2,0(sp)
    80004788:	1000                	addi	s0,sp,32
    8000478a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000478c:	00850913          	addi	s2,a0,8
    80004790:	854a                	mv	a0,s2
    80004792:	ffffc097          	auipc	ra,0xffffc
    80004796:	650080e7          	jalr	1616(ra) # 80000de2 <acquire>
  lk->locked = 0;
    8000479a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000479e:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800047a2:	8526                	mv	a0,s1
    800047a4:	ffffe097          	auipc	ra,0xffffe
    800047a8:	01c080e7          	jalr	28(ra) # 800027c0 <wakeup>
  release(&lk->lk);
    800047ac:	854a                	mv	a0,s2
    800047ae:	ffffc097          	auipc	ra,0xffffc
    800047b2:	704080e7          	jalr	1796(ra) # 80000eb2 <release>
}
    800047b6:	60e2                	ld	ra,24(sp)
    800047b8:	6442                	ld	s0,16(sp)
    800047ba:	64a2                	ld	s1,8(sp)
    800047bc:	6902                	ld	s2,0(sp)
    800047be:	6105                	addi	sp,sp,32
    800047c0:	8082                	ret

00000000800047c2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800047c2:	7179                	addi	sp,sp,-48
    800047c4:	f406                	sd	ra,40(sp)
    800047c6:	f022                	sd	s0,32(sp)
    800047c8:	ec26                	sd	s1,24(sp)
    800047ca:	e84a                	sd	s2,16(sp)
    800047cc:	e44e                	sd	s3,8(sp)
    800047ce:	1800                	addi	s0,sp,48
    800047d0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800047d2:	00850913          	addi	s2,a0,8
    800047d6:	854a                	mv	a0,s2
    800047d8:	ffffc097          	auipc	ra,0xffffc
    800047dc:	60a080e7          	jalr	1546(ra) # 80000de2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800047e0:	409c                	lw	a5,0(s1)
    800047e2:	ef99                	bnez	a5,80004800 <holdingsleep+0x3e>
    800047e4:	4481                	li	s1,0
  release(&lk->lk);
    800047e6:	854a                	mv	a0,s2
    800047e8:	ffffc097          	auipc	ra,0xffffc
    800047ec:	6ca080e7          	jalr	1738(ra) # 80000eb2 <release>
  return r;
}
    800047f0:	8526                	mv	a0,s1
    800047f2:	70a2                	ld	ra,40(sp)
    800047f4:	7402                	ld	s0,32(sp)
    800047f6:	64e2                	ld	s1,24(sp)
    800047f8:	6942                	ld	s2,16(sp)
    800047fa:	69a2                	ld	s3,8(sp)
    800047fc:	6145                	addi	sp,sp,48
    800047fe:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004800:	0304a983          	lw	s3,48(s1)
    80004804:	ffffd097          	auipc	ra,0xffffd
    80004808:	626080e7          	jalr	1574(ra) # 80001e2a <myproc>
    8000480c:	4124                	lw	s1,64(a0)
    8000480e:	413484b3          	sub	s1,s1,s3
    80004812:	0014b493          	seqz	s1,s1
    80004816:	bfc1                	j	800047e6 <holdingsleep+0x24>

0000000080004818 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004818:	1141                	addi	sp,sp,-16
    8000481a:	e406                	sd	ra,8(sp)
    8000481c:	e022                	sd	s0,0(sp)
    8000481e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004820:	00004597          	auipc	a1,0x4
    80004824:	ec858593          	addi	a1,a1,-312 # 800086e8 <syscalls+0x230>
    80004828:	0001e517          	auipc	a0,0x1e
    8000482c:	11050513          	addi	a0,a0,272 # 80022938 <ftable>
    80004830:	ffffc097          	auipc	ra,0xffffc
    80004834:	72e080e7          	jalr	1838(ra) # 80000f5e <initlock>
}
    80004838:	60a2                	ld	ra,8(sp)
    8000483a:	6402                	ld	s0,0(sp)
    8000483c:	0141                	addi	sp,sp,16
    8000483e:	8082                	ret

0000000080004840 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004840:	1101                	addi	sp,sp,-32
    80004842:	ec06                	sd	ra,24(sp)
    80004844:	e822                	sd	s0,16(sp)
    80004846:	e426                	sd	s1,8(sp)
    80004848:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000484a:	0001e517          	auipc	a0,0x1e
    8000484e:	0ee50513          	addi	a0,a0,238 # 80022938 <ftable>
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	590080e7          	jalr	1424(ra) # 80000de2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000485a:	0001e497          	auipc	s1,0x1e
    8000485e:	0fe48493          	addi	s1,s1,254 # 80022958 <ftable+0x20>
    80004862:	0001f717          	auipc	a4,0x1f
    80004866:	09670713          	addi	a4,a4,150 # 800238f8 <ftable+0xfc0>
    if(f->ref == 0){
    8000486a:	40dc                	lw	a5,4(s1)
    8000486c:	cf99                	beqz	a5,8000488a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000486e:	02848493          	addi	s1,s1,40
    80004872:	fee49ce3          	bne	s1,a4,8000486a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004876:	0001e517          	auipc	a0,0x1e
    8000487a:	0c250513          	addi	a0,a0,194 # 80022938 <ftable>
    8000487e:	ffffc097          	auipc	ra,0xffffc
    80004882:	634080e7          	jalr	1588(ra) # 80000eb2 <release>
  return 0;
    80004886:	4481                	li	s1,0
    80004888:	a819                	j	8000489e <filealloc+0x5e>
      f->ref = 1;
    8000488a:	4785                	li	a5,1
    8000488c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000488e:	0001e517          	auipc	a0,0x1e
    80004892:	0aa50513          	addi	a0,a0,170 # 80022938 <ftable>
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	61c080e7          	jalr	1564(ra) # 80000eb2 <release>
}
    8000489e:	8526                	mv	a0,s1
    800048a0:	60e2                	ld	ra,24(sp)
    800048a2:	6442                	ld	s0,16(sp)
    800048a4:	64a2                	ld	s1,8(sp)
    800048a6:	6105                	addi	sp,sp,32
    800048a8:	8082                	ret

00000000800048aa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800048aa:	1101                	addi	sp,sp,-32
    800048ac:	ec06                	sd	ra,24(sp)
    800048ae:	e822                	sd	s0,16(sp)
    800048b0:	e426                	sd	s1,8(sp)
    800048b2:	1000                	addi	s0,sp,32
    800048b4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800048b6:	0001e517          	auipc	a0,0x1e
    800048ba:	08250513          	addi	a0,a0,130 # 80022938 <ftable>
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	524080e7          	jalr	1316(ra) # 80000de2 <acquire>
  if(f->ref < 1)
    800048c6:	40dc                	lw	a5,4(s1)
    800048c8:	02f05263          	blez	a5,800048ec <filedup+0x42>
    panic("filedup");
  f->ref++;
    800048cc:	2785                	addiw	a5,a5,1
    800048ce:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800048d0:	0001e517          	auipc	a0,0x1e
    800048d4:	06850513          	addi	a0,a0,104 # 80022938 <ftable>
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	5da080e7          	jalr	1498(ra) # 80000eb2 <release>
  return f;
}
    800048e0:	8526                	mv	a0,s1
    800048e2:	60e2                	ld	ra,24(sp)
    800048e4:	6442                	ld	s0,16(sp)
    800048e6:	64a2                	ld	s1,8(sp)
    800048e8:	6105                	addi	sp,sp,32
    800048ea:	8082                	ret
    panic("filedup");
    800048ec:	00004517          	auipc	a0,0x4
    800048f0:	e0450513          	addi	a0,a0,-508 # 800086f0 <syscalls+0x238>
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	c5c080e7          	jalr	-932(ra) # 80000550 <panic>

00000000800048fc <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800048fc:	7139                	addi	sp,sp,-64
    800048fe:	fc06                	sd	ra,56(sp)
    80004900:	f822                	sd	s0,48(sp)
    80004902:	f426                	sd	s1,40(sp)
    80004904:	f04a                	sd	s2,32(sp)
    80004906:	ec4e                	sd	s3,24(sp)
    80004908:	e852                	sd	s4,16(sp)
    8000490a:	e456                	sd	s5,8(sp)
    8000490c:	0080                	addi	s0,sp,64
    8000490e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004910:	0001e517          	auipc	a0,0x1e
    80004914:	02850513          	addi	a0,a0,40 # 80022938 <ftable>
    80004918:	ffffc097          	auipc	ra,0xffffc
    8000491c:	4ca080e7          	jalr	1226(ra) # 80000de2 <acquire>
  if(f->ref < 1)
    80004920:	40dc                	lw	a5,4(s1)
    80004922:	06f05163          	blez	a5,80004984 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004926:	37fd                	addiw	a5,a5,-1
    80004928:	0007871b          	sext.w	a4,a5
    8000492c:	c0dc                	sw	a5,4(s1)
    8000492e:	06e04363          	bgtz	a4,80004994 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004932:	0004a903          	lw	s2,0(s1)
    80004936:	0094ca83          	lbu	s5,9(s1)
    8000493a:	0104ba03          	ld	s4,16(s1)
    8000493e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004942:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004946:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000494a:	0001e517          	auipc	a0,0x1e
    8000494e:	fee50513          	addi	a0,a0,-18 # 80022938 <ftable>
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	560080e7          	jalr	1376(ra) # 80000eb2 <release>

  if(ff.type == FD_PIPE){
    8000495a:	4785                	li	a5,1
    8000495c:	04f90d63          	beq	s2,a5,800049b6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004960:	3979                	addiw	s2,s2,-2
    80004962:	4785                	li	a5,1
    80004964:	0527e063          	bltu	a5,s2,800049a4 <fileclose+0xa8>
    begin_op();
    80004968:	00000097          	auipc	ra,0x0
    8000496c:	ac0080e7          	jalr	-1344(ra) # 80004428 <begin_op>
    iput(ff.ip);
    80004970:	854e                	mv	a0,s3
    80004972:	fffff097          	auipc	ra,0xfffff
    80004976:	2a0080e7          	jalr	672(ra) # 80003c12 <iput>
    end_op();
    8000497a:	00000097          	auipc	ra,0x0
    8000497e:	b2e080e7          	jalr	-1234(ra) # 800044a8 <end_op>
    80004982:	a00d                	j	800049a4 <fileclose+0xa8>
    panic("fileclose");
    80004984:	00004517          	auipc	a0,0x4
    80004988:	d7450513          	addi	a0,a0,-652 # 800086f8 <syscalls+0x240>
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	bc4080e7          	jalr	-1084(ra) # 80000550 <panic>
    release(&ftable.lock);
    80004994:	0001e517          	auipc	a0,0x1e
    80004998:	fa450513          	addi	a0,a0,-92 # 80022938 <ftable>
    8000499c:	ffffc097          	auipc	ra,0xffffc
    800049a0:	516080e7          	jalr	1302(ra) # 80000eb2 <release>
  }
}
    800049a4:	70e2                	ld	ra,56(sp)
    800049a6:	7442                	ld	s0,48(sp)
    800049a8:	74a2                	ld	s1,40(sp)
    800049aa:	7902                	ld	s2,32(sp)
    800049ac:	69e2                	ld	s3,24(sp)
    800049ae:	6a42                	ld	s4,16(sp)
    800049b0:	6aa2                	ld	s5,8(sp)
    800049b2:	6121                	addi	sp,sp,64
    800049b4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800049b6:	85d6                	mv	a1,s5
    800049b8:	8552                	mv	a0,s4
    800049ba:	00000097          	auipc	ra,0x0
    800049be:	372080e7          	jalr	882(ra) # 80004d2c <pipeclose>
    800049c2:	b7cd                	j	800049a4 <fileclose+0xa8>

00000000800049c4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800049c4:	715d                	addi	sp,sp,-80
    800049c6:	e486                	sd	ra,72(sp)
    800049c8:	e0a2                	sd	s0,64(sp)
    800049ca:	fc26                	sd	s1,56(sp)
    800049cc:	f84a                	sd	s2,48(sp)
    800049ce:	f44e                	sd	s3,40(sp)
    800049d0:	0880                	addi	s0,sp,80
    800049d2:	84aa                	mv	s1,a0
    800049d4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800049d6:	ffffd097          	auipc	ra,0xffffd
    800049da:	454080e7          	jalr	1108(ra) # 80001e2a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800049de:	409c                	lw	a5,0(s1)
    800049e0:	37f9                	addiw	a5,a5,-2
    800049e2:	4705                	li	a4,1
    800049e4:	04f76763          	bltu	a4,a5,80004a32 <filestat+0x6e>
    800049e8:	892a                	mv	s2,a0
    ilock(f->ip);
    800049ea:	6c88                	ld	a0,24(s1)
    800049ec:	fffff097          	auipc	ra,0xfffff
    800049f0:	06c080e7          	jalr	108(ra) # 80003a58 <ilock>
    stati(f->ip, &st);
    800049f4:	fb840593          	addi	a1,s0,-72
    800049f8:	6c88                	ld	a0,24(s1)
    800049fa:	fffff097          	auipc	ra,0xfffff
    800049fe:	2e8080e7          	jalr	744(ra) # 80003ce2 <stati>
    iunlock(f->ip);
    80004a02:	6c88                	ld	a0,24(s1)
    80004a04:	fffff097          	auipc	ra,0xfffff
    80004a08:	116080e7          	jalr	278(ra) # 80003b1a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a0c:	46e1                	li	a3,24
    80004a0e:	fb840613          	addi	a2,s0,-72
    80004a12:	85ce                	mv	a1,s3
    80004a14:	05893503          	ld	a0,88(s2)
    80004a18:	ffffd097          	auipc	ra,0xffffd
    80004a1c:	106080e7          	jalr	262(ra) # 80001b1e <copyout>
    80004a20:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a24:	60a6                	ld	ra,72(sp)
    80004a26:	6406                	ld	s0,64(sp)
    80004a28:	74e2                	ld	s1,56(sp)
    80004a2a:	7942                	ld	s2,48(sp)
    80004a2c:	79a2                	ld	s3,40(sp)
    80004a2e:	6161                	addi	sp,sp,80
    80004a30:	8082                	ret
  return -1;
    80004a32:	557d                	li	a0,-1
    80004a34:	bfc5                	j	80004a24 <filestat+0x60>

0000000080004a36 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a36:	7179                	addi	sp,sp,-48
    80004a38:	f406                	sd	ra,40(sp)
    80004a3a:	f022                	sd	s0,32(sp)
    80004a3c:	ec26                	sd	s1,24(sp)
    80004a3e:	e84a                	sd	s2,16(sp)
    80004a40:	e44e                	sd	s3,8(sp)
    80004a42:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a44:	00854783          	lbu	a5,8(a0)
    80004a48:	c3d5                	beqz	a5,80004aec <fileread+0xb6>
    80004a4a:	84aa                	mv	s1,a0
    80004a4c:	89ae                	mv	s3,a1
    80004a4e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a50:	411c                	lw	a5,0(a0)
    80004a52:	4705                	li	a4,1
    80004a54:	04e78963          	beq	a5,a4,80004aa6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a58:	470d                	li	a4,3
    80004a5a:	04e78d63          	beq	a5,a4,80004ab4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a5e:	4709                	li	a4,2
    80004a60:	06e79e63          	bne	a5,a4,80004adc <fileread+0xa6>
    ilock(f->ip);
    80004a64:	6d08                	ld	a0,24(a0)
    80004a66:	fffff097          	auipc	ra,0xfffff
    80004a6a:	ff2080e7          	jalr	-14(ra) # 80003a58 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a6e:	874a                	mv	a4,s2
    80004a70:	5094                	lw	a3,32(s1)
    80004a72:	864e                	mv	a2,s3
    80004a74:	4585                	li	a1,1
    80004a76:	6c88                	ld	a0,24(s1)
    80004a78:	fffff097          	auipc	ra,0xfffff
    80004a7c:	294080e7          	jalr	660(ra) # 80003d0c <readi>
    80004a80:	892a                	mv	s2,a0
    80004a82:	00a05563          	blez	a0,80004a8c <fileread+0x56>
      f->off += r;
    80004a86:	509c                	lw	a5,32(s1)
    80004a88:	9fa9                	addw	a5,a5,a0
    80004a8a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a8c:	6c88                	ld	a0,24(s1)
    80004a8e:	fffff097          	auipc	ra,0xfffff
    80004a92:	08c080e7          	jalr	140(ra) # 80003b1a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a96:	854a                	mv	a0,s2
    80004a98:	70a2                	ld	ra,40(sp)
    80004a9a:	7402                	ld	s0,32(sp)
    80004a9c:	64e2                	ld	s1,24(sp)
    80004a9e:	6942                	ld	s2,16(sp)
    80004aa0:	69a2                	ld	s3,8(sp)
    80004aa2:	6145                	addi	sp,sp,48
    80004aa4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004aa6:	6908                	ld	a0,16(a0)
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	422080e7          	jalr	1058(ra) # 80004eca <piperead>
    80004ab0:	892a                	mv	s2,a0
    80004ab2:	b7d5                	j	80004a96 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ab4:	02451783          	lh	a5,36(a0)
    80004ab8:	03079693          	slli	a3,a5,0x30
    80004abc:	92c1                	srli	a3,a3,0x30
    80004abe:	4725                	li	a4,9
    80004ac0:	02d76863          	bltu	a4,a3,80004af0 <fileread+0xba>
    80004ac4:	0792                	slli	a5,a5,0x4
    80004ac6:	0001e717          	auipc	a4,0x1e
    80004aca:	dd270713          	addi	a4,a4,-558 # 80022898 <devsw>
    80004ace:	97ba                	add	a5,a5,a4
    80004ad0:	639c                	ld	a5,0(a5)
    80004ad2:	c38d                	beqz	a5,80004af4 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004ad4:	4505                	li	a0,1
    80004ad6:	9782                	jalr	a5
    80004ad8:	892a                	mv	s2,a0
    80004ada:	bf75                	j	80004a96 <fileread+0x60>
    panic("fileread");
    80004adc:	00004517          	auipc	a0,0x4
    80004ae0:	c2c50513          	addi	a0,a0,-980 # 80008708 <syscalls+0x250>
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	a6c080e7          	jalr	-1428(ra) # 80000550 <panic>
    return -1;
    80004aec:	597d                	li	s2,-1
    80004aee:	b765                	j	80004a96 <fileread+0x60>
      return -1;
    80004af0:	597d                	li	s2,-1
    80004af2:	b755                	j	80004a96 <fileread+0x60>
    80004af4:	597d                	li	s2,-1
    80004af6:	b745                	j	80004a96 <fileread+0x60>

0000000080004af8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004af8:	00954783          	lbu	a5,9(a0)
    80004afc:	14078563          	beqz	a5,80004c46 <filewrite+0x14e>
{
    80004b00:	715d                	addi	sp,sp,-80
    80004b02:	e486                	sd	ra,72(sp)
    80004b04:	e0a2                	sd	s0,64(sp)
    80004b06:	fc26                	sd	s1,56(sp)
    80004b08:	f84a                	sd	s2,48(sp)
    80004b0a:	f44e                	sd	s3,40(sp)
    80004b0c:	f052                	sd	s4,32(sp)
    80004b0e:	ec56                	sd	s5,24(sp)
    80004b10:	e85a                	sd	s6,16(sp)
    80004b12:	e45e                	sd	s7,8(sp)
    80004b14:	e062                	sd	s8,0(sp)
    80004b16:	0880                	addi	s0,sp,80
    80004b18:	892a                	mv	s2,a0
    80004b1a:	8aae                	mv	s5,a1
    80004b1c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b1e:	411c                	lw	a5,0(a0)
    80004b20:	4705                	li	a4,1
    80004b22:	02e78263          	beq	a5,a4,80004b46 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b26:	470d                	li	a4,3
    80004b28:	02e78563          	beq	a5,a4,80004b52 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b2c:	4709                	li	a4,2
    80004b2e:	10e79463          	bne	a5,a4,80004c36 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b32:	0ec05e63          	blez	a2,80004c2e <filewrite+0x136>
    int i = 0;
    80004b36:	4981                	li	s3,0
    80004b38:	6b05                	lui	s6,0x1
    80004b3a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004b3e:	6b85                	lui	s7,0x1
    80004b40:	c00b8b9b          	addiw	s7,s7,-1024
    80004b44:	a851                	j	80004bd8 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004b46:	6908                	ld	a0,16(a0)
    80004b48:	00000097          	auipc	ra,0x0
    80004b4c:	25e080e7          	jalr	606(ra) # 80004da6 <pipewrite>
    80004b50:	a85d                	j	80004c06 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b52:	02451783          	lh	a5,36(a0)
    80004b56:	03079693          	slli	a3,a5,0x30
    80004b5a:	92c1                	srli	a3,a3,0x30
    80004b5c:	4725                	li	a4,9
    80004b5e:	0ed76663          	bltu	a4,a3,80004c4a <filewrite+0x152>
    80004b62:	0792                	slli	a5,a5,0x4
    80004b64:	0001e717          	auipc	a4,0x1e
    80004b68:	d3470713          	addi	a4,a4,-716 # 80022898 <devsw>
    80004b6c:	97ba                	add	a5,a5,a4
    80004b6e:	679c                	ld	a5,8(a5)
    80004b70:	cff9                	beqz	a5,80004c4e <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004b72:	4505                	li	a0,1
    80004b74:	9782                	jalr	a5
    80004b76:	a841                	j	80004c06 <filewrite+0x10e>
    80004b78:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b7c:	00000097          	auipc	ra,0x0
    80004b80:	8ac080e7          	jalr	-1876(ra) # 80004428 <begin_op>
      ilock(f->ip);
    80004b84:	01893503          	ld	a0,24(s2)
    80004b88:	fffff097          	auipc	ra,0xfffff
    80004b8c:	ed0080e7          	jalr	-304(ra) # 80003a58 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b90:	8762                	mv	a4,s8
    80004b92:	02092683          	lw	a3,32(s2)
    80004b96:	01598633          	add	a2,s3,s5
    80004b9a:	4585                	li	a1,1
    80004b9c:	01893503          	ld	a0,24(s2)
    80004ba0:	fffff097          	auipc	ra,0xfffff
    80004ba4:	264080e7          	jalr	612(ra) # 80003e04 <writei>
    80004ba8:	84aa                	mv	s1,a0
    80004baa:	02a05f63          	blez	a0,80004be8 <filewrite+0xf0>
        f->off += r;
    80004bae:	02092783          	lw	a5,32(s2)
    80004bb2:	9fa9                	addw	a5,a5,a0
    80004bb4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004bb8:	01893503          	ld	a0,24(s2)
    80004bbc:	fffff097          	auipc	ra,0xfffff
    80004bc0:	f5e080e7          	jalr	-162(ra) # 80003b1a <iunlock>
      end_op();
    80004bc4:	00000097          	auipc	ra,0x0
    80004bc8:	8e4080e7          	jalr	-1820(ra) # 800044a8 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004bcc:	049c1963          	bne	s8,s1,80004c1e <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004bd0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004bd4:	0349d663          	bge	s3,s4,80004c00 <filewrite+0x108>
      int n1 = n - i;
    80004bd8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004bdc:	84be                	mv	s1,a5
    80004bde:	2781                	sext.w	a5,a5
    80004be0:	f8fb5ce3          	bge	s6,a5,80004b78 <filewrite+0x80>
    80004be4:	84de                	mv	s1,s7
    80004be6:	bf49                	j	80004b78 <filewrite+0x80>
      iunlock(f->ip);
    80004be8:	01893503          	ld	a0,24(s2)
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	f2e080e7          	jalr	-210(ra) # 80003b1a <iunlock>
      end_op();
    80004bf4:	00000097          	auipc	ra,0x0
    80004bf8:	8b4080e7          	jalr	-1868(ra) # 800044a8 <end_op>
      if(r < 0)
    80004bfc:	fc04d8e3          	bgez	s1,80004bcc <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004c00:	8552                	mv	a0,s4
    80004c02:	033a1863          	bne	s4,s3,80004c32 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c06:	60a6                	ld	ra,72(sp)
    80004c08:	6406                	ld	s0,64(sp)
    80004c0a:	74e2                	ld	s1,56(sp)
    80004c0c:	7942                	ld	s2,48(sp)
    80004c0e:	79a2                	ld	s3,40(sp)
    80004c10:	7a02                	ld	s4,32(sp)
    80004c12:	6ae2                	ld	s5,24(sp)
    80004c14:	6b42                	ld	s6,16(sp)
    80004c16:	6ba2                	ld	s7,8(sp)
    80004c18:	6c02                	ld	s8,0(sp)
    80004c1a:	6161                	addi	sp,sp,80
    80004c1c:	8082                	ret
        panic("short filewrite");
    80004c1e:	00004517          	auipc	a0,0x4
    80004c22:	afa50513          	addi	a0,a0,-1286 # 80008718 <syscalls+0x260>
    80004c26:	ffffc097          	auipc	ra,0xffffc
    80004c2a:	92a080e7          	jalr	-1750(ra) # 80000550 <panic>
    int i = 0;
    80004c2e:	4981                	li	s3,0
    80004c30:	bfc1                	j	80004c00 <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004c32:	557d                	li	a0,-1
    80004c34:	bfc9                	j	80004c06 <filewrite+0x10e>
    panic("filewrite");
    80004c36:	00004517          	auipc	a0,0x4
    80004c3a:	af250513          	addi	a0,a0,-1294 # 80008728 <syscalls+0x270>
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	912080e7          	jalr	-1774(ra) # 80000550 <panic>
    return -1;
    80004c46:	557d                	li	a0,-1
}
    80004c48:	8082                	ret
      return -1;
    80004c4a:	557d                	li	a0,-1
    80004c4c:	bf6d                	j	80004c06 <filewrite+0x10e>
    80004c4e:	557d                	li	a0,-1
    80004c50:	bf5d                	j	80004c06 <filewrite+0x10e>

0000000080004c52 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c52:	7179                	addi	sp,sp,-48
    80004c54:	f406                	sd	ra,40(sp)
    80004c56:	f022                	sd	s0,32(sp)
    80004c58:	ec26                	sd	s1,24(sp)
    80004c5a:	e84a                	sd	s2,16(sp)
    80004c5c:	e44e                	sd	s3,8(sp)
    80004c5e:	e052                	sd	s4,0(sp)
    80004c60:	1800                	addi	s0,sp,48
    80004c62:	84aa                	mv	s1,a0
    80004c64:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c66:	0005b023          	sd	zero,0(a1)
    80004c6a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c6e:	00000097          	auipc	ra,0x0
    80004c72:	bd2080e7          	jalr	-1070(ra) # 80004840 <filealloc>
    80004c76:	e088                	sd	a0,0(s1)
    80004c78:	c551                	beqz	a0,80004d04 <pipealloc+0xb2>
    80004c7a:	00000097          	auipc	ra,0x0
    80004c7e:	bc6080e7          	jalr	-1082(ra) # 80004840 <filealloc>
    80004c82:	00aa3023          	sd	a0,0(s4)
    80004c86:	c92d                	beqz	a0,80004cf8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c88:	ffffc097          	auipc	ra,0xffffc
    80004c8c:	ff0080e7          	jalr	-16(ra) # 80000c78 <kalloc>
    80004c90:	892a                	mv	s2,a0
    80004c92:	c125                	beqz	a0,80004cf2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c94:	4985                	li	s3,1
    80004c96:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004c9a:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004c9e:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004ca2:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004ca6:	00004597          	auipc	a1,0x4
    80004caa:	a9258593          	addi	a1,a1,-1390 # 80008738 <syscalls+0x280>
    80004cae:	ffffc097          	auipc	ra,0xffffc
    80004cb2:	2b0080e7          	jalr	688(ra) # 80000f5e <initlock>
  (*f0)->type = FD_PIPE;
    80004cb6:	609c                	ld	a5,0(s1)
    80004cb8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004cbc:	609c                	ld	a5,0(s1)
    80004cbe:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004cc2:	609c                	ld	a5,0(s1)
    80004cc4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004cc8:	609c                	ld	a5,0(s1)
    80004cca:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004cce:	000a3783          	ld	a5,0(s4)
    80004cd2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004cd6:	000a3783          	ld	a5,0(s4)
    80004cda:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004cde:	000a3783          	ld	a5,0(s4)
    80004ce2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ce6:	000a3783          	ld	a5,0(s4)
    80004cea:	0127b823          	sd	s2,16(a5)
  return 0;
    80004cee:	4501                	li	a0,0
    80004cf0:	a025                	j	80004d18 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004cf2:	6088                	ld	a0,0(s1)
    80004cf4:	e501                	bnez	a0,80004cfc <pipealloc+0xaa>
    80004cf6:	a039                	j	80004d04 <pipealloc+0xb2>
    80004cf8:	6088                	ld	a0,0(s1)
    80004cfa:	c51d                	beqz	a0,80004d28 <pipealloc+0xd6>
    fileclose(*f0);
    80004cfc:	00000097          	auipc	ra,0x0
    80004d00:	c00080e7          	jalr	-1024(ra) # 800048fc <fileclose>
  if(*f1)
    80004d04:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d08:	557d                	li	a0,-1
  if(*f1)
    80004d0a:	c799                	beqz	a5,80004d18 <pipealloc+0xc6>
    fileclose(*f1);
    80004d0c:	853e                	mv	a0,a5
    80004d0e:	00000097          	auipc	ra,0x0
    80004d12:	bee080e7          	jalr	-1042(ra) # 800048fc <fileclose>
  return -1;
    80004d16:	557d                	li	a0,-1
}
    80004d18:	70a2                	ld	ra,40(sp)
    80004d1a:	7402                	ld	s0,32(sp)
    80004d1c:	64e2                	ld	s1,24(sp)
    80004d1e:	6942                	ld	s2,16(sp)
    80004d20:	69a2                	ld	s3,8(sp)
    80004d22:	6a02                	ld	s4,0(sp)
    80004d24:	6145                	addi	sp,sp,48
    80004d26:	8082                	ret
  return -1;
    80004d28:	557d                	li	a0,-1
    80004d2a:	b7fd                	j	80004d18 <pipealloc+0xc6>

0000000080004d2c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d2c:	1101                	addi	sp,sp,-32
    80004d2e:	ec06                	sd	ra,24(sp)
    80004d30:	e822                	sd	s0,16(sp)
    80004d32:	e426                	sd	s1,8(sp)
    80004d34:	e04a                	sd	s2,0(sp)
    80004d36:	1000                	addi	s0,sp,32
    80004d38:	84aa                	mv	s1,a0
    80004d3a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d3c:	ffffc097          	auipc	ra,0xffffc
    80004d40:	0a6080e7          	jalr	166(ra) # 80000de2 <acquire>
  if(writable){
    80004d44:	04090263          	beqz	s2,80004d88 <pipeclose+0x5c>
    pi->writeopen = 0;
    80004d48:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004d4c:	22048513          	addi	a0,s1,544
    80004d50:	ffffe097          	auipc	ra,0xffffe
    80004d54:	a70080e7          	jalr	-1424(ra) # 800027c0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d58:	2284b783          	ld	a5,552(s1)
    80004d5c:	ef9d                	bnez	a5,80004d9a <pipeclose+0x6e>
    release(&pi->lock);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	ffffc097          	auipc	ra,0xffffc
    80004d64:	152080e7          	jalr	338(ra) # 80000eb2 <release>
#ifdef LAB_LOCK
    freelock(&pi->lock);
    80004d68:	8526                	mv	a0,s1
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	190080e7          	jalr	400(ra) # 80000efa <freelock>
#endif    
    kfree((char*)pi);
    80004d72:	8526                	mv	a0,s1
    80004d74:	ffffc097          	auipc	ra,0xffffc
    80004d78:	e14080e7          	jalr	-492(ra) # 80000b88 <kfree>
  } else
    release(&pi->lock);
}
    80004d7c:	60e2                	ld	ra,24(sp)
    80004d7e:	6442                	ld	s0,16(sp)
    80004d80:	64a2                	ld	s1,8(sp)
    80004d82:	6902                	ld	s2,0(sp)
    80004d84:	6105                	addi	sp,sp,32
    80004d86:	8082                	ret
    pi->readopen = 0;
    80004d88:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004d8c:	22448513          	addi	a0,s1,548
    80004d90:	ffffe097          	auipc	ra,0xffffe
    80004d94:	a30080e7          	jalr	-1488(ra) # 800027c0 <wakeup>
    80004d98:	b7c1                	j	80004d58 <pipeclose+0x2c>
    release(&pi->lock);
    80004d9a:	8526                	mv	a0,s1
    80004d9c:	ffffc097          	auipc	ra,0xffffc
    80004da0:	116080e7          	jalr	278(ra) # 80000eb2 <release>
}
    80004da4:	bfe1                	j	80004d7c <pipeclose+0x50>

0000000080004da6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004da6:	7119                	addi	sp,sp,-128
    80004da8:	fc86                	sd	ra,120(sp)
    80004daa:	f8a2                	sd	s0,112(sp)
    80004dac:	f4a6                	sd	s1,104(sp)
    80004dae:	f0ca                	sd	s2,96(sp)
    80004db0:	ecce                	sd	s3,88(sp)
    80004db2:	e8d2                	sd	s4,80(sp)
    80004db4:	e4d6                	sd	s5,72(sp)
    80004db6:	e0da                	sd	s6,64(sp)
    80004db8:	fc5e                	sd	s7,56(sp)
    80004dba:	f862                	sd	s8,48(sp)
    80004dbc:	f466                	sd	s9,40(sp)
    80004dbe:	f06a                	sd	s10,32(sp)
    80004dc0:	ec6e                	sd	s11,24(sp)
    80004dc2:	0100                	addi	s0,sp,128
    80004dc4:	84aa                	mv	s1,a0
    80004dc6:	8cae                	mv	s9,a1
    80004dc8:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	060080e7          	jalr	96(ra) # 80001e2a <myproc>
    80004dd2:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	00c080e7          	jalr	12(ra) # 80000de2 <acquire>
  for(i = 0; i < n; i++){
    80004dde:	0d605963          	blez	s6,80004eb0 <pipewrite+0x10a>
    80004de2:	89a6                	mv	s3,s1
    80004de4:	3b7d                	addiw	s6,s6,-1
    80004de6:	1b02                	slli	s6,s6,0x20
    80004de8:	020b5b13          	srli	s6,s6,0x20
    80004dec:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004dee:	22048a93          	addi	s5,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004df2:	22448a13          	addi	s4,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004df6:	5dfd                	li	s11,-1
    80004df8:	000b8d1b          	sext.w	s10,s7
    80004dfc:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004dfe:	2204a783          	lw	a5,544(s1)
    80004e02:	2244a703          	lw	a4,548(s1)
    80004e06:	2007879b          	addiw	a5,a5,512
    80004e0a:	02f71b63          	bne	a4,a5,80004e40 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004e0e:	2284a783          	lw	a5,552(s1)
    80004e12:	cbad                	beqz	a5,80004e84 <pipewrite+0xde>
    80004e14:	03892783          	lw	a5,56(s2)
    80004e18:	e7b5                	bnez	a5,80004e84 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004e1a:	8556                	mv	a0,s5
    80004e1c:	ffffe097          	auipc	ra,0xffffe
    80004e20:	9a4080e7          	jalr	-1628(ra) # 800027c0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e24:	85ce                	mv	a1,s3
    80004e26:	8552                	mv	a0,s4
    80004e28:	ffffe097          	auipc	ra,0xffffe
    80004e2c:	812080e7          	jalr	-2030(ra) # 8000263a <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004e30:	2204a783          	lw	a5,544(s1)
    80004e34:	2244a703          	lw	a4,548(s1)
    80004e38:	2007879b          	addiw	a5,a5,512
    80004e3c:	fcf709e3          	beq	a4,a5,80004e0e <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e40:	4685                	li	a3,1
    80004e42:	019b8633          	add	a2,s7,s9
    80004e46:	f8f40593          	addi	a1,s0,-113
    80004e4a:	05893503          	ld	a0,88(s2)
    80004e4e:	ffffd097          	auipc	ra,0xffffd
    80004e52:	d5c080e7          	jalr	-676(ra) # 80001baa <copyin>
    80004e56:	05b50e63          	beq	a0,s11,80004eb2 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e5a:	2244a783          	lw	a5,548(s1)
    80004e5e:	0017871b          	addiw	a4,a5,1
    80004e62:	22e4a223          	sw	a4,548(s1)
    80004e66:	1ff7f793          	andi	a5,a5,511
    80004e6a:	97a6                	add	a5,a5,s1
    80004e6c:	f8f44703          	lbu	a4,-113(s0)
    80004e70:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004e74:	001d0c1b          	addiw	s8,s10,1
    80004e78:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004e7c:	036b8b63          	beq	s7,s6,80004eb2 <pipewrite+0x10c>
    80004e80:	8bbe                	mv	s7,a5
    80004e82:	bf9d                	j	80004df8 <pipewrite+0x52>
        release(&pi->lock);
    80004e84:	8526                	mv	a0,s1
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	02c080e7          	jalr	44(ra) # 80000eb2 <release>
        return -1;
    80004e8e:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004e90:	8562                	mv	a0,s8
    80004e92:	70e6                	ld	ra,120(sp)
    80004e94:	7446                	ld	s0,112(sp)
    80004e96:	74a6                	ld	s1,104(sp)
    80004e98:	7906                	ld	s2,96(sp)
    80004e9a:	69e6                	ld	s3,88(sp)
    80004e9c:	6a46                	ld	s4,80(sp)
    80004e9e:	6aa6                	ld	s5,72(sp)
    80004ea0:	6b06                	ld	s6,64(sp)
    80004ea2:	7be2                	ld	s7,56(sp)
    80004ea4:	7c42                	ld	s8,48(sp)
    80004ea6:	7ca2                	ld	s9,40(sp)
    80004ea8:	7d02                	ld	s10,32(sp)
    80004eaa:	6de2                	ld	s11,24(sp)
    80004eac:	6109                	addi	sp,sp,128
    80004eae:	8082                	ret
  for(i = 0; i < n; i++){
    80004eb0:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004eb2:	22048513          	addi	a0,s1,544
    80004eb6:	ffffe097          	auipc	ra,0xffffe
    80004eba:	90a080e7          	jalr	-1782(ra) # 800027c0 <wakeup>
  release(&pi->lock);
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	ffffc097          	auipc	ra,0xffffc
    80004ec4:	ff2080e7          	jalr	-14(ra) # 80000eb2 <release>
  return i;
    80004ec8:	b7e1                	j	80004e90 <pipewrite+0xea>

0000000080004eca <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004eca:	715d                	addi	sp,sp,-80
    80004ecc:	e486                	sd	ra,72(sp)
    80004ece:	e0a2                	sd	s0,64(sp)
    80004ed0:	fc26                	sd	s1,56(sp)
    80004ed2:	f84a                	sd	s2,48(sp)
    80004ed4:	f44e                	sd	s3,40(sp)
    80004ed6:	f052                	sd	s4,32(sp)
    80004ed8:	ec56                	sd	s5,24(sp)
    80004eda:	e85a                	sd	s6,16(sp)
    80004edc:	0880                	addi	s0,sp,80
    80004ede:	84aa                	mv	s1,a0
    80004ee0:	892e                	mv	s2,a1
    80004ee2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ee4:	ffffd097          	auipc	ra,0xffffd
    80004ee8:	f46080e7          	jalr	-186(ra) # 80001e2a <myproc>
    80004eec:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004eee:	8b26                	mv	s6,s1
    80004ef0:	8526                	mv	a0,s1
    80004ef2:	ffffc097          	auipc	ra,0xffffc
    80004ef6:	ef0080e7          	jalr	-272(ra) # 80000de2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004efa:	2204a703          	lw	a4,544(s1)
    80004efe:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f02:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f06:	02f71463          	bne	a4,a5,80004f2e <piperead+0x64>
    80004f0a:	22c4a783          	lw	a5,556(s1)
    80004f0e:	c385                	beqz	a5,80004f2e <piperead+0x64>
    if(pr->killed){
    80004f10:	038a2783          	lw	a5,56(s4)
    80004f14:	ebc1                	bnez	a5,80004fa4 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f16:	85da                	mv	a1,s6
    80004f18:	854e                	mv	a0,s3
    80004f1a:	ffffd097          	auipc	ra,0xffffd
    80004f1e:	720080e7          	jalr	1824(ra) # 8000263a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f22:	2204a703          	lw	a4,544(s1)
    80004f26:	2244a783          	lw	a5,548(s1)
    80004f2a:	fef700e3          	beq	a4,a5,80004f0a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f2e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f30:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f32:	05505363          	blez	s5,80004f78 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004f36:	2204a783          	lw	a5,544(s1)
    80004f3a:	2244a703          	lw	a4,548(s1)
    80004f3e:	02f70d63          	beq	a4,a5,80004f78 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f42:	0017871b          	addiw	a4,a5,1
    80004f46:	22e4a023          	sw	a4,544(s1)
    80004f4a:	1ff7f793          	andi	a5,a5,511
    80004f4e:	97a6                	add	a5,a5,s1
    80004f50:	0207c783          	lbu	a5,32(a5)
    80004f54:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f58:	4685                	li	a3,1
    80004f5a:	fbf40613          	addi	a2,s0,-65
    80004f5e:	85ca                	mv	a1,s2
    80004f60:	058a3503          	ld	a0,88(s4)
    80004f64:	ffffd097          	auipc	ra,0xffffd
    80004f68:	bba080e7          	jalr	-1094(ra) # 80001b1e <copyout>
    80004f6c:	01650663          	beq	a0,s6,80004f78 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f70:	2985                	addiw	s3,s3,1
    80004f72:	0905                	addi	s2,s2,1
    80004f74:	fd3a91e3          	bne	s5,s3,80004f36 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f78:	22448513          	addi	a0,s1,548
    80004f7c:	ffffe097          	auipc	ra,0xffffe
    80004f80:	844080e7          	jalr	-1980(ra) # 800027c0 <wakeup>
  release(&pi->lock);
    80004f84:	8526                	mv	a0,s1
    80004f86:	ffffc097          	auipc	ra,0xffffc
    80004f8a:	f2c080e7          	jalr	-212(ra) # 80000eb2 <release>
  return i;
}
    80004f8e:	854e                	mv	a0,s3
    80004f90:	60a6                	ld	ra,72(sp)
    80004f92:	6406                	ld	s0,64(sp)
    80004f94:	74e2                	ld	s1,56(sp)
    80004f96:	7942                	ld	s2,48(sp)
    80004f98:	79a2                	ld	s3,40(sp)
    80004f9a:	7a02                	ld	s4,32(sp)
    80004f9c:	6ae2                	ld	s5,24(sp)
    80004f9e:	6b42                	ld	s6,16(sp)
    80004fa0:	6161                	addi	sp,sp,80
    80004fa2:	8082                	ret
      release(&pi->lock);
    80004fa4:	8526                	mv	a0,s1
    80004fa6:	ffffc097          	auipc	ra,0xffffc
    80004faa:	f0c080e7          	jalr	-244(ra) # 80000eb2 <release>
      return -1;
    80004fae:	59fd                	li	s3,-1
    80004fb0:	bff9                	j	80004f8e <piperead+0xc4>

0000000080004fb2 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004fb2:	df010113          	addi	sp,sp,-528
    80004fb6:	20113423          	sd	ra,520(sp)
    80004fba:	20813023          	sd	s0,512(sp)
    80004fbe:	ffa6                	sd	s1,504(sp)
    80004fc0:	fbca                	sd	s2,496(sp)
    80004fc2:	f7ce                	sd	s3,488(sp)
    80004fc4:	f3d2                	sd	s4,480(sp)
    80004fc6:	efd6                	sd	s5,472(sp)
    80004fc8:	ebda                	sd	s6,464(sp)
    80004fca:	e7de                	sd	s7,456(sp)
    80004fcc:	e3e2                	sd	s8,448(sp)
    80004fce:	ff66                	sd	s9,440(sp)
    80004fd0:	fb6a                	sd	s10,432(sp)
    80004fd2:	f76e                	sd	s11,424(sp)
    80004fd4:	0c00                	addi	s0,sp,528
    80004fd6:	84aa                	mv	s1,a0
    80004fd8:	dea43c23          	sd	a0,-520(s0)
    80004fdc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	e4a080e7          	jalr	-438(ra) # 80001e2a <myproc>
    80004fe8:	892a                	mv	s2,a0

  begin_op();
    80004fea:	fffff097          	auipc	ra,0xfffff
    80004fee:	43e080e7          	jalr	1086(ra) # 80004428 <begin_op>

  if((ip = namei(path)) == 0){
    80004ff2:	8526                	mv	a0,s1
    80004ff4:	fffff097          	auipc	ra,0xfffff
    80004ff8:	218080e7          	jalr	536(ra) # 8000420c <namei>
    80004ffc:	c92d                	beqz	a0,8000506e <exec+0xbc>
    80004ffe:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005000:	fffff097          	auipc	ra,0xfffff
    80005004:	a58080e7          	jalr	-1448(ra) # 80003a58 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005008:	04000713          	li	a4,64
    8000500c:	4681                	li	a3,0
    8000500e:	e4840613          	addi	a2,s0,-440
    80005012:	4581                	li	a1,0
    80005014:	8526                	mv	a0,s1
    80005016:	fffff097          	auipc	ra,0xfffff
    8000501a:	cf6080e7          	jalr	-778(ra) # 80003d0c <readi>
    8000501e:	04000793          	li	a5,64
    80005022:	00f51a63          	bne	a0,a5,80005036 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005026:	e4842703          	lw	a4,-440(s0)
    8000502a:	464c47b7          	lui	a5,0x464c4
    8000502e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005032:	04f70463          	beq	a4,a5,8000507a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005036:	8526                	mv	a0,s1
    80005038:	fffff097          	auipc	ra,0xfffff
    8000503c:	c82080e7          	jalr	-894(ra) # 80003cba <iunlockput>
    end_op();
    80005040:	fffff097          	auipc	ra,0xfffff
    80005044:	468080e7          	jalr	1128(ra) # 800044a8 <end_op>
  }
  return -1;
    80005048:	557d                	li	a0,-1
}
    8000504a:	20813083          	ld	ra,520(sp)
    8000504e:	20013403          	ld	s0,512(sp)
    80005052:	74fe                	ld	s1,504(sp)
    80005054:	795e                	ld	s2,496(sp)
    80005056:	79be                	ld	s3,488(sp)
    80005058:	7a1e                	ld	s4,480(sp)
    8000505a:	6afe                	ld	s5,472(sp)
    8000505c:	6b5e                	ld	s6,464(sp)
    8000505e:	6bbe                	ld	s7,456(sp)
    80005060:	6c1e                	ld	s8,448(sp)
    80005062:	7cfa                	ld	s9,440(sp)
    80005064:	7d5a                	ld	s10,432(sp)
    80005066:	7dba                	ld	s11,424(sp)
    80005068:	21010113          	addi	sp,sp,528
    8000506c:	8082                	ret
    end_op();
    8000506e:	fffff097          	auipc	ra,0xfffff
    80005072:	43a080e7          	jalr	1082(ra) # 800044a8 <end_op>
    return -1;
    80005076:	557d                	li	a0,-1
    80005078:	bfc9                	j	8000504a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000507a:	854a                	mv	a0,s2
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	e72080e7          	jalr	-398(ra) # 80001eee <proc_pagetable>
    80005084:	8baa                	mv	s7,a0
    80005086:	d945                	beqz	a0,80005036 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005088:	e6842983          	lw	s3,-408(s0)
    8000508c:	e8045783          	lhu	a5,-384(s0)
    80005090:	c7ad                	beqz	a5,800050fa <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005092:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005094:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005096:	6c85                	lui	s9,0x1
    80005098:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000509c:	def43823          	sd	a5,-528(s0)
    800050a0:	a42d                	j	800052ca <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050a2:	00003517          	auipc	a0,0x3
    800050a6:	69e50513          	addi	a0,a0,1694 # 80008740 <syscalls+0x288>
    800050aa:	ffffb097          	auipc	ra,0xffffb
    800050ae:	4a6080e7          	jalr	1190(ra) # 80000550 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050b2:	8756                	mv	a4,s5
    800050b4:	012d86bb          	addw	a3,s11,s2
    800050b8:	4581                	li	a1,0
    800050ba:	8526                	mv	a0,s1
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	c50080e7          	jalr	-944(ra) # 80003d0c <readi>
    800050c4:	2501                	sext.w	a0,a0
    800050c6:	1aaa9963          	bne	s5,a0,80005278 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    800050ca:	6785                	lui	a5,0x1
    800050cc:	0127893b          	addw	s2,a5,s2
    800050d0:	77fd                	lui	a5,0xfffff
    800050d2:	01478a3b          	addw	s4,a5,s4
    800050d6:	1f897163          	bgeu	s2,s8,800052b8 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    800050da:	02091593          	slli	a1,s2,0x20
    800050de:	9181                	srli	a1,a1,0x20
    800050e0:	95ea                	add	a1,a1,s10
    800050e2:	855e                	mv	a0,s7
    800050e4:	ffffc097          	auipc	ra,0xffffc
    800050e8:	478080e7          	jalr	1144(ra) # 8000155c <walkaddr>
    800050ec:	862a                	mv	a2,a0
    if(pa == 0)
    800050ee:	d955                	beqz	a0,800050a2 <exec+0xf0>
      n = PGSIZE;
    800050f0:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800050f2:	fd9a70e3          	bgeu	s4,s9,800050b2 <exec+0x100>
      n = sz - i;
    800050f6:	8ad2                	mv	s5,s4
    800050f8:	bf6d                	j	800050b2 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800050fa:	4901                	li	s2,0
  iunlockput(ip);
    800050fc:	8526                	mv	a0,s1
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	bbc080e7          	jalr	-1092(ra) # 80003cba <iunlockput>
  end_op();
    80005106:	fffff097          	auipc	ra,0xfffff
    8000510a:	3a2080e7          	jalr	930(ra) # 800044a8 <end_op>
  p = myproc();
    8000510e:	ffffd097          	auipc	ra,0xffffd
    80005112:	d1c080e7          	jalr	-740(ra) # 80001e2a <myproc>
    80005116:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005118:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000511c:	6785                	lui	a5,0x1
    8000511e:	17fd                	addi	a5,a5,-1
    80005120:	993e                	add	s2,s2,a5
    80005122:	757d                	lui	a0,0xfffff
    80005124:	00a977b3          	and	a5,s2,a0
    80005128:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000512c:	6609                	lui	a2,0x2
    8000512e:	963e                	add	a2,a2,a5
    80005130:	85be                	mv	a1,a5
    80005132:	855e                	mv	a0,s7
    80005134:	ffffc097          	auipc	ra,0xffffc
    80005138:	79a080e7          	jalr	1946(ra) # 800018ce <uvmalloc>
    8000513c:	8b2a                	mv	s6,a0
  ip = 0;
    8000513e:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005140:	12050c63          	beqz	a0,80005278 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005144:	75f9                	lui	a1,0xffffe
    80005146:	95aa                	add	a1,a1,a0
    80005148:	855e                	mv	a0,s7
    8000514a:	ffffd097          	auipc	ra,0xffffd
    8000514e:	9a2080e7          	jalr	-1630(ra) # 80001aec <uvmclear>
  stackbase = sp - PGSIZE;
    80005152:	7c7d                	lui	s8,0xfffff
    80005154:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005156:	e0043783          	ld	a5,-512(s0)
    8000515a:	6388                	ld	a0,0(a5)
    8000515c:	c535                	beqz	a0,800051c8 <exec+0x216>
    8000515e:	e8840993          	addi	s3,s0,-376
    80005162:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005166:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005168:	ffffc097          	auipc	ra,0xffffc
    8000516c:	1e2080e7          	jalr	482(ra) # 8000134a <strlen>
    80005170:	2505                	addiw	a0,a0,1
    80005172:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005176:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000517a:	13896363          	bltu	s2,s8,800052a0 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000517e:	e0043d83          	ld	s11,-512(s0)
    80005182:	000dba03          	ld	s4,0(s11)
    80005186:	8552                	mv	a0,s4
    80005188:	ffffc097          	auipc	ra,0xffffc
    8000518c:	1c2080e7          	jalr	450(ra) # 8000134a <strlen>
    80005190:	0015069b          	addiw	a3,a0,1
    80005194:	8652                	mv	a2,s4
    80005196:	85ca                	mv	a1,s2
    80005198:	855e                	mv	a0,s7
    8000519a:	ffffd097          	auipc	ra,0xffffd
    8000519e:	984080e7          	jalr	-1660(ra) # 80001b1e <copyout>
    800051a2:	10054363          	bltz	a0,800052a8 <exec+0x2f6>
    ustack[argc] = sp;
    800051a6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051aa:	0485                	addi	s1,s1,1
    800051ac:	008d8793          	addi	a5,s11,8
    800051b0:	e0f43023          	sd	a5,-512(s0)
    800051b4:	008db503          	ld	a0,8(s11)
    800051b8:	c911                	beqz	a0,800051cc <exec+0x21a>
    if(argc >= MAXARG)
    800051ba:	09a1                	addi	s3,s3,8
    800051bc:	fb3c96e3          	bne	s9,s3,80005168 <exec+0x1b6>
  sz = sz1;
    800051c0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800051c4:	4481                	li	s1,0
    800051c6:	a84d                	j	80005278 <exec+0x2c6>
  sp = sz;
    800051c8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800051ca:	4481                	li	s1,0
  ustack[argc] = 0;
    800051cc:	00349793          	slli	a5,s1,0x3
    800051d0:	f9040713          	addi	a4,s0,-112
    800051d4:	97ba                	add	a5,a5,a4
    800051d6:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    800051da:	00148693          	addi	a3,s1,1
    800051de:	068e                	slli	a3,a3,0x3
    800051e0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051e4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800051e8:	01897663          	bgeu	s2,s8,800051f4 <exec+0x242>
  sz = sz1;
    800051ec:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800051f0:	4481                	li	s1,0
    800051f2:	a059                	j	80005278 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800051f4:	e8840613          	addi	a2,s0,-376
    800051f8:	85ca                	mv	a1,s2
    800051fa:	855e                	mv	a0,s7
    800051fc:	ffffd097          	auipc	ra,0xffffd
    80005200:	922080e7          	jalr	-1758(ra) # 80001b1e <copyout>
    80005204:	0a054663          	bltz	a0,800052b0 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005208:	060ab783          	ld	a5,96(s5)
    8000520c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005210:	df843783          	ld	a5,-520(s0)
    80005214:	0007c703          	lbu	a4,0(a5)
    80005218:	cf11                	beqz	a4,80005234 <exec+0x282>
    8000521a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000521c:	02f00693          	li	a3,47
    80005220:	a029                	j	8000522a <exec+0x278>
  for(last=s=path; *s; s++)
    80005222:	0785                	addi	a5,a5,1
    80005224:	fff7c703          	lbu	a4,-1(a5)
    80005228:	c711                	beqz	a4,80005234 <exec+0x282>
    if(*s == '/')
    8000522a:	fed71ce3          	bne	a4,a3,80005222 <exec+0x270>
      last = s+1;
    8000522e:	def43c23          	sd	a5,-520(s0)
    80005232:	bfc5                	j	80005222 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80005234:	4641                	li	a2,16
    80005236:	df843583          	ld	a1,-520(s0)
    8000523a:	160a8513          	addi	a0,s5,352
    8000523e:	ffffc097          	auipc	ra,0xffffc
    80005242:	0da080e7          	jalr	218(ra) # 80001318 <safestrcpy>
  oldpagetable = p->pagetable;
    80005246:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    8000524a:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    8000524e:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005252:	060ab783          	ld	a5,96(s5)
    80005256:	e6043703          	ld	a4,-416(s0)
    8000525a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000525c:	060ab783          	ld	a5,96(s5)
    80005260:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005264:	85ea                	mv	a1,s10
    80005266:	ffffd097          	auipc	ra,0xffffd
    8000526a:	d24080e7          	jalr	-732(ra) # 80001f8a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000526e:	0004851b          	sext.w	a0,s1
    80005272:	bbe1                	j	8000504a <exec+0x98>
    80005274:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005278:	e0843583          	ld	a1,-504(s0)
    8000527c:	855e                	mv	a0,s7
    8000527e:	ffffd097          	auipc	ra,0xffffd
    80005282:	d0c080e7          	jalr	-756(ra) # 80001f8a <proc_freepagetable>
  if(ip){
    80005286:	da0498e3          	bnez	s1,80005036 <exec+0x84>
  return -1;
    8000528a:	557d                	li	a0,-1
    8000528c:	bb7d                	j	8000504a <exec+0x98>
    8000528e:	e1243423          	sd	s2,-504(s0)
    80005292:	b7dd                	j	80005278 <exec+0x2c6>
    80005294:	e1243423          	sd	s2,-504(s0)
    80005298:	b7c5                	j	80005278 <exec+0x2c6>
    8000529a:	e1243423          	sd	s2,-504(s0)
    8000529e:	bfe9                	j	80005278 <exec+0x2c6>
  sz = sz1;
    800052a0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052a4:	4481                	li	s1,0
    800052a6:	bfc9                	j	80005278 <exec+0x2c6>
  sz = sz1;
    800052a8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052ac:	4481                	li	s1,0
    800052ae:	b7e9                	j	80005278 <exec+0x2c6>
  sz = sz1;
    800052b0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052b4:	4481                	li	s1,0
    800052b6:	b7c9                	j	80005278 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052b8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052bc:	2b05                	addiw	s6,s6,1
    800052be:	0389899b          	addiw	s3,s3,56
    800052c2:	e8045783          	lhu	a5,-384(s0)
    800052c6:	e2fb5be3          	bge	s6,a5,800050fc <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052ca:	2981                	sext.w	s3,s3
    800052cc:	03800713          	li	a4,56
    800052d0:	86ce                	mv	a3,s3
    800052d2:	e1040613          	addi	a2,s0,-496
    800052d6:	4581                	li	a1,0
    800052d8:	8526                	mv	a0,s1
    800052da:	fffff097          	auipc	ra,0xfffff
    800052de:	a32080e7          	jalr	-1486(ra) # 80003d0c <readi>
    800052e2:	03800793          	li	a5,56
    800052e6:	f8f517e3          	bne	a0,a5,80005274 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800052ea:	e1042783          	lw	a5,-496(s0)
    800052ee:	4705                	li	a4,1
    800052f0:	fce796e3          	bne	a5,a4,800052bc <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800052f4:	e3843603          	ld	a2,-456(s0)
    800052f8:	e3043783          	ld	a5,-464(s0)
    800052fc:	f8f669e3          	bltu	a2,a5,8000528e <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005300:	e2043783          	ld	a5,-480(s0)
    80005304:	963e                	add	a2,a2,a5
    80005306:	f8f667e3          	bltu	a2,a5,80005294 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000530a:	85ca                	mv	a1,s2
    8000530c:	855e                	mv	a0,s7
    8000530e:	ffffc097          	auipc	ra,0xffffc
    80005312:	5c0080e7          	jalr	1472(ra) # 800018ce <uvmalloc>
    80005316:	e0a43423          	sd	a0,-504(s0)
    8000531a:	d141                	beqz	a0,8000529a <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    8000531c:	e2043d03          	ld	s10,-480(s0)
    80005320:	df043783          	ld	a5,-528(s0)
    80005324:	00fd77b3          	and	a5,s10,a5
    80005328:	fba1                	bnez	a5,80005278 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000532a:	e1842d83          	lw	s11,-488(s0)
    8000532e:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005332:	f80c03e3          	beqz	s8,800052b8 <exec+0x306>
    80005336:	8a62                	mv	s4,s8
    80005338:	4901                	li	s2,0
    8000533a:	b345                	j	800050da <exec+0x128>

000000008000533c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000533c:	7179                	addi	sp,sp,-48
    8000533e:	f406                	sd	ra,40(sp)
    80005340:	f022                	sd	s0,32(sp)
    80005342:	ec26                	sd	s1,24(sp)
    80005344:	e84a                	sd	s2,16(sp)
    80005346:	1800                	addi	s0,sp,48
    80005348:	892e                	mv	s2,a1
    8000534a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000534c:	fdc40593          	addi	a1,s0,-36
    80005350:	ffffe097          	auipc	ra,0xffffe
    80005354:	b96080e7          	jalr	-1130(ra) # 80002ee6 <argint>
    80005358:	04054063          	bltz	a0,80005398 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000535c:	fdc42703          	lw	a4,-36(s0)
    80005360:	47bd                	li	a5,15
    80005362:	02e7ed63          	bltu	a5,a4,8000539c <argfd+0x60>
    80005366:	ffffd097          	auipc	ra,0xffffd
    8000536a:	ac4080e7          	jalr	-1340(ra) # 80001e2a <myproc>
    8000536e:	fdc42703          	lw	a4,-36(s0)
    80005372:	01a70793          	addi	a5,a4,26
    80005376:	078e                	slli	a5,a5,0x3
    80005378:	953e                	add	a0,a0,a5
    8000537a:	651c                	ld	a5,8(a0)
    8000537c:	c395                	beqz	a5,800053a0 <argfd+0x64>
    return -1;
  if(pfd)
    8000537e:	00090463          	beqz	s2,80005386 <argfd+0x4a>
    *pfd = fd;
    80005382:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005386:	4501                	li	a0,0
  if(pf)
    80005388:	c091                	beqz	s1,8000538c <argfd+0x50>
    *pf = f;
    8000538a:	e09c                	sd	a5,0(s1)
}
    8000538c:	70a2                	ld	ra,40(sp)
    8000538e:	7402                	ld	s0,32(sp)
    80005390:	64e2                	ld	s1,24(sp)
    80005392:	6942                	ld	s2,16(sp)
    80005394:	6145                	addi	sp,sp,48
    80005396:	8082                	ret
    return -1;
    80005398:	557d                	li	a0,-1
    8000539a:	bfcd                	j	8000538c <argfd+0x50>
    return -1;
    8000539c:	557d                	li	a0,-1
    8000539e:	b7fd                	j	8000538c <argfd+0x50>
    800053a0:	557d                	li	a0,-1
    800053a2:	b7ed                	j	8000538c <argfd+0x50>

00000000800053a4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053a4:	1101                	addi	sp,sp,-32
    800053a6:	ec06                	sd	ra,24(sp)
    800053a8:	e822                	sd	s0,16(sp)
    800053aa:	e426                	sd	s1,8(sp)
    800053ac:	1000                	addi	s0,sp,32
    800053ae:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053b0:	ffffd097          	auipc	ra,0xffffd
    800053b4:	a7a080e7          	jalr	-1414(ra) # 80001e2a <myproc>
    800053b8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053ba:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffd70b0>
    800053be:	4501                	li	a0,0
    800053c0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053c2:	6398                	ld	a4,0(a5)
    800053c4:	cb19                	beqz	a4,800053da <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053c6:	2505                	addiw	a0,a0,1
    800053c8:	07a1                	addi	a5,a5,8
    800053ca:	fed51ce3          	bne	a0,a3,800053c2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053ce:	557d                	li	a0,-1
}
    800053d0:	60e2                	ld	ra,24(sp)
    800053d2:	6442                	ld	s0,16(sp)
    800053d4:	64a2                	ld	s1,8(sp)
    800053d6:	6105                	addi	sp,sp,32
    800053d8:	8082                	ret
      p->ofile[fd] = f;
    800053da:	01a50793          	addi	a5,a0,26
    800053de:	078e                	slli	a5,a5,0x3
    800053e0:	963e                	add	a2,a2,a5
    800053e2:	e604                	sd	s1,8(a2)
      return fd;
    800053e4:	b7f5                	j	800053d0 <fdalloc+0x2c>

00000000800053e6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800053e6:	715d                	addi	sp,sp,-80
    800053e8:	e486                	sd	ra,72(sp)
    800053ea:	e0a2                	sd	s0,64(sp)
    800053ec:	fc26                	sd	s1,56(sp)
    800053ee:	f84a                	sd	s2,48(sp)
    800053f0:	f44e                	sd	s3,40(sp)
    800053f2:	f052                	sd	s4,32(sp)
    800053f4:	ec56                	sd	s5,24(sp)
    800053f6:	0880                	addi	s0,sp,80
    800053f8:	89ae                	mv	s3,a1
    800053fa:	8ab2                	mv	s5,a2
    800053fc:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800053fe:	fb040593          	addi	a1,s0,-80
    80005402:	fffff097          	auipc	ra,0xfffff
    80005406:	e28080e7          	jalr	-472(ra) # 8000422a <nameiparent>
    8000540a:	892a                	mv	s2,a0
    8000540c:	12050e63          	beqz	a0,80005548 <create+0x162>
    return 0;

  ilock(dp);
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	648080e7          	jalr	1608(ra) # 80003a58 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005418:	4601                	li	a2,0
    8000541a:	fb040593          	addi	a1,s0,-80
    8000541e:	854a                	mv	a0,s2
    80005420:	fffff097          	auipc	ra,0xfffff
    80005424:	b1a080e7          	jalr	-1254(ra) # 80003f3a <dirlookup>
    80005428:	84aa                	mv	s1,a0
    8000542a:	c921                	beqz	a0,8000547a <create+0x94>
    iunlockput(dp);
    8000542c:	854a                	mv	a0,s2
    8000542e:	fffff097          	auipc	ra,0xfffff
    80005432:	88c080e7          	jalr	-1908(ra) # 80003cba <iunlockput>
    ilock(ip);
    80005436:	8526                	mv	a0,s1
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	620080e7          	jalr	1568(ra) # 80003a58 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005440:	2981                	sext.w	s3,s3
    80005442:	4789                	li	a5,2
    80005444:	02f99463          	bne	s3,a5,8000546c <create+0x86>
    80005448:	04c4d783          	lhu	a5,76(s1)
    8000544c:	37f9                	addiw	a5,a5,-2
    8000544e:	17c2                	slli	a5,a5,0x30
    80005450:	93c1                	srli	a5,a5,0x30
    80005452:	4705                	li	a4,1
    80005454:	00f76c63          	bltu	a4,a5,8000546c <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005458:	8526                	mv	a0,s1
    8000545a:	60a6                	ld	ra,72(sp)
    8000545c:	6406                	ld	s0,64(sp)
    8000545e:	74e2                	ld	s1,56(sp)
    80005460:	7942                	ld	s2,48(sp)
    80005462:	79a2                	ld	s3,40(sp)
    80005464:	7a02                	ld	s4,32(sp)
    80005466:	6ae2                	ld	s5,24(sp)
    80005468:	6161                	addi	sp,sp,80
    8000546a:	8082                	ret
    iunlockput(ip);
    8000546c:	8526                	mv	a0,s1
    8000546e:	fffff097          	auipc	ra,0xfffff
    80005472:	84c080e7          	jalr	-1972(ra) # 80003cba <iunlockput>
    return 0;
    80005476:	4481                	li	s1,0
    80005478:	b7c5                	j	80005458 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000547a:	85ce                	mv	a1,s3
    8000547c:	00092503          	lw	a0,0(s2)
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	440080e7          	jalr	1088(ra) # 800038c0 <ialloc>
    80005488:	84aa                	mv	s1,a0
    8000548a:	c521                	beqz	a0,800054d2 <create+0xec>
  ilock(ip);
    8000548c:	ffffe097          	auipc	ra,0xffffe
    80005490:	5cc080e7          	jalr	1484(ra) # 80003a58 <ilock>
  ip->major = major;
    80005494:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    80005498:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    8000549c:	4a05                	li	s4,1
    8000549e:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    800054a2:	8526                	mv	a0,s1
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	4ea080e7          	jalr	1258(ra) # 8000398e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054ac:	2981                	sext.w	s3,s3
    800054ae:	03498a63          	beq	s3,s4,800054e2 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800054b2:	40d0                	lw	a2,4(s1)
    800054b4:	fb040593          	addi	a1,s0,-80
    800054b8:	854a                	mv	a0,s2
    800054ba:	fffff097          	auipc	ra,0xfffff
    800054be:	c90080e7          	jalr	-880(ra) # 8000414a <dirlink>
    800054c2:	06054b63          	bltz	a0,80005538 <create+0x152>
  iunlockput(dp);
    800054c6:	854a                	mv	a0,s2
    800054c8:	ffffe097          	auipc	ra,0xffffe
    800054cc:	7f2080e7          	jalr	2034(ra) # 80003cba <iunlockput>
  return ip;
    800054d0:	b761                	j	80005458 <create+0x72>
    panic("create: ialloc");
    800054d2:	00003517          	auipc	a0,0x3
    800054d6:	28e50513          	addi	a0,a0,654 # 80008760 <syscalls+0x2a8>
    800054da:	ffffb097          	auipc	ra,0xffffb
    800054de:	076080e7          	jalr	118(ra) # 80000550 <panic>
    dp->nlink++;  // for ".."
    800054e2:	05295783          	lhu	a5,82(s2)
    800054e6:	2785                	addiw	a5,a5,1
    800054e8:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800054ec:	854a                	mv	a0,s2
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	4a0080e7          	jalr	1184(ra) # 8000398e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054f6:	40d0                	lw	a2,4(s1)
    800054f8:	00003597          	auipc	a1,0x3
    800054fc:	27858593          	addi	a1,a1,632 # 80008770 <syscalls+0x2b8>
    80005500:	8526                	mv	a0,s1
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	c48080e7          	jalr	-952(ra) # 8000414a <dirlink>
    8000550a:	00054f63          	bltz	a0,80005528 <create+0x142>
    8000550e:	00492603          	lw	a2,4(s2)
    80005512:	00003597          	auipc	a1,0x3
    80005516:	26658593          	addi	a1,a1,614 # 80008778 <syscalls+0x2c0>
    8000551a:	8526                	mv	a0,s1
    8000551c:	fffff097          	auipc	ra,0xfffff
    80005520:	c2e080e7          	jalr	-978(ra) # 8000414a <dirlink>
    80005524:	f80557e3          	bgez	a0,800054b2 <create+0xcc>
      panic("create dots");
    80005528:	00003517          	auipc	a0,0x3
    8000552c:	25850513          	addi	a0,a0,600 # 80008780 <syscalls+0x2c8>
    80005530:	ffffb097          	auipc	ra,0xffffb
    80005534:	020080e7          	jalr	32(ra) # 80000550 <panic>
    panic("create: dirlink");
    80005538:	00003517          	auipc	a0,0x3
    8000553c:	25850513          	addi	a0,a0,600 # 80008790 <syscalls+0x2d8>
    80005540:	ffffb097          	auipc	ra,0xffffb
    80005544:	010080e7          	jalr	16(ra) # 80000550 <panic>
    return 0;
    80005548:	84aa                	mv	s1,a0
    8000554a:	b739                	j	80005458 <create+0x72>

000000008000554c <sys_dup>:
{
    8000554c:	7179                	addi	sp,sp,-48
    8000554e:	f406                	sd	ra,40(sp)
    80005550:	f022                	sd	s0,32(sp)
    80005552:	ec26                	sd	s1,24(sp)
    80005554:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005556:	fd840613          	addi	a2,s0,-40
    8000555a:	4581                	li	a1,0
    8000555c:	4501                	li	a0,0
    8000555e:	00000097          	auipc	ra,0x0
    80005562:	dde080e7          	jalr	-546(ra) # 8000533c <argfd>
    return -1;
    80005566:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005568:	02054363          	bltz	a0,8000558e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000556c:	fd843503          	ld	a0,-40(s0)
    80005570:	00000097          	auipc	ra,0x0
    80005574:	e34080e7          	jalr	-460(ra) # 800053a4 <fdalloc>
    80005578:	84aa                	mv	s1,a0
    return -1;
    8000557a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000557c:	00054963          	bltz	a0,8000558e <sys_dup+0x42>
  filedup(f);
    80005580:	fd843503          	ld	a0,-40(s0)
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	326080e7          	jalr	806(ra) # 800048aa <filedup>
  return fd;
    8000558c:	87a6                	mv	a5,s1
}
    8000558e:	853e                	mv	a0,a5
    80005590:	70a2                	ld	ra,40(sp)
    80005592:	7402                	ld	s0,32(sp)
    80005594:	64e2                	ld	s1,24(sp)
    80005596:	6145                	addi	sp,sp,48
    80005598:	8082                	ret

000000008000559a <sys_read>:
{
    8000559a:	7179                	addi	sp,sp,-48
    8000559c:	f406                	sd	ra,40(sp)
    8000559e:	f022                	sd	s0,32(sp)
    800055a0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055a2:	fe840613          	addi	a2,s0,-24
    800055a6:	4581                	li	a1,0
    800055a8:	4501                	li	a0,0
    800055aa:	00000097          	auipc	ra,0x0
    800055ae:	d92080e7          	jalr	-622(ra) # 8000533c <argfd>
    return -1;
    800055b2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055b4:	04054163          	bltz	a0,800055f6 <sys_read+0x5c>
    800055b8:	fe440593          	addi	a1,s0,-28
    800055bc:	4509                	li	a0,2
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	928080e7          	jalr	-1752(ra) # 80002ee6 <argint>
    return -1;
    800055c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055c8:	02054763          	bltz	a0,800055f6 <sys_read+0x5c>
    800055cc:	fd840593          	addi	a1,s0,-40
    800055d0:	4505                	li	a0,1
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	936080e7          	jalr	-1738(ra) # 80002f08 <argaddr>
    return -1;
    800055da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055dc:	00054d63          	bltz	a0,800055f6 <sys_read+0x5c>
  return fileread(f, p, n);
    800055e0:	fe442603          	lw	a2,-28(s0)
    800055e4:	fd843583          	ld	a1,-40(s0)
    800055e8:	fe843503          	ld	a0,-24(s0)
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	44a080e7          	jalr	1098(ra) # 80004a36 <fileread>
    800055f4:	87aa                	mv	a5,a0
}
    800055f6:	853e                	mv	a0,a5
    800055f8:	70a2                	ld	ra,40(sp)
    800055fa:	7402                	ld	s0,32(sp)
    800055fc:	6145                	addi	sp,sp,48
    800055fe:	8082                	ret

0000000080005600 <sys_write>:
{
    80005600:	7179                	addi	sp,sp,-48
    80005602:	f406                	sd	ra,40(sp)
    80005604:	f022                	sd	s0,32(sp)
    80005606:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005608:	fe840613          	addi	a2,s0,-24
    8000560c:	4581                	li	a1,0
    8000560e:	4501                	li	a0,0
    80005610:	00000097          	auipc	ra,0x0
    80005614:	d2c080e7          	jalr	-724(ra) # 8000533c <argfd>
    return -1;
    80005618:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000561a:	04054163          	bltz	a0,8000565c <sys_write+0x5c>
    8000561e:	fe440593          	addi	a1,s0,-28
    80005622:	4509                	li	a0,2
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	8c2080e7          	jalr	-1854(ra) # 80002ee6 <argint>
    return -1;
    8000562c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000562e:	02054763          	bltz	a0,8000565c <sys_write+0x5c>
    80005632:	fd840593          	addi	a1,s0,-40
    80005636:	4505                	li	a0,1
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	8d0080e7          	jalr	-1840(ra) # 80002f08 <argaddr>
    return -1;
    80005640:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005642:	00054d63          	bltz	a0,8000565c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005646:	fe442603          	lw	a2,-28(s0)
    8000564a:	fd843583          	ld	a1,-40(s0)
    8000564e:	fe843503          	ld	a0,-24(s0)
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	4a6080e7          	jalr	1190(ra) # 80004af8 <filewrite>
    8000565a:	87aa                	mv	a5,a0
}
    8000565c:	853e                	mv	a0,a5
    8000565e:	70a2                	ld	ra,40(sp)
    80005660:	7402                	ld	s0,32(sp)
    80005662:	6145                	addi	sp,sp,48
    80005664:	8082                	ret

0000000080005666 <sys_close>:
{
    80005666:	1101                	addi	sp,sp,-32
    80005668:	ec06                	sd	ra,24(sp)
    8000566a:	e822                	sd	s0,16(sp)
    8000566c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000566e:	fe040613          	addi	a2,s0,-32
    80005672:	fec40593          	addi	a1,s0,-20
    80005676:	4501                	li	a0,0
    80005678:	00000097          	auipc	ra,0x0
    8000567c:	cc4080e7          	jalr	-828(ra) # 8000533c <argfd>
    return -1;
    80005680:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005682:	02054463          	bltz	a0,800056aa <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005686:	ffffc097          	auipc	ra,0xffffc
    8000568a:	7a4080e7          	jalr	1956(ra) # 80001e2a <myproc>
    8000568e:	fec42783          	lw	a5,-20(s0)
    80005692:	07e9                	addi	a5,a5,26
    80005694:	078e                	slli	a5,a5,0x3
    80005696:	97aa                	add	a5,a5,a0
    80005698:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000569c:	fe043503          	ld	a0,-32(s0)
    800056a0:	fffff097          	auipc	ra,0xfffff
    800056a4:	25c080e7          	jalr	604(ra) # 800048fc <fileclose>
  return 0;
    800056a8:	4781                	li	a5,0
}
    800056aa:	853e                	mv	a0,a5
    800056ac:	60e2                	ld	ra,24(sp)
    800056ae:	6442                	ld	s0,16(sp)
    800056b0:	6105                	addi	sp,sp,32
    800056b2:	8082                	ret

00000000800056b4 <sys_fstat>:
{
    800056b4:	1101                	addi	sp,sp,-32
    800056b6:	ec06                	sd	ra,24(sp)
    800056b8:	e822                	sd	s0,16(sp)
    800056ba:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056bc:	fe840613          	addi	a2,s0,-24
    800056c0:	4581                	li	a1,0
    800056c2:	4501                	li	a0,0
    800056c4:	00000097          	auipc	ra,0x0
    800056c8:	c78080e7          	jalr	-904(ra) # 8000533c <argfd>
    return -1;
    800056cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056ce:	02054563          	bltz	a0,800056f8 <sys_fstat+0x44>
    800056d2:	fe040593          	addi	a1,s0,-32
    800056d6:	4505                	li	a0,1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	830080e7          	jalr	-2000(ra) # 80002f08 <argaddr>
    return -1;
    800056e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056e2:	00054b63          	bltz	a0,800056f8 <sys_fstat+0x44>
  return filestat(f, st);
    800056e6:	fe043583          	ld	a1,-32(s0)
    800056ea:	fe843503          	ld	a0,-24(s0)
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	2d6080e7          	jalr	726(ra) # 800049c4 <filestat>
    800056f6:	87aa                	mv	a5,a0
}
    800056f8:	853e                	mv	a0,a5
    800056fa:	60e2                	ld	ra,24(sp)
    800056fc:	6442                	ld	s0,16(sp)
    800056fe:	6105                	addi	sp,sp,32
    80005700:	8082                	ret

0000000080005702 <sys_link>:
{
    80005702:	7169                	addi	sp,sp,-304
    80005704:	f606                	sd	ra,296(sp)
    80005706:	f222                	sd	s0,288(sp)
    80005708:	ee26                	sd	s1,280(sp)
    8000570a:	ea4a                	sd	s2,272(sp)
    8000570c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000570e:	08000613          	li	a2,128
    80005712:	ed040593          	addi	a1,s0,-304
    80005716:	4501                	li	a0,0
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	812080e7          	jalr	-2030(ra) # 80002f2a <argstr>
    return -1;
    80005720:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005722:	10054e63          	bltz	a0,8000583e <sys_link+0x13c>
    80005726:	08000613          	li	a2,128
    8000572a:	f5040593          	addi	a1,s0,-176
    8000572e:	4505                	li	a0,1
    80005730:	ffffd097          	auipc	ra,0xffffd
    80005734:	7fa080e7          	jalr	2042(ra) # 80002f2a <argstr>
    return -1;
    80005738:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000573a:	10054263          	bltz	a0,8000583e <sys_link+0x13c>
  begin_op();
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	cea080e7          	jalr	-790(ra) # 80004428 <begin_op>
  if((ip = namei(old)) == 0){
    80005746:	ed040513          	addi	a0,s0,-304
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	ac2080e7          	jalr	-1342(ra) # 8000420c <namei>
    80005752:	84aa                	mv	s1,a0
    80005754:	c551                	beqz	a0,800057e0 <sys_link+0xde>
  ilock(ip);
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	302080e7          	jalr	770(ra) # 80003a58 <ilock>
  if(ip->type == T_DIR){
    8000575e:	04c49703          	lh	a4,76(s1)
    80005762:	4785                	li	a5,1
    80005764:	08f70463          	beq	a4,a5,800057ec <sys_link+0xea>
  ip->nlink++;
    80005768:	0524d783          	lhu	a5,82(s1)
    8000576c:	2785                	addiw	a5,a5,1
    8000576e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005772:	8526                	mv	a0,s1
    80005774:	ffffe097          	auipc	ra,0xffffe
    80005778:	21a080e7          	jalr	538(ra) # 8000398e <iupdate>
  iunlock(ip);
    8000577c:	8526                	mv	a0,s1
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	39c080e7          	jalr	924(ra) # 80003b1a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005786:	fd040593          	addi	a1,s0,-48
    8000578a:	f5040513          	addi	a0,s0,-176
    8000578e:	fffff097          	auipc	ra,0xfffff
    80005792:	a9c080e7          	jalr	-1380(ra) # 8000422a <nameiparent>
    80005796:	892a                	mv	s2,a0
    80005798:	c935                	beqz	a0,8000580c <sys_link+0x10a>
  ilock(dp);
    8000579a:	ffffe097          	auipc	ra,0xffffe
    8000579e:	2be080e7          	jalr	702(ra) # 80003a58 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057a2:	00092703          	lw	a4,0(s2)
    800057a6:	409c                	lw	a5,0(s1)
    800057a8:	04f71d63          	bne	a4,a5,80005802 <sys_link+0x100>
    800057ac:	40d0                	lw	a2,4(s1)
    800057ae:	fd040593          	addi	a1,s0,-48
    800057b2:	854a                	mv	a0,s2
    800057b4:	fffff097          	auipc	ra,0xfffff
    800057b8:	996080e7          	jalr	-1642(ra) # 8000414a <dirlink>
    800057bc:	04054363          	bltz	a0,80005802 <sys_link+0x100>
  iunlockput(dp);
    800057c0:	854a                	mv	a0,s2
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	4f8080e7          	jalr	1272(ra) # 80003cba <iunlockput>
  iput(ip);
    800057ca:	8526                	mv	a0,s1
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	446080e7          	jalr	1094(ra) # 80003c12 <iput>
  end_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	cd4080e7          	jalr	-812(ra) # 800044a8 <end_op>
  return 0;
    800057dc:	4781                	li	a5,0
    800057de:	a085                	j	8000583e <sys_link+0x13c>
    end_op();
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	cc8080e7          	jalr	-824(ra) # 800044a8 <end_op>
    return -1;
    800057e8:	57fd                	li	a5,-1
    800057ea:	a891                	j	8000583e <sys_link+0x13c>
    iunlockput(ip);
    800057ec:	8526                	mv	a0,s1
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	4cc080e7          	jalr	1228(ra) # 80003cba <iunlockput>
    end_op();
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	cb2080e7          	jalr	-846(ra) # 800044a8 <end_op>
    return -1;
    800057fe:	57fd                	li	a5,-1
    80005800:	a83d                	j	8000583e <sys_link+0x13c>
    iunlockput(dp);
    80005802:	854a                	mv	a0,s2
    80005804:	ffffe097          	auipc	ra,0xffffe
    80005808:	4b6080e7          	jalr	1206(ra) # 80003cba <iunlockput>
  ilock(ip);
    8000580c:	8526                	mv	a0,s1
    8000580e:	ffffe097          	auipc	ra,0xffffe
    80005812:	24a080e7          	jalr	586(ra) # 80003a58 <ilock>
  ip->nlink--;
    80005816:	0524d783          	lhu	a5,82(s1)
    8000581a:	37fd                	addiw	a5,a5,-1
    8000581c:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005820:	8526                	mv	a0,s1
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	16c080e7          	jalr	364(ra) # 8000398e <iupdate>
  iunlockput(ip);
    8000582a:	8526                	mv	a0,s1
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	48e080e7          	jalr	1166(ra) # 80003cba <iunlockput>
  end_op();
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	c74080e7          	jalr	-908(ra) # 800044a8 <end_op>
  return -1;
    8000583c:	57fd                	li	a5,-1
}
    8000583e:	853e                	mv	a0,a5
    80005840:	70b2                	ld	ra,296(sp)
    80005842:	7412                	ld	s0,288(sp)
    80005844:	64f2                	ld	s1,280(sp)
    80005846:	6952                	ld	s2,272(sp)
    80005848:	6155                	addi	sp,sp,304
    8000584a:	8082                	ret

000000008000584c <sys_unlink>:
{
    8000584c:	7151                	addi	sp,sp,-240
    8000584e:	f586                	sd	ra,232(sp)
    80005850:	f1a2                	sd	s0,224(sp)
    80005852:	eda6                	sd	s1,216(sp)
    80005854:	e9ca                	sd	s2,208(sp)
    80005856:	e5ce                	sd	s3,200(sp)
    80005858:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000585a:	08000613          	li	a2,128
    8000585e:	f3040593          	addi	a1,s0,-208
    80005862:	4501                	li	a0,0
    80005864:	ffffd097          	auipc	ra,0xffffd
    80005868:	6c6080e7          	jalr	1734(ra) # 80002f2a <argstr>
    8000586c:	18054163          	bltz	a0,800059ee <sys_unlink+0x1a2>
  begin_op();
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	bb8080e7          	jalr	-1096(ra) # 80004428 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005878:	fb040593          	addi	a1,s0,-80
    8000587c:	f3040513          	addi	a0,s0,-208
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	9aa080e7          	jalr	-1622(ra) # 8000422a <nameiparent>
    80005888:	84aa                	mv	s1,a0
    8000588a:	c979                	beqz	a0,80005960 <sys_unlink+0x114>
  ilock(dp);
    8000588c:	ffffe097          	auipc	ra,0xffffe
    80005890:	1cc080e7          	jalr	460(ra) # 80003a58 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005894:	00003597          	auipc	a1,0x3
    80005898:	edc58593          	addi	a1,a1,-292 # 80008770 <syscalls+0x2b8>
    8000589c:	fb040513          	addi	a0,s0,-80
    800058a0:	ffffe097          	auipc	ra,0xffffe
    800058a4:	680080e7          	jalr	1664(ra) # 80003f20 <namecmp>
    800058a8:	14050a63          	beqz	a0,800059fc <sys_unlink+0x1b0>
    800058ac:	00003597          	auipc	a1,0x3
    800058b0:	ecc58593          	addi	a1,a1,-308 # 80008778 <syscalls+0x2c0>
    800058b4:	fb040513          	addi	a0,s0,-80
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	668080e7          	jalr	1640(ra) # 80003f20 <namecmp>
    800058c0:	12050e63          	beqz	a0,800059fc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058c4:	f2c40613          	addi	a2,s0,-212
    800058c8:	fb040593          	addi	a1,s0,-80
    800058cc:	8526                	mv	a0,s1
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	66c080e7          	jalr	1644(ra) # 80003f3a <dirlookup>
    800058d6:	892a                	mv	s2,a0
    800058d8:	12050263          	beqz	a0,800059fc <sys_unlink+0x1b0>
  ilock(ip);
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	17c080e7          	jalr	380(ra) # 80003a58 <ilock>
  if(ip->nlink < 1)
    800058e4:	05291783          	lh	a5,82(s2)
    800058e8:	08f05263          	blez	a5,8000596c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800058ec:	04c91703          	lh	a4,76(s2)
    800058f0:	4785                	li	a5,1
    800058f2:	08f70563          	beq	a4,a5,8000597c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800058f6:	4641                	li	a2,16
    800058f8:	4581                	li	a1,0
    800058fa:	fc040513          	addi	a0,s0,-64
    800058fe:	ffffc097          	auipc	ra,0xffffc
    80005902:	8c4080e7          	jalr	-1852(ra) # 800011c2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005906:	4741                	li	a4,16
    80005908:	f2c42683          	lw	a3,-212(s0)
    8000590c:	fc040613          	addi	a2,s0,-64
    80005910:	4581                	li	a1,0
    80005912:	8526                	mv	a0,s1
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	4f0080e7          	jalr	1264(ra) # 80003e04 <writei>
    8000591c:	47c1                	li	a5,16
    8000591e:	0af51563          	bne	a0,a5,800059c8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005922:	04c91703          	lh	a4,76(s2)
    80005926:	4785                	li	a5,1
    80005928:	0af70863          	beq	a4,a5,800059d8 <sys_unlink+0x18c>
  iunlockput(dp);
    8000592c:	8526                	mv	a0,s1
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	38c080e7          	jalr	908(ra) # 80003cba <iunlockput>
  ip->nlink--;
    80005936:	05295783          	lhu	a5,82(s2)
    8000593a:	37fd                	addiw	a5,a5,-1
    8000593c:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005940:	854a                	mv	a0,s2
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	04c080e7          	jalr	76(ra) # 8000398e <iupdate>
  iunlockput(ip);
    8000594a:	854a                	mv	a0,s2
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	36e080e7          	jalr	878(ra) # 80003cba <iunlockput>
  end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	b54080e7          	jalr	-1196(ra) # 800044a8 <end_op>
  return 0;
    8000595c:	4501                	li	a0,0
    8000595e:	a84d                	j	80005a10 <sys_unlink+0x1c4>
    end_op();
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	b48080e7          	jalr	-1208(ra) # 800044a8 <end_op>
    return -1;
    80005968:	557d                	li	a0,-1
    8000596a:	a05d                	j	80005a10 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000596c:	00003517          	auipc	a0,0x3
    80005970:	e3450513          	addi	a0,a0,-460 # 800087a0 <syscalls+0x2e8>
    80005974:	ffffb097          	auipc	ra,0xffffb
    80005978:	bdc080e7          	jalr	-1060(ra) # 80000550 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000597c:	05492703          	lw	a4,84(s2)
    80005980:	02000793          	li	a5,32
    80005984:	f6e7f9e3          	bgeu	a5,a4,800058f6 <sys_unlink+0xaa>
    80005988:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000598c:	4741                	li	a4,16
    8000598e:	86ce                	mv	a3,s3
    80005990:	f1840613          	addi	a2,s0,-232
    80005994:	4581                	li	a1,0
    80005996:	854a                	mv	a0,s2
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	374080e7          	jalr	884(ra) # 80003d0c <readi>
    800059a0:	47c1                	li	a5,16
    800059a2:	00f51b63          	bne	a0,a5,800059b8 <sys_unlink+0x16c>
    if(de.inum != 0)
    800059a6:	f1845783          	lhu	a5,-232(s0)
    800059aa:	e7a1                	bnez	a5,800059f2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059ac:	29c1                	addiw	s3,s3,16
    800059ae:	05492783          	lw	a5,84(s2)
    800059b2:	fcf9ede3          	bltu	s3,a5,8000598c <sys_unlink+0x140>
    800059b6:	b781                	j	800058f6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059b8:	00003517          	auipc	a0,0x3
    800059bc:	e0050513          	addi	a0,a0,-512 # 800087b8 <syscalls+0x300>
    800059c0:	ffffb097          	auipc	ra,0xffffb
    800059c4:	b90080e7          	jalr	-1136(ra) # 80000550 <panic>
    panic("unlink: writei");
    800059c8:	00003517          	auipc	a0,0x3
    800059cc:	e0850513          	addi	a0,a0,-504 # 800087d0 <syscalls+0x318>
    800059d0:	ffffb097          	auipc	ra,0xffffb
    800059d4:	b80080e7          	jalr	-1152(ra) # 80000550 <panic>
    dp->nlink--;
    800059d8:	0524d783          	lhu	a5,82(s1)
    800059dc:	37fd                	addiw	a5,a5,-1
    800059de:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    800059e2:	8526                	mv	a0,s1
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	faa080e7          	jalr	-86(ra) # 8000398e <iupdate>
    800059ec:	b781                	j	8000592c <sys_unlink+0xe0>
    return -1;
    800059ee:	557d                	li	a0,-1
    800059f0:	a005                	j	80005a10 <sys_unlink+0x1c4>
    iunlockput(ip);
    800059f2:	854a                	mv	a0,s2
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	2c6080e7          	jalr	710(ra) # 80003cba <iunlockput>
  iunlockput(dp);
    800059fc:	8526                	mv	a0,s1
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	2bc080e7          	jalr	700(ra) # 80003cba <iunlockput>
  end_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	aa2080e7          	jalr	-1374(ra) # 800044a8 <end_op>
  return -1;
    80005a0e:	557d                	li	a0,-1
}
    80005a10:	70ae                	ld	ra,232(sp)
    80005a12:	740e                	ld	s0,224(sp)
    80005a14:	64ee                	ld	s1,216(sp)
    80005a16:	694e                	ld	s2,208(sp)
    80005a18:	69ae                	ld	s3,200(sp)
    80005a1a:	616d                	addi	sp,sp,240
    80005a1c:	8082                	ret

0000000080005a1e <sys_open>:

uint64
sys_open(void)
{
    80005a1e:	7131                	addi	sp,sp,-192
    80005a20:	fd06                	sd	ra,184(sp)
    80005a22:	f922                	sd	s0,176(sp)
    80005a24:	f526                	sd	s1,168(sp)
    80005a26:	f14a                	sd	s2,160(sp)
    80005a28:	ed4e                	sd	s3,152(sp)
    80005a2a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a2c:	08000613          	li	a2,128
    80005a30:	f5040593          	addi	a1,s0,-176
    80005a34:	4501                	li	a0,0
    80005a36:	ffffd097          	auipc	ra,0xffffd
    80005a3a:	4f4080e7          	jalr	1268(ra) # 80002f2a <argstr>
    return -1;
    80005a3e:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a40:	0c054163          	bltz	a0,80005b02 <sys_open+0xe4>
    80005a44:	f4c40593          	addi	a1,s0,-180
    80005a48:	4505                	li	a0,1
    80005a4a:	ffffd097          	auipc	ra,0xffffd
    80005a4e:	49c080e7          	jalr	1180(ra) # 80002ee6 <argint>
    80005a52:	0a054863          	bltz	a0,80005b02 <sys_open+0xe4>

  begin_op();
    80005a56:	fffff097          	auipc	ra,0xfffff
    80005a5a:	9d2080e7          	jalr	-1582(ra) # 80004428 <begin_op>

  if(omode & O_CREATE){
    80005a5e:	f4c42783          	lw	a5,-180(s0)
    80005a62:	2007f793          	andi	a5,a5,512
    80005a66:	cbdd                	beqz	a5,80005b1c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a68:	4681                	li	a3,0
    80005a6a:	4601                	li	a2,0
    80005a6c:	4589                	li	a1,2
    80005a6e:	f5040513          	addi	a0,s0,-176
    80005a72:	00000097          	auipc	ra,0x0
    80005a76:	974080e7          	jalr	-1676(ra) # 800053e6 <create>
    80005a7a:	892a                	mv	s2,a0
    if(ip == 0){
    80005a7c:	c959                	beqz	a0,80005b12 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a7e:	04c91703          	lh	a4,76(s2)
    80005a82:	478d                	li	a5,3
    80005a84:	00f71763          	bne	a4,a5,80005a92 <sys_open+0x74>
    80005a88:	04e95703          	lhu	a4,78(s2)
    80005a8c:	47a5                	li	a5,9
    80005a8e:	0ce7ec63          	bltu	a5,a4,80005b66 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	dae080e7          	jalr	-594(ra) # 80004840 <filealloc>
    80005a9a:	89aa                	mv	s3,a0
    80005a9c:	10050263          	beqz	a0,80005ba0 <sys_open+0x182>
    80005aa0:	00000097          	auipc	ra,0x0
    80005aa4:	904080e7          	jalr	-1788(ra) # 800053a4 <fdalloc>
    80005aa8:	84aa                	mv	s1,a0
    80005aaa:	0e054663          	bltz	a0,80005b96 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005aae:	04c91703          	lh	a4,76(s2)
    80005ab2:	478d                	li	a5,3
    80005ab4:	0cf70463          	beq	a4,a5,80005b7c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ab8:	4789                	li	a5,2
    80005aba:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005abe:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ac2:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ac6:	f4c42783          	lw	a5,-180(s0)
    80005aca:	0017c713          	xori	a4,a5,1
    80005ace:	8b05                	andi	a4,a4,1
    80005ad0:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ad4:	0037f713          	andi	a4,a5,3
    80005ad8:	00e03733          	snez	a4,a4
    80005adc:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ae0:	4007f793          	andi	a5,a5,1024
    80005ae4:	c791                	beqz	a5,80005af0 <sys_open+0xd2>
    80005ae6:	04c91703          	lh	a4,76(s2)
    80005aea:	4789                	li	a5,2
    80005aec:	08f70f63          	beq	a4,a5,80005b8a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005af0:	854a                	mv	a0,s2
    80005af2:	ffffe097          	auipc	ra,0xffffe
    80005af6:	028080e7          	jalr	40(ra) # 80003b1a <iunlock>
  end_op();
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	9ae080e7          	jalr	-1618(ra) # 800044a8 <end_op>

  return fd;
}
    80005b02:	8526                	mv	a0,s1
    80005b04:	70ea                	ld	ra,184(sp)
    80005b06:	744a                	ld	s0,176(sp)
    80005b08:	74aa                	ld	s1,168(sp)
    80005b0a:	790a                	ld	s2,160(sp)
    80005b0c:	69ea                	ld	s3,152(sp)
    80005b0e:	6129                	addi	sp,sp,192
    80005b10:	8082                	ret
      end_op();
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	996080e7          	jalr	-1642(ra) # 800044a8 <end_op>
      return -1;
    80005b1a:	b7e5                	j	80005b02 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b1c:	f5040513          	addi	a0,s0,-176
    80005b20:	ffffe097          	auipc	ra,0xffffe
    80005b24:	6ec080e7          	jalr	1772(ra) # 8000420c <namei>
    80005b28:	892a                	mv	s2,a0
    80005b2a:	c905                	beqz	a0,80005b5a <sys_open+0x13c>
    ilock(ip);
    80005b2c:	ffffe097          	auipc	ra,0xffffe
    80005b30:	f2c080e7          	jalr	-212(ra) # 80003a58 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b34:	04c91703          	lh	a4,76(s2)
    80005b38:	4785                	li	a5,1
    80005b3a:	f4f712e3          	bne	a4,a5,80005a7e <sys_open+0x60>
    80005b3e:	f4c42783          	lw	a5,-180(s0)
    80005b42:	dba1                	beqz	a5,80005a92 <sys_open+0x74>
      iunlockput(ip);
    80005b44:	854a                	mv	a0,s2
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	174080e7          	jalr	372(ra) # 80003cba <iunlockput>
      end_op();
    80005b4e:	fffff097          	auipc	ra,0xfffff
    80005b52:	95a080e7          	jalr	-1702(ra) # 800044a8 <end_op>
      return -1;
    80005b56:	54fd                	li	s1,-1
    80005b58:	b76d                	j	80005b02 <sys_open+0xe4>
      end_op();
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	94e080e7          	jalr	-1714(ra) # 800044a8 <end_op>
      return -1;
    80005b62:	54fd                	li	s1,-1
    80005b64:	bf79                	j	80005b02 <sys_open+0xe4>
    iunlockput(ip);
    80005b66:	854a                	mv	a0,s2
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	152080e7          	jalr	338(ra) # 80003cba <iunlockput>
    end_op();
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	938080e7          	jalr	-1736(ra) # 800044a8 <end_op>
    return -1;
    80005b78:	54fd                	li	s1,-1
    80005b7a:	b761                	j	80005b02 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b7c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b80:	04e91783          	lh	a5,78(s2)
    80005b84:	02f99223          	sh	a5,36(s3)
    80005b88:	bf2d                	j	80005ac2 <sys_open+0xa4>
    itrunc(ip);
    80005b8a:	854a                	mv	a0,s2
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	fda080e7          	jalr	-38(ra) # 80003b66 <itrunc>
    80005b94:	bfb1                	j	80005af0 <sys_open+0xd2>
      fileclose(f);
    80005b96:	854e                	mv	a0,s3
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	d64080e7          	jalr	-668(ra) # 800048fc <fileclose>
    iunlockput(ip);
    80005ba0:	854a                	mv	a0,s2
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	118080e7          	jalr	280(ra) # 80003cba <iunlockput>
    end_op();
    80005baa:	fffff097          	auipc	ra,0xfffff
    80005bae:	8fe080e7          	jalr	-1794(ra) # 800044a8 <end_op>
    return -1;
    80005bb2:	54fd                	li	s1,-1
    80005bb4:	b7b9                	j	80005b02 <sys_open+0xe4>

0000000080005bb6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bb6:	7175                	addi	sp,sp,-144
    80005bb8:	e506                	sd	ra,136(sp)
    80005bba:	e122                	sd	s0,128(sp)
    80005bbc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bbe:	fffff097          	auipc	ra,0xfffff
    80005bc2:	86a080e7          	jalr	-1942(ra) # 80004428 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bc6:	08000613          	li	a2,128
    80005bca:	f7040593          	addi	a1,s0,-144
    80005bce:	4501                	li	a0,0
    80005bd0:	ffffd097          	auipc	ra,0xffffd
    80005bd4:	35a080e7          	jalr	858(ra) # 80002f2a <argstr>
    80005bd8:	02054963          	bltz	a0,80005c0a <sys_mkdir+0x54>
    80005bdc:	4681                	li	a3,0
    80005bde:	4601                	li	a2,0
    80005be0:	4585                	li	a1,1
    80005be2:	f7040513          	addi	a0,s0,-144
    80005be6:	00000097          	auipc	ra,0x0
    80005bea:	800080e7          	jalr	-2048(ra) # 800053e6 <create>
    80005bee:	cd11                	beqz	a0,80005c0a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bf0:	ffffe097          	auipc	ra,0xffffe
    80005bf4:	0ca080e7          	jalr	202(ra) # 80003cba <iunlockput>
  end_op();
    80005bf8:	fffff097          	auipc	ra,0xfffff
    80005bfc:	8b0080e7          	jalr	-1872(ra) # 800044a8 <end_op>
  return 0;
    80005c00:	4501                	li	a0,0
}
    80005c02:	60aa                	ld	ra,136(sp)
    80005c04:	640a                	ld	s0,128(sp)
    80005c06:	6149                	addi	sp,sp,144
    80005c08:	8082                	ret
    end_op();
    80005c0a:	fffff097          	auipc	ra,0xfffff
    80005c0e:	89e080e7          	jalr	-1890(ra) # 800044a8 <end_op>
    return -1;
    80005c12:	557d                	li	a0,-1
    80005c14:	b7fd                	j	80005c02 <sys_mkdir+0x4c>

0000000080005c16 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c16:	7135                	addi	sp,sp,-160
    80005c18:	ed06                	sd	ra,152(sp)
    80005c1a:	e922                	sd	s0,144(sp)
    80005c1c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	80a080e7          	jalr	-2038(ra) # 80004428 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c26:	08000613          	li	a2,128
    80005c2a:	f7040593          	addi	a1,s0,-144
    80005c2e:	4501                	li	a0,0
    80005c30:	ffffd097          	auipc	ra,0xffffd
    80005c34:	2fa080e7          	jalr	762(ra) # 80002f2a <argstr>
    80005c38:	04054a63          	bltz	a0,80005c8c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005c3c:	f6c40593          	addi	a1,s0,-148
    80005c40:	4505                	li	a0,1
    80005c42:	ffffd097          	auipc	ra,0xffffd
    80005c46:	2a4080e7          	jalr	676(ra) # 80002ee6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c4a:	04054163          	bltz	a0,80005c8c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c4e:	f6840593          	addi	a1,s0,-152
    80005c52:	4509                	li	a0,2
    80005c54:	ffffd097          	auipc	ra,0xffffd
    80005c58:	292080e7          	jalr	658(ra) # 80002ee6 <argint>
     argint(1, &major) < 0 ||
    80005c5c:	02054863          	bltz	a0,80005c8c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c60:	f6841683          	lh	a3,-152(s0)
    80005c64:	f6c41603          	lh	a2,-148(s0)
    80005c68:	458d                	li	a1,3
    80005c6a:	f7040513          	addi	a0,s0,-144
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	778080e7          	jalr	1912(ra) # 800053e6 <create>
     argint(2, &minor) < 0 ||
    80005c76:	c919                	beqz	a0,80005c8c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c78:	ffffe097          	auipc	ra,0xffffe
    80005c7c:	042080e7          	jalr	66(ra) # 80003cba <iunlockput>
  end_op();
    80005c80:	fffff097          	auipc	ra,0xfffff
    80005c84:	828080e7          	jalr	-2008(ra) # 800044a8 <end_op>
  return 0;
    80005c88:	4501                	li	a0,0
    80005c8a:	a031                	j	80005c96 <sys_mknod+0x80>
    end_op();
    80005c8c:	fffff097          	auipc	ra,0xfffff
    80005c90:	81c080e7          	jalr	-2020(ra) # 800044a8 <end_op>
    return -1;
    80005c94:	557d                	li	a0,-1
}
    80005c96:	60ea                	ld	ra,152(sp)
    80005c98:	644a                	ld	s0,144(sp)
    80005c9a:	610d                	addi	sp,sp,160
    80005c9c:	8082                	ret

0000000080005c9e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c9e:	7135                	addi	sp,sp,-160
    80005ca0:	ed06                	sd	ra,152(sp)
    80005ca2:	e922                	sd	s0,144(sp)
    80005ca4:	e526                	sd	s1,136(sp)
    80005ca6:	e14a                	sd	s2,128(sp)
    80005ca8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005caa:	ffffc097          	auipc	ra,0xffffc
    80005cae:	180080e7          	jalr	384(ra) # 80001e2a <myproc>
    80005cb2:	892a                	mv	s2,a0
  
  begin_op();
    80005cb4:	ffffe097          	auipc	ra,0xffffe
    80005cb8:	774080e7          	jalr	1908(ra) # 80004428 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cbc:	08000613          	li	a2,128
    80005cc0:	f6040593          	addi	a1,s0,-160
    80005cc4:	4501                	li	a0,0
    80005cc6:	ffffd097          	auipc	ra,0xffffd
    80005cca:	264080e7          	jalr	612(ra) # 80002f2a <argstr>
    80005cce:	04054b63          	bltz	a0,80005d24 <sys_chdir+0x86>
    80005cd2:	f6040513          	addi	a0,s0,-160
    80005cd6:	ffffe097          	auipc	ra,0xffffe
    80005cda:	536080e7          	jalr	1334(ra) # 8000420c <namei>
    80005cde:	84aa                	mv	s1,a0
    80005ce0:	c131                	beqz	a0,80005d24 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ce2:	ffffe097          	auipc	ra,0xffffe
    80005ce6:	d76080e7          	jalr	-650(ra) # 80003a58 <ilock>
  if(ip->type != T_DIR){
    80005cea:	04c49703          	lh	a4,76(s1)
    80005cee:	4785                	li	a5,1
    80005cf0:	04f71063          	bne	a4,a5,80005d30 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005cf4:	8526                	mv	a0,s1
    80005cf6:	ffffe097          	auipc	ra,0xffffe
    80005cfa:	e24080e7          	jalr	-476(ra) # 80003b1a <iunlock>
  iput(p->cwd);
    80005cfe:	15893503          	ld	a0,344(s2)
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	f10080e7          	jalr	-240(ra) # 80003c12 <iput>
  end_op();
    80005d0a:	ffffe097          	auipc	ra,0xffffe
    80005d0e:	79e080e7          	jalr	1950(ra) # 800044a8 <end_op>
  p->cwd = ip;
    80005d12:	14993c23          	sd	s1,344(s2)
  return 0;
    80005d16:	4501                	li	a0,0
}
    80005d18:	60ea                	ld	ra,152(sp)
    80005d1a:	644a                	ld	s0,144(sp)
    80005d1c:	64aa                	ld	s1,136(sp)
    80005d1e:	690a                	ld	s2,128(sp)
    80005d20:	610d                	addi	sp,sp,160
    80005d22:	8082                	ret
    end_op();
    80005d24:	ffffe097          	auipc	ra,0xffffe
    80005d28:	784080e7          	jalr	1924(ra) # 800044a8 <end_op>
    return -1;
    80005d2c:	557d                	li	a0,-1
    80005d2e:	b7ed                	j	80005d18 <sys_chdir+0x7a>
    iunlockput(ip);
    80005d30:	8526                	mv	a0,s1
    80005d32:	ffffe097          	auipc	ra,0xffffe
    80005d36:	f88080e7          	jalr	-120(ra) # 80003cba <iunlockput>
    end_op();
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	76e080e7          	jalr	1902(ra) # 800044a8 <end_op>
    return -1;
    80005d42:	557d                	li	a0,-1
    80005d44:	bfd1                	j	80005d18 <sys_chdir+0x7a>

0000000080005d46 <sys_exec>:

uint64
sys_exec(void)
{
    80005d46:	7145                	addi	sp,sp,-464
    80005d48:	e786                	sd	ra,456(sp)
    80005d4a:	e3a2                	sd	s0,448(sp)
    80005d4c:	ff26                	sd	s1,440(sp)
    80005d4e:	fb4a                	sd	s2,432(sp)
    80005d50:	f74e                	sd	s3,424(sp)
    80005d52:	f352                	sd	s4,416(sp)
    80005d54:	ef56                	sd	s5,408(sp)
    80005d56:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d58:	08000613          	li	a2,128
    80005d5c:	f4040593          	addi	a1,s0,-192
    80005d60:	4501                	li	a0,0
    80005d62:	ffffd097          	auipc	ra,0xffffd
    80005d66:	1c8080e7          	jalr	456(ra) # 80002f2a <argstr>
    return -1;
    80005d6a:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d6c:	0c054a63          	bltz	a0,80005e40 <sys_exec+0xfa>
    80005d70:	e3840593          	addi	a1,s0,-456
    80005d74:	4505                	li	a0,1
    80005d76:	ffffd097          	auipc	ra,0xffffd
    80005d7a:	192080e7          	jalr	402(ra) # 80002f08 <argaddr>
    80005d7e:	0c054163          	bltz	a0,80005e40 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005d82:	10000613          	li	a2,256
    80005d86:	4581                	li	a1,0
    80005d88:	e4040513          	addi	a0,s0,-448
    80005d8c:	ffffb097          	auipc	ra,0xffffb
    80005d90:	436080e7          	jalr	1078(ra) # 800011c2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d94:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d98:	89a6                	mv	s3,s1
    80005d9a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d9c:	02000a13          	li	s4,32
    80005da0:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005da4:	00391513          	slli	a0,s2,0x3
    80005da8:	e3040593          	addi	a1,s0,-464
    80005dac:	e3843783          	ld	a5,-456(s0)
    80005db0:	953e                	add	a0,a0,a5
    80005db2:	ffffd097          	auipc	ra,0xffffd
    80005db6:	09a080e7          	jalr	154(ra) # 80002e4c <fetchaddr>
    80005dba:	02054a63          	bltz	a0,80005dee <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005dbe:	e3043783          	ld	a5,-464(s0)
    80005dc2:	c3b9                	beqz	a5,80005e08 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005dc4:	ffffb097          	auipc	ra,0xffffb
    80005dc8:	eb4080e7          	jalr	-332(ra) # 80000c78 <kalloc>
    80005dcc:	85aa                	mv	a1,a0
    80005dce:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005dd2:	cd11                	beqz	a0,80005dee <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005dd4:	6605                	lui	a2,0x1
    80005dd6:	e3043503          	ld	a0,-464(s0)
    80005dda:	ffffd097          	auipc	ra,0xffffd
    80005dde:	0c4080e7          	jalr	196(ra) # 80002e9e <fetchstr>
    80005de2:	00054663          	bltz	a0,80005dee <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005de6:	0905                	addi	s2,s2,1
    80005de8:	09a1                	addi	s3,s3,8
    80005dea:	fb491be3          	bne	s2,s4,80005da0 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dee:	10048913          	addi	s2,s1,256
    80005df2:	6088                	ld	a0,0(s1)
    80005df4:	c529                	beqz	a0,80005e3e <sys_exec+0xf8>
    kfree(argv[i]);
    80005df6:	ffffb097          	auipc	ra,0xffffb
    80005dfa:	d92080e7          	jalr	-622(ra) # 80000b88 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dfe:	04a1                	addi	s1,s1,8
    80005e00:	ff2499e3          	bne	s1,s2,80005df2 <sys_exec+0xac>
  return -1;
    80005e04:	597d                	li	s2,-1
    80005e06:	a82d                	j	80005e40 <sys_exec+0xfa>
      argv[i] = 0;
    80005e08:	0a8e                	slli	s5,s5,0x3
    80005e0a:	fc040793          	addi	a5,s0,-64
    80005e0e:	9abe                	add	s5,s5,a5
    80005e10:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e14:	e4040593          	addi	a1,s0,-448
    80005e18:	f4040513          	addi	a0,s0,-192
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	196080e7          	jalr	406(ra) # 80004fb2 <exec>
    80005e24:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e26:	10048993          	addi	s3,s1,256
    80005e2a:	6088                	ld	a0,0(s1)
    80005e2c:	c911                	beqz	a0,80005e40 <sys_exec+0xfa>
    kfree(argv[i]);
    80005e2e:	ffffb097          	auipc	ra,0xffffb
    80005e32:	d5a080e7          	jalr	-678(ra) # 80000b88 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e36:	04a1                	addi	s1,s1,8
    80005e38:	ff3499e3          	bne	s1,s3,80005e2a <sys_exec+0xe4>
    80005e3c:	a011                	j	80005e40 <sys_exec+0xfa>
  return -1;
    80005e3e:	597d                	li	s2,-1
}
    80005e40:	854a                	mv	a0,s2
    80005e42:	60be                	ld	ra,456(sp)
    80005e44:	641e                	ld	s0,448(sp)
    80005e46:	74fa                	ld	s1,440(sp)
    80005e48:	795a                	ld	s2,432(sp)
    80005e4a:	79ba                	ld	s3,424(sp)
    80005e4c:	7a1a                	ld	s4,416(sp)
    80005e4e:	6afa                	ld	s5,408(sp)
    80005e50:	6179                	addi	sp,sp,464
    80005e52:	8082                	ret

0000000080005e54 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e54:	7139                	addi	sp,sp,-64
    80005e56:	fc06                	sd	ra,56(sp)
    80005e58:	f822                	sd	s0,48(sp)
    80005e5a:	f426                	sd	s1,40(sp)
    80005e5c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e5e:	ffffc097          	auipc	ra,0xffffc
    80005e62:	fcc080e7          	jalr	-52(ra) # 80001e2a <myproc>
    80005e66:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e68:	fd840593          	addi	a1,s0,-40
    80005e6c:	4501                	li	a0,0
    80005e6e:	ffffd097          	auipc	ra,0xffffd
    80005e72:	09a080e7          	jalr	154(ra) # 80002f08 <argaddr>
    return -1;
    80005e76:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005e78:	0e054063          	bltz	a0,80005f58 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005e7c:	fc840593          	addi	a1,s0,-56
    80005e80:	fd040513          	addi	a0,s0,-48
    80005e84:	fffff097          	auipc	ra,0xfffff
    80005e88:	dce080e7          	jalr	-562(ra) # 80004c52 <pipealloc>
    return -1;
    80005e8c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e8e:	0c054563          	bltz	a0,80005f58 <sys_pipe+0x104>
  fd0 = -1;
    80005e92:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e96:	fd043503          	ld	a0,-48(s0)
    80005e9a:	fffff097          	auipc	ra,0xfffff
    80005e9e:	50a080e7          	jalr	1290(ra) # 800053a4 <fdalloc>
    80005ea2:	fca42223          	sw	a0,-60(s0)
    80005ea6:	08054c63          	bltz	a0,80005f3e <sys_pipe+0xea>
    80005eaa:	fc843503          	ld	a0,-56(s0)
    80005eae:	fffff097          	auipc	ra,0xfffff
    80005eb2:	4f6080e7          	jalr	1270(ra) # 800053a4 <fdalloc>
    80005eb6:	fca42023          	sw	a0,-64(s0)
    80005eba:	06054863          	bltz	a0,80005f2a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ebe:	4691                	li	a3,4
    80005ec0:	fc440613          	addi	a2,s0,-60
    80005ec4:	fd843583          	ld	a1,-40(s0)
    80005ec8:	6ca8                	ld	a0,88(s1)
    80005eca:	ffffc097          	auipc	ra,0xffffc
    80005ece:	c54080e7          	jalr	-940(ra) # 80001b1e <copyout>
    80005ed2:	02054063          	bltz	a0,80005ef2 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ed6:	4691                	li	a3,4
    80005ed8:	fc040613          	addi	a2,s0,-64
    80005edc:	fd843583          	ld	a1,-40(s0)
    80005ee0:	0591                	addi	a1,a1,4
    80005ee2:	6ca8                	ld	a0,88(s1)
    80005ee4:	ffffc097          	auipc	ra,0xffffc
    80005ee8:	c3a080e7          	jalr	-966(ra) # 80001b1e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005eec:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005eee:	06055563          	bgez	a0,80005f58 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005ef2:	fc442783          	lw	a5,-60(s0)
    80005ef6:	07e9                	addi	a5,a5,26
    80005ef8:	078e                	slli	a5,a5,0x3
    80005efa:	97a6                	add	a5,a5,s1
    80005efc:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005f00:	fc042503          	lw	a0,-64(s0)
    80005f04:	0569                	addi	a0,a0,26
    80005f06:	050e                	slli	a0,a0,0x3
    80005f08:	9526                	add	a0,a0,s1
    80005f0a:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005f0e:	fd043503          	ld	a0,-48(s0)
    80005f12:	fffff097          	auipc	ra,0xfffff
    80005f16:	9ea080e7          	jalr	-1558(ra) # 800048fc <fileclose>
    fileclose(wf);
    80005f1a:	fc843503          	ld	a0,-56(s0)
    80005f1e:	fffff097          	auipc	ra,0xfffff
    80005f22:	9de080e7          	jalr	-1570(ra) # 800048fc <fileclose>
    return -1;
    80005f26:	57fd                	li	a5,-1
    80005f28:	a805                	j	80005f58 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005f2a:	fc442783          	lw	a5,-60(s0)
    80005f2e:	0007c863          	bltz	a5,80005f3e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005f32:	01a78513          	addi	a0,a5,26
    80005f36:	050e                	slli	a0,a0,0x3
    80005f38:	9526                	add	a0,a0,s1
    80005f3a:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005f3e:	fd043503          	ld	a0,-48(s0)
    80005f42:	fffff097          	auipc	ra,0xfffff
    80005f46:	9ba080e7          	jalr	-1606(ra) # 800048fc <fileclose>
    fileclose(wf);
    80005f4a:	fc843503          	ld	a0,-56(s0)
    80005f4e:	fffff097          	auipc	ra,0xfffff
    80005f52:	9ae080e7          	jalr	-1618(ra) # 800048fc <fileclose>
    return -1;
    80005f56:	57fd                	li	a5,-1
}
    80005f58:	853e                	mv	a0,a5
    80005f5a:	70e2                	ld	ra,56(sp)
    80005f5c:	7442                	ld	s0,48(sp)
    80005f5e:	74a2                	ld	s1,40(sp)
    80005f60:	6121                	addi	sp,sp,64
    80005f62:	8082                	ret
	...

0000000080005f70 <kernelvec>:
    80005f70:	7111                	addi	sp,sp,-256
    80005f72:	e006                	sd	ra,0(sp)
    80005f74:	e40a                	sd	sp,8(sp)
    80005f76:	e80e                	sd	gp,16(sp)
    80005f78:	ec12                	sd	tp,24(sp)
    80005f7a:	f016                	sd	t0,32(sp)
    80005f7c:	f41a                	sd	t1,40(sp)
    80005f7e:	f81e                	sd	t2,48(sp)
    80005f80:	fc22                	sd	s0,56(sp)
    80005f82:	e0a6                	sd	s1,64(sp)
    80005f84:	e4aa                	sd	a0,72(sp)
    80005f86:	e8ae                	sd	a1,80(sp)
    80005f88:	ecb2                	sd	a2,88(sp)
    80005f8a:	f0b6                	sd	a3,96(sp)
    80005f8c:	f4ba                	sd	a4,104(sp)
    80005f8e:	f8be                	sd	a5,112(sp)
    80005f90:	fcc2                	sd	a6,120(sp)
    80005f92:	e146                	sd	a7,128(sp)
    80005f94:	e54a                	sd	s2,136(sp)
    80005f96:	e94e                	sd	s3,144(sp)
    80005f98:	ed52                	sd	s4,152(sp)
    80005f9a:	f156                	sd	s5,160(sp)
    80005f9c:	f55a                	sd	s6,168(sp)
    80005f9e:	f95e                	sd	s7,176(sp)
    80005fa0:	fd62                	sd	s8,184(sp)
    80005fa2:	e1e6                	sd	s9,192(sp)
    80005fa4:	e5ea                	sd	s10,200(sp)
    80005fa6:	e9ee                	sd	s11,208(sp)
    80005fa8:	edf2                	sd	t3,216(sp)
    80005faa:	f1f6                	sd	t4,224(sp)
    80005fac:	f5fa                	sd	t5,232(sp)
    80005fae:	f9fe                	sd	t6,240(sp)
    80005fb0:	d69fc0ef          	jal	ra,80002d18 <kerneltrap>
    80005fb4:	6082                	ld	ra,0(sp)
    80005fb6:	6122                	ld	sp,8(sp)
    80005fb8:	61c2                	ld	gp,16(sp)
    80005fba:	7282                	ld	t0,32(sp)
    80005fbc:	7322                	ld	t1,40(sp)
    80005fbe:	73c2                	ld	t2,48(sp)
    80005fc0:	7462                	ld	s0,56(sp)
    80005fc2:	6486                	ld	s1,64(sp)
    80005fc4:	6526                	ld	a0,72(sp)
    80005fc6:	65c6                	ld	a1,80(sp)
    80005fc8:	6666                	ld	a2,88(sp)
    80005fca:	7686                	ld	a3,96(sp)
    80005fcc:	7726                	ld	a4,104(sp)
    80005fce:	77c6                	ld	a5,112(sp)
    80005fd0:	7866                	ld	a6,120(sp)
    80005fd2:	688a                	ld	a7,128(sp)
    80005fd4:	692a                	ld	s2,136(sp)
    80005fd6:	69ca                	ld	s3,144(sp)
    80005fd8:	6a6a                	ld	s4,152(sp)
    80005fda:	7a8a                	ld	s5,160(sp)
    80005fdc:	7b2a                	ld	s6,168(sp)
    80005fde:	7bca                	ld	s7,176(sp)
    80005fe0:	7c6a                	ld	s8,184(sp)
    80005fe2:	6c8e                	ld	s9,192(sp)
    80005fe4:	6d2e                	ld	s10,200(sp)
    80005fe6:	6dce                	ld	s11,208(sp)
    80005fe8:	6e6e                	ld	t3,216(sp)
    80005fea:	7e8e                	ld	t4,224(sp)
    80005fec:	7f2e                	ld	t5,232(sp)
    80005fee:	7fce                	ld	t6,240(sp)
    80005ff0:	6111                	addi	sp,sp,256
    80005ff2:	10200073          	sret
    80005ff6:	00000013          	nop
    80005ffa:	00000013          	nop
    80005ffe:	0001                	nop

0000000080006000 <timervec>:
    80006000:	34051573          	csrrw	a0,mscratch,a0
    80006004:	e10c                	sd	a1,0(a0)
    80006006:	e510                	sd	a2,8(a0)
    80006008:	e914                	sd	a3,16(a0)
    8000600a:	6d0c                	ld	a1,24(a0)
    8000600c:	7110                	ld	a2,32(a0)
    8000600e:	6194                	ld	a3,0(a1)
    80006010:	96b2                	add	a3,a3,a2
    80006012:	e194                	sd	a3,0(a1)
    80006014:	4589                	li	a1,2
    80006016:	14459073          	csrw	sip,a1
    8000601a:	6914                	ld	a3,16(a0)
    8000601c:	6510                	ld	a2,8(a0)
    8000601e:	610c                	ld	a1,0(a0)
    80006020:	34051573          	csrrw	a0,mscratch,a0
    80006024:	30200073          	mret
	...

000000008000602a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000602a:	1141                	addi	sp,sp,-16
    8000602c:	e422                	sd	s0,8(sp)
    8000602e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006030:	0c0007b7          	lui	a5,0xc000
    80006034:	4705                	li	a4,1
    80006036:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006038:	c3d8                	sw	a4,4(a5)
}
    8000603a:	6422                	ld	s0,8(sp)
    8000603c:	0141                	addi	sp,sp,16
    8000603e:	8082                	ret

0000000080006040 <plicinithart>:

void
plicinithart(void)
{
    80006040:	1141                	addi	sp,sp,-16
    80006042:	e406                	sd	ra,8(sp)
    80006044:	e022                	sd	s0,0(sp)
    80006046:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006048:	ffffc097          	auipc	ra,0xffffc
    8000604c:	db6080e7          	jalr	-586(ra) # 80001dfe <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006050:	0085171b          	slliw	a4,a0,0x8
    80006054:	0c0027b7          	lui	a5,0xc002
    80006058:	97ba                	add	a5,a5,a4
    8000605a:	40200713          	li	a4,1026
    8000605e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006062:	00d5151b          	slliw	a0,a0,0xd
    80006066:	0c2017b7          	lui	a5,0xc201
    8000606a:	953e                	add	a0,a0,a5
    8000606c:	00052023          	sw	zero,0(a0)
}
    80006070:	60a2                	ld	ra,8(sp)
    80006072:	6402                	ld	s0,0(sp)
    80006074:	0141                	addi	sp,sp,16
    80006076:	8082                	ret

0000000080006078 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006078:	1141                	addi	sp,sp,-16
    8000607a:	e406                	sd	ra,8(sp)
    8000607c:	e022                	sd	s0,0(sp)
    8000607e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006080:	ffffc097          	auipc	ra,0xffffc
    80006084:	d7e080e7          	jalr	-642(ra) # 80001dfe <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006088:	00d5179b          	slliw	a5,a0,0xd
    8000608c:	0c201537          	lui	a0,0xc201
    80006090:	953e                	add	a0,a0,a5
  return irq;
}
    80006092:	4148                	lw	a0,4(a0)
    80006094:	60a2                	ld	ra,8(sp)
    80006096:	6402                	ld	s0,0(sp)
    80006098:	0141                	addi	sp,sp,16
    8000609a:	8082                	ret

000000008000609c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000609c:	1101                	addi	sp,sp,-32
    8000609e:	ec06                	sd	ra,24(sp)
    800060a0:	e822                	sd	s0,16(sp)
    800060a2:	e426                	sd	s1,8(sp)
    800060a4:	1000                	addi	s0,sp,32
    800060a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060a8:	ffffc097          	auipc	ra,0xffffc
    800060ac:	d56080e7          	jalr	-682(ra) # 80001dfe <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060b0:	00d5151b          	slliw	a0,a0,0xd
    800060b4:	0c2017b7          	lui	a5,0xc201
    800060b8:	97aa                	add	a5,a5,a0
    800060ba:	c3c4                	sw	s1,4(a5)
}
    800060bc:	60e2                	ld	ra,24(sp)
    800060be:	6442                	ld	s0,16(sp)
    800060c0:	64a2                	ld	s1,8(sp)
    800060c2:	6105                	addi	sp,sp,32
    800060c4:	8082                	ret

00000000800060c6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060c6:	1141                	addi	sp,sp,-16
    800060c8:	e406                	sd	ra,8(sp)
    800060ca:	e022                	sd	s0,0(sp)
    800060cc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060ce:	479d                	li	a5,7
    800060d0:	06a7c963          	blt	a5,a0,80006142 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800060d4:	0001e797          	auipc	a5,0x1e
    800060d8:	f2c78793          	addi	a5,a5,-212 # 80024000 <disk>
    800060dc:	00a78733          	add	a4,a5,a0
    800060e0:	6789                	lui	a5,0x2
    800060e2:	97ba                	add	a5,a5,a4
    800060e4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800060e8:	e7ad                	bnez	a5,80006152 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060ea:	00451793          	slli	a5,a0,0x4
    800060ee:	00020717          	auipc	a4,0x20
    800060f2:	f1270713          	addi	a4,a4,-238 # 80026000 <disk+0x2000>
    800060f6:	6314                	ld	a3,0(a4)
    800060f8:	96be                	add	a3,a3,a5
    800060fa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800060fe:	6314                	ld	a3,0(a4)
    80006100:	96be                	add	a3,a3,a5
    80006102:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006106:	6314                	ld	a3,0(a4)
    80006108:	96be                	add	a3,a3,a5
    8000610a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000610e:	6318                	ld	a4,0(a4)
    80006110:	97ba                	add	a5,a5,a4
    80006112:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006116:	0001e797          	auipc	a5,0x1e
    8000611a:	eea78793          	addi	a5,a5,-278 # 80024000 <disk>
    8000611e:	97aa                	add	a5,a5,a0
    80006120:	6509                	lui	a0,0x2
    80006122:	953e                	add	a0,a0,a5
    80006124:	4785                	li	a5,1
    80006126:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000612a:	00020517          	auipc	a0,0x20
    8000612e:	eee50513          	addi	a0,a0,-274 # 80026018 <disk+0x2018>
    80006132:	ffffc097          	auipc	ra,0xffffc
    80006136:	68e080e7          	jalr	1678(ra) # 800027c0 <wakeup>
}
    8000613a:	60a2                	ld	ra,8(sp)
    8000613c:	6402                	ld	s0,0(sp)
    8000613e:	0141                	addi	sp,sp,16
    80006140:	8082                	ret
    panic("free_desc 1");
    80006142:	00002517          	auipc	a0,0x2
    80006146:	69e50513          	addi	a0,a0,1694 # 800087e0 <syscalls+0x328>
    8000614a:	ffffa097          	auipc	ra,0xffffa
    8000614e:	406080e7          	jalr	1030(ra) # 80000550 <panic>
    panic("free_desc 2");
    80006152:	00002517          	auipc	a0,0x2
    80006156:	69e50513          	addi	a0,a0,1694 # 800087f0 <syscalls+0x338>
    8000615a:	ffffa097          	auipc	ra,0xffffa
    8000615e:	3f6080e7          	jalr	1014(ra) # 80000550 <panic>

0000000080006162 <virtio_disk_init>:
{
    80006162:	1101                	addi	sp,sp,-32
    80006164:	ec06                	sd	ra,24(sp)
    80006166:	e822                	sd	s0,16(sp)
    80006168:	e426                	sd	s1,8(sp)
    8000616a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000616c:	00002597          	auipc	a1,0x2
    80006170:	69458593          	addi	a1,a1,1684 # 80008800 <syscalls+0x348>
    80006174:	00020517          	auipc	a0,0x20
    80006178:	fb450513          	addi	a0,a0,-76 # 80026128 <disk+0x2128>
    8000617c:	ffffb097          	auipc	ra,0xffffb
    80006180:	de2080e7          	jalr	-542(ra) # 80000f5e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006184:	100017b7          	lui	a5,0x10001
    80006188:	4398                	lw	a4,0(a5)
    8000618a:	2701                	sext.w	a4,a4
    8000618c:	747277b7          	lui	a5,0x74727
    80006190:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006194:	0ef71163          	bne	a4,a5,80006276 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006198:	100017b7          	lui	a5,0x10001
    8000619c:	43dc                	lw	a5,4(a5)
    8000619e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061a0:	4705                	li	a4,1
    800061a2:	0ce79a63          	bne	a5,a4,80006276 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061a6:	100017b7          	lui	a5,0x10001
    800061aa:	479c                	lw	a5,8(a5)
    800061ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061ae:	4709                	li	a4,2
    800061b0:	0ce79363          	bne	a5,a4,80006276 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061b4:	100017b7          	lui	a5,0x10001
    800061b8:	47d8                	lw	a4,12(a5)
    800061ba:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061bc:	554d47b7          	lui	a5,0x554d4
    800061c0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061c4:	0af71963          	bne	a4,a5,80006276 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c8:	100017b7          	lui	a5,0x10001
    800061cc:	4705                	li	a4,1
    800061ce:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d0:	470d                	li	a4,3
    800061d2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061d4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061d6:	c7ffe737          	lui	a4,0xc7ffe
    800061da:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd6737>
    800061de:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061e0:	2701                	sext.w	a4,a4
    800061e2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e4:	472d                	li	a4,11
    800061e6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e8:	473d                	li	a4,15
    800061ea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061ec:	6705                	lui	a4,0x1
    800061ee:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061f0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061f4:	5bdc                	lw	a5,52(a5)
    800061f6:	2781                	sext.w	a5,a5
  if(max == 0)
    800061f8:	c7d9                	beqz	a5,80006286 <virtio_disk_init+0x124>
  if(max < NUM)
    800061fa:	471d                	li	a4,7
    800061fc:	08f77d63          	bgeu	a4,a5,80006296 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006200:	100014b7          	lui	s1,0x10001
    80006204:	47a1                	li	a5,8
    80006206:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006208:	6609                	lui	a2,0x2
    8000620a:	4581                	li	a1,0
    8000620c:	0001e517          	auipc	a0,0x1e
    80006210:	df450513          	addi	a0,a0,-524 # 80024000 <disk>
    80006214:	ffffb097          	auipc	ra,0xffffb
    80006218:	fae080e7          	jalr	-82(ra) # 800011c2 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000621c:	0001e717          	auipc	a4,0x1e
    80006220:	de470713          	addi	a4,a4,-540 # 80024000 <disk>
    80006224:	00c75793          	srli	a5,a4,0xc
    80006228:	2781                	sext.w	a5,a5
    8000622a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000622c:	00020797          	auipc	a5,0x20
    80006230:	dd478793          	addi	a5,a5,-556 # 80026000 <disk+0x2000>
    80006234:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006236:	0001e717          	auipc	a4,0x1e
    8000623a:	e4a70713          	addi	a4,a4,-438 # 80024080 <disk+0x80>
    8000623e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006240:	0001f717          	auipc	a4,0x1f
    80006244:	dc070713          	addi	a4,a4,-576 # 80025000 <disk+0x1000>
    80006248:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000624a:	4705                	li	a4,1
    8000624c:	00e78c23          	sb	a4,24(a5)
    80006250:	00e78ca3          	sb	a4,25(a5)
    80006254:	00e78d23          	sb	a4,26(a5)
    80006258:	00e78da3          	sb	a4,27(a5)
    8000625c:	00e78e23          	sb	a4,28(a5)
    80006260:	00e78ea3          	sb	a4,29(a5)
    80006264:	00e78f23          	sb	a4,30(a5)
    80006268:	00e78fa3          	sb	a4,31(a5)
}
    8000626c:	60e2                	ld	ra,24(sp)
    8000626e:	6442                	ld	s0,16(sp)
    80006270:	64a2                	ld	s1,8(sp)
    80006272:	6105                	addi	sp,sp,32
    80006274:	8082                	ret
    panic("could not find virtio disk");
    80006276:	00002517          	auipc	a0,0x2
    8000627a:	59a50513          	addi	a0,a0,1434 # 80008810 <syscalls+0x358>
    8000627e:	ffffa097          	auipc	ra,0xffffa
    80006282:	2d2080e7          	jalr	722(ra) # 80000550 <panic>
    panic("virtio disk has no queue 0");
    80006286:	00002517          	auipc	a0,0x2
    8000628a:	5aa50513          	addi	a0,a0,1450 # 80008830 <syscalls+0x378>
    8000628e:	ffffa097          	auipc	ra,0xffffa
    80006292:	2c2080e7          	jalr	706(ra) # 80000550 <panic>
    panic("virtio disk max queue too short");
    80006296:	00002517          	auipc	a0,0x2
    8000629a:	5ba50513          	addi	a0,a0,1466 # 80008850 <syscalls+0x398>
    8000629e:	ffffa097          	auipc	ra,0xffffa
    800062a2:	2b2080e7          	jalr	690(ra) # 80000550 <panic>

00000000800062a6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062a6:	7159                	addi	sp,sp,-112
    800062a8:	f486                	sd	ra,104(sp)
    800062aa:	f0a2                	sd	s0,96(sp)
    800062ac:	eca6                	sd	s1,88(sp)
    800062ae:	e8ca                	sd	s2,80(sp)
    800062b0:	e4ce                	sd	s3,72(sp)
    800062b2:	e0d2                	sd	s4,64(sp)
    800062b4:	fc56                	sd	s5,56(sp)
    800062b6:	f85a                	sd	s6,48(sp)
    800062b8:	f45e                	sd	s7,40(sp)
    800062ba:	f062                	sd	s8,32(sp)
    800062bc:	ec66                	sd	s9,24(sp)
    800062be:	e86a                	sd	s10,16(sp)
    800062c0:	1880                	addi	s0,sp,112
    800062c2:	892a                	mv	s2,a0
    800062c4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062c6:	00c52c83          	lw	s9,12(a0)
    800062ca:	001c9c9b          	slliw	s9,s9,0x1
    800062ce:	1c82                	slli	s9,s9,0x20
    800062d0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800062d4:	00020517          	auipc	a0,0x20
    800062d8:	e5450513          	addi	a0,a0,-428 # 80026128 <disk+0x2128>
    800062dc:	ffffb097          	auipc	ra,0xffffb
    800062e0:	b06080e7          	jalr	-1274(ra) # 80000de2 <acquire>
  for(int i = 0; i < 3; i++){
    800062e4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062e6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800062e8:	0001eb97          	auipc	s7,0x1e
    800062ec:	d18b8b93          	addi	s7,s7,-744 # 80024000 <disk>
    800062f0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800062f2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800062f4:	8a4e                	mv	s4,s3
    800062f6:	a051                	j	8000637a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800062f8:	00fb86b3          	add	a3,s7,a5
    800062fc:	96da                	add	a3,a3,s6
    800062fe:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006302:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006304:	0207c563          	bltz	a5,8000632e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006308:	2485                	addiw	s1,s1,1
    8000630a:	0711                	addi	a4,a4,4
    8000630c:	1b548863          	beq	s1,s5,800064bc <virtio_disk_rw+0x216>
    idx[i] = alloc_desc();
    80006310:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006312:	00020697          	auipc	a3,0x20
    80006316:	d0668693          	addi	a3,a3,-762 # 80026018 <disk+0x2018>
    8000631a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000631c:	0006c583          	lbu	a1,0(a3)
    80006320:	fde1                	bnez	a1,800062f8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006322:	2785                	addiw	a5,a5,1
    80006324:	0685                	addi	a3,a3,1
    80006326:	ff879be3          	bne	a5,s8,8000631c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000632a:	57fd                	li	a5,-1
    8000632c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000632e:	02905a63          	blez	s1,80006362 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006332:	f9042503          	lw	a0,-112(s0)
    80006336:	00000097          	auipc	ra,0x0
    8000633a:	d90080e7          	jalr	-624(ra) # 800060c6 <free_desc>
      for(int j = 0; j < i; j++)
    8000633e:	4785                	li	a5,1
    80006340:	0297d163          	bge	a5,s1,80006362 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006344:	f9442503          	lw	a0,-108(s0)
    80006348:	00000097          	auipc	ra,0x0
    8000634c:	d7e080e7          	jalr	-642(ra) # 800060c6 <free_desc>
      for(int j = 0; j < i; j++)
    80006350:	4789                	li	a5,2
    80006352:	0097d863          	bge	a5,s1,80006362 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006356:	f9842503          	lw	a0,-104(s0)
    8000635a:	00000097          	auipc	ra,0x0
    8000635e:	d6c080e7          	jalr	-660(ra) # 800060c6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006362:	00020597          	auipc	a1,0x20
    80006366:	dc658593          	addi	a1,a1,-570 # 80026128 <disk+0x2128>
    8000636a:	00020517          	auipc	a0,0x20
    8000636e:	cae50513          	addi	a0,a0,-850 # 80026018 <disk+0x2018>
    80006372:	ffffc097          	auipc	ra,0xffffc
    80006376:	2c8080e7          	jalr	712(ra) # 8000263a <sleep>
  for(int i = 0; i < 3; i++){
    8000637a:	f9040713          	addi	a4,s0,-112
    8000637e:	84ce                	mv	s1,s3
    80006380:	bf41                	j	80006310 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006382:	00020697          	auipc	a3,0x20
    80006386:	c7e6b683          	ld	a3,-898(a3) # 80026000 <disk+0x2000>
    8000638a:	96ba                	add	a3,a3,a4
    8000638c:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006390:	0001e817          	auipc	a6,0x1e
    80006394:	c7080813          	addi	a6,a6,-912 # 80024000 <disk>
    80006398:	00020697          	auipc	a3,0x20
    8000639c:	c6868693          	addi	a3,a3,-920 # 80026000 <disk+0x2000>
    800063a0:	6290                	ld	a2,0(a3)
    800063a2:	963a                	add	a2,a2,a4
    800063a4:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800063a8:	0015e593          	ori	a1,a1,1
    800063ac:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800063b0:	f9842603          	lw	a2,-104(s0)
    800063b4:	628c                	ld	a1,0(a3)
    800063b6:	972e                	add	a4,a4,a1
    800063b8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063bc:	20050593          	addi	a1,a0,512
    800063c0:	0592                	slli	a1,a1,0x4
    800063c2:	95c2                	add	a1,a1,a6
    800063c4:	577d                	li	a4,-1
    800063c6:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063ca:	00461713          	slli	a4,a2,0x4
    800063ce:	6290                	ld	a2,0(a3)
    800063d0:	963a                	add	a2,a2,a4
    800063d2:	03078793          	addi	a5,a5,48
    800063d6:	97c2                	add	a5,a5,a6
    800063d8:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800063da:	629c                	ld	a5,0(a3)
    800063dc:	97ba                	add	a5,a5,a4
    800063de:	4605                	li	a2,1
    800063e0:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063e2:	629c                	ld	a5,0(a3)
    800063e4:	97ba                	add	a5,a5,a4
    800063e6:	4809                	li	a6,2
    800063e8:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800063ec:	629c                	ld	a5,0(a3)
    800063ee:	973e                	add	a4,a4,a5
    800063f0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063f4:	00c92223          	sw	a2,4(s2)
  disk.info[idx[0]].b = b;
    800063f8:	0325b423          	sd	s2,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063fc:	6698                	ld	a4,8(a3)
    800063fe:	00275783          	lhu	a5,2(a4)
    80006402:	8b9d                	andi	a5,a5,7
    80006404:	0786                	slli	a5,a5,0x1
    80006406:	97ba                	add	a5,a5,a4
    80006408:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    8000640c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006410:	6698                	ld	a4,8(a3)
    80006412:	00275783          	lhu	a5,2(a4)
    80006416:	2785                	addiw	a5,a5,1
    80006418:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000641c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006420:	100017b7          	lui	a5,0x10001
    80006424:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006428:	00492783          	lw	a5,4(s2)
    8000642c:	02c79163          	bne	a5,a2,8000644e <virtio_disk_rw+0x1a8>
    sleep(b, &disk.vdisk_lock);
    80006430:	00020997          	auipc	s3,0x20
    80006434:	cf898993          	addi	s3,s3,-776 # 80026128 <disk+0x2128>
  while(b->disk == 1) {
    80006438:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000643a:	85ce                	mv	a1,s3
    8000643c:	854a                	mv	a0,s2
    8000643e:	ffffc097          	auipc	ra,0xffffc
    80006442:	1fc080e7          	jalr	508(ra) # 8000263a <sleep>
  while(b->disk == 1) {
    80006446:	00492783          	lw	a5,4(s2)
    8000644a:	fe9788e3          	beq	a5,s1,8000643a <virtio_disk_rw+0x194>
  }

  disk.info[idx[0]].b = 0;
    8000644e:	f9042903          	lw	s2,-112(s0)
    80006452:	20090793          	addi	a5,s2,512
    80006456:	00479713          	slli	a4,a5,0x4
    8000645a:	0001e797          	auipc	a5,0x1e
    8000645e:	ba678793          	addi	a5,a5,-1114 # 80024000 <disk>
    80006462:	97ba                	add	a5,a5,a4
    80006464:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006468:	00020997          	auipc	s3,0x20
    8000646c:	b9898993          	addi	s3,s3,-1128 # 80026000 <disk+0x2000>
    80006470:	00491713          	slli	a4,s2,0x4
    80006474:	0009b783          	ld	a5,0(s3)
    80006478:	97ba                	add	a5,a5,a4
    8000647a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000647e:	854a                	mv	a0,s2
    80006480:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006484:	00000097          	auipc	ra,0x0
    80006488:	c42080e7          	jalr	-958(ra) # 800060c6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000648c:	8885                	andi	s1,s1,1
    8000648e:	f0ed                	bnez	s1,80006470 <virtio_disk_rw+0x1ca>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006490:	00020517          	auipc	a0,0x20
    80006494:	c9850513          	addi	a0,a0,-872 # 80026128 <disk+0x2128>
    80006498:	ffffb097          	auipc	ra,0xffffb
    8000649c:	a1a080e7          	jalr	-1510(ra) # 80000eb2 <release>
}
    800064a0:	70a6                	ld	ra,104(sp)
    800064a2:	7406                	ld	s0,96(sp)
    800064a4:	64e6                	ld	s1,88(sp)
    800064a6:	6946                	ld	s2,80(sp)
    800064a8:	69a6                	ld	s3,72(sp)
    800064aa:	6a06                	ld	s4,64(sp)
    800064ac:	7ae2                	ld	s5,56(sp)
    800064ae:	7b42                	ld	s6,48(sp)
    800064b0:	7ba2                	ld	s7,40(sp)
    800064b2:	7c02                	ld	s8,32(sp)
    800064b4:	6ce2                	ld	s9,24(sp)
    800064b6:	6d42                	ld	s10,16(sp)
    800064b8:	6165                	addi	sp,sp,112
    800064ba:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064bc:	f9042503          	lw	a0,-112(s0)
    800064c0:	20050793          	addi	a5,a0,512
    800064c4:	0792                	slli	a5,a5,0x4
  if(write)
    800064c6:	0001e817          	auipc	a6,0x1e
    800064ca:	b3a80813          	addi	a6,a6,-1222 # 80024000 <disk>
    800064ce:	00f80733          	add	a4,a6,a5
    800064d2:	01a036b3          	snez	a3,s10
    800064d6:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800064da:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800064de:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064e2:	7679                	lui	a2,0xffffe
    800064e4:	963e                	add	a2,a2,a5
    800064e6:	00020697          	auipc	a3,0x20
    800064ea:	b1a68693          	addi	a3,a3,-1254 # 80026000 <disk+0x2000>
    800064ee:	6298                	ld	a4,0(a3)
    800064f0:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064f2:	0a878593          	addi	a1,a5,168
    800064f6:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064f8:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064fa:	6298                	ld	a4,0(a3)
    800064fc:	9732                	add	a4,a4,a2
    800064fe:	45c1                	li	a1,16
    80006500:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006502:	6298                	ld	a4,0(a3)
    80006504:	9732                	add	a4,a4,a2
    80006506:	4585                	li	a1,1
    80006508:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    8000650c:	f9442703          	lw	a4,-108(s0)
    80006510:	628c                	ld	a1,0(a3)
    80006512:	962e                	add	a2,a2,a1
    80006514:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd5fe6>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006518:	0712                	slli	a4,a4,0x4
    8000651a:	6290                	ld	a2,0(a3)
    8000651c:	963a                	add	a2,a2,a4
    8000651e:	06090593          	addi	a1,s2,96
    80006522:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006524:	6294                	ld	a3,0(a3)
    80006526:	96ba                	add	a3,a3,a4
    80006528:	40000613          	li	a2,1024
    8000652c:	c690                	sw	a2,8(a3)
  if(write)
    8000652e:	e40d1ae3          	bnez	s10,80006382 <virtio_disk_rw+0xdc>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006532:	00020697          	auipc	a3,0x20
    80006536:	ace6b683          	ld	a3,-1330(a3) # 80026000 <disk+0x2000>
    8000653a:	96ba                	add	a3,a3,a4
    8000653c:	4609                	li	a2,2
    8000653e:	00c69623          	sh	a2,12(a3)
    80006542:	b5b9                	j	80006390 <virtio_disk_rw+0xea>

0000000080006544 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006544:	1101                	addi	sp,sp,-32
    80006546:	ec06                	sd	ra,24(sp)
    80006548:	e822                	sd	s0,16(sp)
    8000654a:	e426                	sd	s1,8(sp)
    8000654c:	e04a                	sd	s2,0(sp)
    8000654e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006550:	00020517          	auipc	a0,0x20
    80006554:	bd850513          	addi	a0,a0,-1064 # 80026128 <disk+0x2128>
    80006558:	ffffb097          	auipc	ra,0xffffb
    8000655c:	88a080e7          	jalr	-1910(ra) # 80000de2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006560:	10001737          	lui	a4,0x10001
    80006564:	533c                	lw	a5,96(a4)
    80006566:	8b8d                	andi	a5,a5,3
    80006568:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000656a:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000656e:	00020797          	auipc	a5,0x20
    80006572:	a9278793          	addi	a5,a5,-1390 # 80026000 <disk+0x2000>
    80006576:	6b94                	ld	a3,16(a5)
    80006578:	0207d703          	lhu	a4,32(a5)
    8000657c:	0026d783          	lhu	a5,2(a3)
    80006580:	06f70163          	beq	a4,a5,800065e2 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006584:	0001e917          	auipc	s2,0x1e
    80006588:	a7c90913          	addi	s2,s2,-1412 # 80024000 <disk>
    8000658c:	00020497          	auipc	s1,0x20
    80006590:	a7448493          	addi	s1,s1,-1420 # 80026000 <disk+0x2000>
    __sync_synchronize();
    80006594:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006598:	6898                	ld	a4,16(s1)
    8000659a:	0204d783          	lhu	a5,32(s1)
    8000659e:	8b9d                	andi	a5,a5,7
    800065a0:	078e                	slli	a5,a5,0x3
    800065a2:	97ba                	add	a5,a5,a4
    800065a4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065a6:	20078713          	addi	a4,a5,512
    800065aa:	0712                	slli	a4,a4,0x4
    800065ac:	974a                	add	a4,a4,s2
    800065ae:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800065b2:	e731                	bnez	a4,800065fe <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065b4:	20078793          	addi	a5,a5,512
    800065b8:	0792                	slli	a5,a5,0x4
    800065ba:	97ca                	add	a5,a5,s2
    800065bc:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800065be:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065c2:	ffffc097          	auipc	ra,0xffffc
    800065c6:	1fe080e7          	jalr	510(ra) # 800027c0 <wakeup>

    disk.used_idx += 1;
    800065ca:	0204d783          	lhu	a5,32(s1)
    800065ce:	2785                	addiw	a5,a5,1
    800065d0:	17c2                	slli	a5,a5,0x30
    800065d2:	93c1                	srli	a5,a5,0x30
    800065d4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065d8:	6898                	ld	a4,16(s1)
    800065da:	00275703          	lhu	a4,2(a4)
    800065de:	faf71be3          	bne	a4,a5,80006594 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800065e2:	00020517          	auipc	a0,0x20
    800065e6:	b4650513          	addi	a0,a0,-1210 # 80026128 <disk+0x2128>
    800065ea:	ffffb097          	auipc	ra,0xffffb
    800065ee:	8c8080e7          	jalr	-1848(ra) # 80000eb2 <release>
}
    800065f2:	60e2                	ld	ra,24(sp)
    800065f4:	6442                	ld	s0,16(sp)
    800065f6:	64a2                	ld	s1,8(sp)
    800065f8:	6902                	ld	s2,0(sp)
    800065fa:	6105                	addi	sp,sp,32
    800065fc:	8082                	ret
      panic("virtio_disk_intr status");
    800065fe:	00002517          	auipc	a0,0x2
    80006602:	27250513          	addi	a0,a0,626 # 80008870 <syscalls+0x3b8>
    80006606:	ffffa097          	auipc	ra,0xffffa
    8000660a:	f4a080e7          	jalr	-182(ra) # 80000550 <panic>

000000008000660e <statswrite>:
int statscopyin(char*, int);
int statslock(char*, int);
  
int
statswrite(int user_src, uint64 src, int n)
{
    8000660e:	1141                	addi	sp,sp,-16
    80006610:	e422                	sd	s0,8(sp)
    80006612:	0800                	addi	s0,sp,16
  return -1;
}
    80006614:	557d                	li	a0,-1
    80006616:	6422                	ld	s0,8(sp)
    80006618:	0141                	addi	sp,sp,16
    8000661a:	8082                	ret

000000008000661c <statsread>:

int
statsread(int user_dst, uint64 dst, int n)
{
    8000661c:	7179                	addi	sp,sp,-48
    8000661e:	f406                	sd	ra,40(sp)
    80006620:	f022                	sd	s0,32(sp)
    80006622:	ec26                	sd	s1,24(sp)
    80006624:	e84a                	sd	s2,16(sp)
    80006626:	e44e                	sd	s3,8(sp)
    80006628:	e052                	sd	s4,0(sp)
    8000662a:	1800                	addi	s0,sp,48
    8000662c:	892a                	mv	s2,a0
    8000662e:	89ae                	mv	s3,a1
    80006630:	84b2                	mv	s1,a2
  int m;

  acquire(&stats.lock);
    80006632:	00021517          	auipc	a0,0x21
    80006636:	9ce50513          	addi	a0,a0,-1586 # 80027000 <stats>
    8000663a:	ffffa097          	auipc	ra,0xffffa
    8000663e:	7a8080e7          	jalr	1960(ra) # 80000de2 <acquire>

  if(stats.sz == 0) {
    80006642:	00022797          	auipc	a5,0x22
    80006646:	9de7a783          	lw	a5,-1570(a5) # 80028020 <stats+0x1020>
    8000664a:	cbb5                	beqz	a5,800066be <statsread+0xa2>
#endif
#ifdef LAB_LOCK
    stats.sz = statslock(stats.buf, BUFSZ);
#endif
  }
  m = stats.sz - stats.off;
    8000664c:	00022797          	auipc	a5,0x22
    80006650:	9b478793          	addi	a5,a5,-1612 # 80028000 <stats+0x1000>
    80006654:	53d8                	lw	a4,36(a5)
    80006656:	539c                	lw	a5,32(a5)
    80006658:	9f99                	subw	a5,a5,a4
    8000665a:	0007869b          	sext.w	a3,a5

  if (m > 0) {
    8000665e:	06d05e63          	blez	a3,800066da <statsread+0xbe>
    if(m > n)
    80006662:	8a3e                	mv	s4,a5
    80006664:	00d4d363          	bge	s1,a3,8000666a <statsread+0x4e>
    80006668:	8a26                	mv	s4,s1
    8000666a:	000a049b          	sext.w	s1,s4
      m  = n;
    if(either_copyout(user_dst, dst, stats.buf+stats.off, m) != -1) {
    8000666e:	86a6                	mv	a3,s1
    80006670:	00021617          	auipc	a2,0x21
    80006674:	9b060613          	addi	a2,a2,-1616 # 80027020 <stats+0x20>
    80006678:	963a                	add	a2,a2,a4
    8000667a:	85ce                	mv	a1,s3
    8000667c:	854a                	mv	a0,s2
    8000667e:	ffffc097          	auipc	ra,0xffffc
    80006682:	21c080e7          	jalr	540(ra) # 8000289a <either_copyout>
    80006686:	57fd                	li	a5,-1
    80006688:	00f50a63          	beq	a0,a5,8000669c <statsread+0x80>
      stats.off += m;
    8000668c:	00022717          	auipc	a4,0x22
    80006690:	97470713          	addi	a4,a4,-1676 # 80028000 <stats+0x1000>
    80006694:	535c                	lw	a5,36(a4)
    80006696:	014787bb          	addw	a5,a5,s4
    8000669a:	d35c                	sw	a5,36(a4)
  } else {
    m = -1;
    stats.sz = 0;
    stats.off = 0;
  }
  release(&stats.lock);
    8000669c:	00021517          	auipc	a0,0x21
    800066a0:	96450513          	addi	a0,a0,-1692 # 80027000 <stats>
    800066a4:	ffffb097          	auipc	ra,0xffffb
    800066a8:	80e080e7          	jalr	-2034(ra) # 80000eb2 <release>
  return m;
}
    800066ac:	8526                	mv	a0,s1
    800066ae:	70a2                	ld	ra,40(sp)
    800066b0:	7402                	ld	s0,32(sp)
    800066b2:	64e2                	ld	s1,24(sp)
    800066b4:	6942                	ld	s2,16(sp)
    800066b6:	69a2                	ld	s3,8(sp)
    800066b8:	6a02                	ld	s4,0(sp)
    800066ba:	6145                	addi	sp,sp,48
    800066bc:	8082                	ret
    stats.sz = statslock(stats.buf, BUFSZ);
    800066be:	6585                	lui	a1,0x1
    800066c0:	00021517          	auipc	a0,0x21
    800066c4:	96050513          	addi	a0,a0,-1696 # 80027020 <stats+0x20>
    800066c8:	ffffb097          	auipc	ra,0xffffb
    800066cc:	944080e7          	jalr	-1724(ra) # 8000100c <statslock>
    800066d0:	00022797          	auipc	a5,0x22
    800066d4:	94a7a823          	sw	a0,-1712(a5) # 80028020 <stats+0x1020>
    800066d8:	bf95                	j	8000664c <statsread+0x30>
    stats.sz = 0;
    800066da:	00022797          	auipc	a5,0x22
    800066de:	92678793          	addi	a5,a5,-1754 # 80028000 <stats+0x1000>
    800066e2:	0207a023          	sw	zero,32(a5)
    stats.off = 0;
    800066e6:	0207a223          	sw	zero,36(a5)
    m = -1;
    800066ea:	54fd                	li	s1,-1
    800066ec:	bf45                	j	8000669c <statsread+0x80>

00000000800066ee <statsinit>:

void
statsinit(void)
{
    800066ee:	1141                	addi	sp,sp,-16
    800066f0:	e406                	sd	ra,8(sp)
    800066f2:	e022                	sd	s0,0(sp)
    800066f4:	0800                	addi	s0,sp,16
  initlock(&stats.lock, "stats");
    800066f6:	00002597          	auipc	a1,0x2
    800066fa:	19258593          	addi	a1,a1,402 # 80008888 <syscalls+0x3d0>
    800066fe:	00021517          	auipc	a0,0x21
    80006702:	90250513          	addi	a0,a0,-1790 # 80027000 <stats>
    80006706:	ffffb097          	auipc	ra,0xffffb
    8000670a:	858080e7          	jalr	-1960(ra) # 80000f5e <initlock>

  devsw[STATS].read = statsread;
    8000670e:	0001c797          	auipc	a5,0x1c
    80006712:	18a78793          	addi	a5,a5,394 # 80022898 <devsw>
    80006716:	00000717          	auipc	a4,0x0
    8000671a:	f0670713          	addi	a4,a4,-250 # 8000661c <statsread>
    8000671e:	f398                	sd	a4,32(a5)
  devsw[STATS].write = statswrite;
    80006720:	00000717          	auipc	a4,0x0
    80006724:	eee70713          	addi	a4,a4,-274 # 8000660e <statswrite>
    80006728:	f798                	sd	a4,40(a5)
}
    8000672a:	60a2                	ld	ra,8(sp)
    8000672c:	6402                	ld	s0,0(sp)
    8000672e:	0141                	addi	sp,sp,16
    80006730:	8082                	ret

0000000080006732 <sprintint>:
  return 1;
}

static int
sprintint(char *s, int xx, int base, int sign)
{
    80006732:	1101                	addi	sp,sp,-32
    80006734:	ec22                	sd	s0,24(sp)
    80006736:	1000                	addi	s0,sp,32
    80006738:	882a                	mv	a6,a0
  char buf[16];
  int i, n;
  uint x;

  if(sign && (sign = xx < 0))
    8000673a:	c299                	beqz	a3,80006740 <sprintint+0xe>
    8000673c:	0805c163          	bltz	a1,800067be <sprintint+0x8c>
    x = -xx;
  else
    x = xx;
    80006740:	2581                	sext.w	a1,a1
    80006742:	4301                	li	t1,0

  i = 0;
    80006744:	fe040713          	addi	a4,s0,-32
    80006748:	4501                	li	a0,0
  do {
    buf[i++] = digits[x % base];
    8000674a:	2601                	sext.w	a2,a2
    8000674c:	00002697          	auipc	a3,0x2
    80006750:	14468693          	addi	a3,a3,324 # 80008890 <digits>
    80006754:	88aa                	mv	a7,a0
    80006756:	2505                	addiw	a0,a0,1
    80006758:	02c5f7bb          	remuw	a5,a1,a2
    8000675c:	1782                	slli	a5,a5,0x20
    8000675e:	9381                	srli	a5,a5,0x20
    80006760:	97b6                	add	a5,a5,a3
    80006762:	0007c783          	lbu	a5,0(a5)
    80006766:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    8000676a:	0005879b          	sext.w	a5,a1
    8000676e:	02c5d5bb          	divuw	a1,a1,a2
    80006772:	0705                	addi	a4,a4,1
    80006774:	fec7f0e3          	bgeu	a5,a2,80006754 <sprintint+0x22>

  if(sign)
    80006778:	00030b63          	beqz	t1,8000678e <sprintint+0x5c>
    buf[i++] = '-';
    8000677c:	ff040793          	addi	a5,s0,-16
    80006780:	97aa                	add	a5,a5,a0
    80006782:	02d00713          	li	a4,45
    80006786:	fee78823          	sb	a4,-16(a5)
    8000678a:	0028851b          	addiw	a0,a7,2

  n = 0;
  while(--i >= 0)
    8000678e:	02a05c63          	blez	a0,800067c6 <sprintint+0x94>
    80006792:	fe040793          	addi	a5,s0,-32
    80006796:	00a78733          	add	a4,a5,a0
    8000679a:	87c2                	mv	a5,a6
    8000679c:	0805                	addi	a6,a6,1
    8000679e:	fff5061b          	addiw	a2,a0,-1
    800067a2:	1602                	slli	a2,a2,0x20
    800067a4:	9201                	srli	a2,a2,0x20
    800067a6:	9642                	add	a2,a2,a6
  *s = c;
    800067a8:	fff74683          	lbu	a3,-1(a4)
    800067ac:	00d78023          	sb	a3,0(a5)
  while(--i >= 0)
    800067b0:	177d                	addi	a4,a4,-1
    800067b2:	0785                	addi	a5,a5,1
    800067b4:	fec79ae3          	bne	a5,a2,800067a8 <sprintint+0x76>
    n += sputc(s+n, buf[i]);
  return n;
}
    800067b8:	6462                	ld	s0,24(sp)
    800067ba:	6105                	addi	sp,sp,32
    800067bc:	8082                	ret
    x = -xx;
    800067be:	40b005bb          	negw	a1,a1
  if(sign && (sign = xx < 0))
    800067c2:	4305                	li	t1,1
    x = -xx;
    800067c4:	b741                	j	80006744 <sprintint+0x12>
  while(--i >= 0)
    800067c6:	4501                	li	a0,0
    800067c8:	bfc5                	j	800067b8 <sprintint+0x86>

00000000800067ca <snprintf>:

int
snprintf(char *buf, int sz, char *fmt, ...)
{
    800067ca:	7135                	addi	sp,sp,-160
    800067cc:	f486                	sd	ra,104(sp)
    800067ce:	f0a2                	sd	s0,96(sp)
    800067d0:	eca6                	sd	s1,88(sp)
    800067d2:	e8ca                	sd	s2,80(sp)
    800067d4:	e4ce                	sd	s3,72(sp)
    800067d6:	e0d2                	sd	s4,64(sp)
    800067d8:	fc56                	sd	s5,56(sp)
    800067da:	f85a                	sd	s6,48(sp)
    800067dc:	f45e                	sd	s7,40(sp)
    800067de:	f062                	sd	s8,32(sp)
    800067e0:	ec66                	sd	s9,24(sp)
    800067e2:	e86a                	sd	s10,16(sp)
    800067e4:	1880                	addi	s0,sp,112
    800067e6:	e414                	sd	a3,8(s0)
    800067e8:	e818                	sd	a4,16(s0)
    800067ea:	ec1c                	sd	a5,24(s0)
    800067ec:	03043023          	sd	a6,32(s0)
    800067f0:	03143423          	sd	a7,40(s0)
  va_list ap;
  int i, c;
  int off = 0;
  char *s;

  if (fmt == 0)
    800067f4:	c61d                	beqz	a2,80006822 <snprintf+0x58>
    800067f6:	8baa                	mv	s7,a0
    800067f8:	89ae                	mv	s3,a1
    800067fa:	8a32                	mv	s4,a2
    panic("null fmt");

  va_start(ap, fmt);
    800067fc:	00840793          	addi	a5,s0,8
    80006800:	f8f43c23          	sd	a5,-104(s0)
  int off = 0;
    80006804:	4481                	li	s1,0
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006806:	4901                	li	s2,0
    80006808:	02b05563          	blez	a1,80006832 <snprintf+0x68>
    if(c != '%'){
    8000680c:	02500a93          	li	s5,37
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    80006810:	07300b13          	li	s6,115
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
      break;
    case 's':
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s && off < sz; s++)
    80006814:	02800d13          	li	s10,40
    switch(c){
    80006818:	07800c93          	li	s9,120
    8000681c:	06400c13          	li	s8,100
    80006820:	a01d                	j	80006846 <snprintf+0x7c>
    panic("null fmt");
    80006822:	00002517          	auipc	a0,0x2
    80006826:	80650513          	addi	a0,a0,-2042 # 80008028 <etext+0x28>
    8000682a:	ffffa097          	auipc	ra,0xffffa
    8000682e:	d26080e7          	jalr	-730(ra) # 80000550 <panic>
  int off = 0;
    80006832:	4481                	li	s1,0
    80006834:	a86d                	j	800068ee <snprintf+0x124>
  *s = c;
    80006836:	009b8733          	add	a4,s7,s1
    8000683a:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    8000683e:	2485                	addiw	s1,s1,1
  for(i = 0; off < sz && (c = fmt[i] & 0xff) != 0; i++){
    80006840:	2905                	addiw	s2,s2,1
    80006842:	0b34d663          	bge	s1,s3,800068ee <snprintf+0x124>
    80006846:	012a07b3          	add	a5,s4,s2
    8000684a:	0007c783          	lbu	a5,0(a5)
    8000684e:	0007871b          	sext.w	a4,a5
    80006852:	cfd1                	beqz	a5,800068ee <snprintf+0x124>
    if(c != '%'){
    80006854:	ff5711e3          	bne	a4,s5,80006836 <snprintf+0x6c>
    c = fmt[++i] & 0xff;
    80006858:	2905                	addiw	s2,s2,1
    8000685a:	012a07b3          	add	a5,s4,s2
    8000685e:	0007c783          	lbu	a5,0(a5)
    if(c == 0)
    80006862:	c7d1                	beqz	a5,800068ee <snprintf+0x124>
    switch(c){
    80006864:	05678c63          	beq	a5,s6,800068bc <snprintf+0xf2>
    80006868:	02fb6763          	bltu	s6,a5,80006896 <snprintf+0xcc>
    8000686c:	0b578663          	beq	a5,s5,80006918 <snprintf+0x14e>
    80006870:	0b879a63          	bne	a5,s8,80006924 <snprintf+0x15a>
      off += sprintint(buf+off, va_arg(ap, int), 10, 1);
    80006874:	f9843783          	ld	a5,-104(s0)
    80006878:	00878713          	addi	a4,a5,8
    8000687c:	f8e43c23          	sd	a4,-104(s0)
    80006880:	4685                	li	a3,1
    80006882:	4629                	li	a2,10
    80006884:	438c                	lw	a1,0(a5)
    80006886:	009b8533          	add	a0,s7,s1
    8000688a:	00000097          	auipc	ra,0x0
    8000688e:	ea8080e7          	jalr	-344(ra) # 80006732 <sprintint>
    80006892:	9ca9                	addw	s1,s1,a0
      break;
    80006894:	b775                	j	80006840 <snprintf+0x76>
    switch(c){
    80006896:	09979763          	bne	a5,s9,80006924 <snprintf+0x15a>
      off += sprintint(buf+off, va_arg(ap, int), 16, 1);
    8000689a:	f9843783          	ld	a5,-104(s0)
    8000689e:	00878713          	addi	a4,a5,8
    800068a2:	f8e43c23          	sd	a4,-104(s0)
    800068a6:	4685                	li	a3,1
    800068a8:	4641                	li	a2,16
    800068aa:	438c                	lw	a1,0(a5)
    800068ac:	009b8533          	add	a0,s7,s1
    800068b0:	00000097          	auipc	ra,0x0
    800068b4:	e82080e7          	jalr	-382(ra) # 80006732 <sprintint>
    800068b8:	9ca9                	addw	s1,s1,a0
      break;
    800068ba:	b759                	j	80006840 <snprintf+0x76>
      if((s = va_arg(ap, char*)) == 0)
    800068bc:	f9843783          	ld	a5,-104(s0)
    800068c0:	00878713          	addi	a4,a5,8
    800068c4:	f8e43c23          	sd	a4,-104(s0)
    800068c8:	639c                	ld	a5,0(a5)
    800068ca:	c3a9                	beqz	a5,8000690c <snprintf+0x142>
      for(; *s && off < sz; s++)
    800068cc:	0007c703          	lbu	a4,0(a5)
    800068d0:	db25                	beqz	a4,80006840 <snprintf+0x76>
    800068d2:	0134de63          	bge	s1,s3,800068ee <snprintf+0x124>
    800068d6:	009b86b3          	add	a3,s7,s1
  *s = c;
    800068da:	00e68023          	sb	a4,0(a3)
        off += sputc(buf+off, *s);
    800068de:	2485                	addiw	s1,s1,1
      for(; *s && off < sz; s++)
    800068e0:	0785                	addi	a5,a5,1
    800068e2:	0007c703          	lbu	a4,0(a5)
    800068e6:	df29                	beqz	a4,80006840 <snprintf+0x76>
    800068e8:	0685                	addi	a3,a3,1
    800068ea:	fe9998e3          	bne	s3,s1,800068da <snprintf+0x110>
      off += sputc(buf+off, c);
      break;
    }
  }
  return off;
}
    800068ee:	8526                	mv	a0,s1
    800068f0:	70a6                	ld	ra,104(sp)
    800068f2:	7406                	ld	s0,96(sp)
    800068f4:	64e6                	ld	s1,88(sp)
    800068f6:	6946                	ld	s2,80(sp)
    800068f8:	69a6                	ld	s3,72(sp)
    800068fa:	6a06                	ld	s4,64(sp)
    800068fc:	7ae2                	ld	s5,56(sp)
    800068fe:	7b42                	ld	s6,48(sp)
    80006900:	7ba2                	ld	s7,40(sp)
    80006902:	7c02                	ld	s8,32(sp)
    80006904:	6ce2                	ld	s9,24(sp)
    80006906:	6d42                	ld	s10,16(sp)
    80006908:	610d                	addi	sp,sp,160
    8000690a:	8082                	ret
        s = "(null)";
    8000690c:	00001797          	auipc	a5,0x1
    80006910:	71478793          	addi	a5,a5,1812 # 80008020 <etext+0x20>
      for(; *s && off < sz; s++)
    80006914:	876a                	mv	a4,s10
    80006916:	bf75                	j	800068d2 <snprintf+0x108>
  *s = c;
    80006918:	009b87b3          	add	a5,s7,s1
    8000691c:	01578023          	sb	s5,0(a5)
      off += sputc(buf+off, '%');
    80006920:	2485                	addiw	s1,s1,1
      break;
    80006922:	bf39                	j	80006840 <snprintf+0x76>
  *s = c;
    80006924:	009b8733          	add	a4,s7,s1
    80006928:	01570023          	sb	s5,0(a4)
      off += sputc(buf+off, c);
    8000692c:	0014871b          	addiw	a4,s1,1
  *s = c;
    80006930:	975e                	add	a4,a4,s7
    80006932:	00f70023          	sb	a5,0(a4)
      off += sputc(buf+off, c);
    80006936:	2489                	addiw	s1,s1,2
      break;
    80006938:	b721                	j	80006840 <snprintf+0x76>
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
