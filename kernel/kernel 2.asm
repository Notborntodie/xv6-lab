
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
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
    80000022:	f14027f3          	csrr	a5,mhartid
    80000026:	0007859b          	sext.w	a1,a5
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	fe070713          	addi	a4,a4,-32 # 80009030 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
    8000005a:	ef1c                	sd	a5,24(a4)
    8000005c:	f310                	sd	a2,32(a4)
    8000005e:	34071073          	csrw	mscratch,a4
    80000062:	00006797          	auipc	a5,0x6
    80000066:	b4e78793          	addi	a5,a5,-1202 # 80005bb0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
    8000006e:	300027f3          	csrr	a5,mstatus
    80000072:	0087e793          	ori	a5,a5,8
    80000076:	30079073          	csrw	mstatus,a5
    8000007a:	304027f3          	csrr	a5,mie
    8000007e:	0807e793          	ori	a5,a5,128
    80000082:	30479073          	csrw	mie,a5
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
    80000094:	300027f3          	csrr	a5,mstatus
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009e:	8ff9                	and	a5,a5,a4
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    800000a8:	30079073          	csrw	mstatus,a5
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	ee278793          	addi	a5,a5,-286 # 80000f8e <main>
    800000b4:	34179073          	csrw	mepc,a5
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
    800000c6:	30379073          	csrw	mideleg,a5
    800000ca:	104027f3          	csrr	a5,sie
    800000ce:	2227e793          	ori	a5,a5,546
    800000d2:	10479073          	csrw	sie,a5
    800000d6:	00000097          	auipc	ra,0x0
    800000da:	f46080e7          	jalr	-186(ra) # 8000001c <timerinit>
    800000de:	f14027f3          	csrr	a5,mhartid
    800000e2:	2781                	sext.w	a5,a5
    800000e4:	823e                	mv	tp,a5
    800000e6:	30200073          	mret
    800000ea:	60a2                	ld	ra,8(sp)
    800000ec:	6402                	ld	s0,0(sp)
    800000ee:	0141                	addi	sp,sp,16
    800000f0:	8082                	ret

00000000800000f2 <consolewrite>:
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
    8000010a:	00011517          	auipc	a0,0x11
    8000010e:	06650513          	addi	a0,a0,102 # 80011170 <cons>
    80000112:	00001097          	auipc	ra,0x1
    80000116:	bd4080e7          	jalr	-1068(ra) # 80000ce6 <acquire>
    8000011a:	05305c63          	blez	s3,80000172 <consolewrite+0x80>
    8000011e:	4901                	li	s2,0
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	3d8080e7          	jalr	984(ra) # 80002504 <either_copyin>
    80000134:	01550d63          	beq	a0,s5,8000014e <consolewrite+0x5c>
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	796080e7          	jalr	1942(ra) # 800008d2 <uartputc>
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x30>
    8000014c:	894e                	mv	s2,s3
    8000014e:	00011517          	auipc	a0,0x11
    80000152:	02250513          	addi	a0,a0,34 # 80011170 <cons>
    80000156:	00001097          	auipc	ra,0x1
    8000015a:	c44080e7          	jalr	-956(ra) # 80000d9a <release>
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
    80000172:	4901                	li	s2,0
    80000174:	bfe9                	j	8000014e <consolewrite+0x5c>

0000000080000176 <consoleread>:
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
    80000192:	00060b1b          	sext.w	s6,a2
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	fda50513          	addi	a0,a0,-38 # 80011170 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	b48080e7          	jalr	-1208(ra) # 80000ce6 <acquire>
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	fca48493          	addi	s1,s1,-54 # 80011170 <cons>
    800001ae:	00011917          	auipc	s2,0x11
    800001b2:	05a90913          	addi	s2,s2,90 # 80011208 <cons+0x98>
    800001b6:	07305f63          	blez	s3,80000234 <consoleread+0xbe>
    800001ba:	0984a783          	lw	a5,152(s1)
    800001be:	09c4a703          	lw	a4,156(s1)
    800001c2:	02f71463          	bne	a4,a5,800001ea <consoleread+0x74>
    800001c6:	00002097          	auipc	ra,0x2
    800001ca:	878080e7          	jalr	-1928(ra) # 80001a3e <myproc>
    800001ce:	591c                	lw	a5,48(a0)
    800001d0:	efad                	bnez	a5,8000024a <consoleread+0xd4>
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	07e080e7          	jalr	126(ra) # 80002254 <sleep>
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fef700e3          	beq	a4,a5,800001c6 <consoleread+0x50>
    800001ea:	00011717          	auipc	a4,0x11
    800001ee:	f8670713          	addi	a4,a4,-122 # 80011170 <cons>
    800001f2:	0017869b          	addiw	a3,a5,1
    800001f6:	08d72c23          	sw	a3,152(a4)
    800001fa:	07f7f693          	andi	a3,a5,127
    800001fe:	9736                	add	a4,a4,a3
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070b9b          	sext.w	s7,a4
    80000208:	4691                	li	a3,4
    8000020a:	06db8463          	beq	s7,a3,80000272 <consoleread+0xfc>
    8000020e:	fae407a3          	sb	a4,-81(s0)
    80000212:	4685                	li	a3,1
    80000214:	faf40613          	addi	a2,s0,-81
    80000218:	85d2                	mv	a1,s4
    8000021a:	8556                	mv	a0,s5
    8000021c:	00002097          	auipc	ra,0x2
    80000220:	292080e7          	jalr	658(ra) # 800024ae <either_copyout>
    80000224:	57fd                	li	a5,-1
    80000226:	00f50763          	beq	a0,a5,80000234 <consoleread+0xbe>
    8000022a:	0a05                	addi	s4,s4,1
    8000022c:	39fd                	addiw	s3,s3,-1
    8000022e:	47a9                	li	a5,10
    80000230:	f8fb93e3          	bne	s7,a5,800001b6 <consoleread+0x40>
    80000234:	00011517          	auipc	a0,0x11
    80000238:	f3c50513          	addi	a0,a0,-196 # 80011170 <cons>
    8000023c:	00001097          	auipc	ra,0x1
    80000240:	b5e080e7          	jalr	-1186(ra) # 80000d9a <release>
    80000244:	413b053b          	subw	a0,s6,s3
    80000248:	a811                	j	8000025c <consoleread+0xe6>
    8000024a:	00011517          	auipc	a0,0x11
    8000024e:	f2650513          	addi	a0,a0,-218 # 80011170 <cons>
    80000252:	00001097          	auipc	ra,0x1
    80000256:	b48080e7          	jalr	-1208(ra) # 80000d9a <release>
    8000025a:	557d                	li	a0,-1
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
    80000272:	0009871b          	sext.w	a4,s3
    80000276:	fb677fe3          	bgeu	a4,s6,80000234 <consoleread+0xbe>
    8000027a:	00011717          	auipc	a4,0x11
    8000027e:	f8f72723          	sw	a5,-114(a4) # 80011208 <cons+0x98>
    80000282:	bf4d                	j	80000234 <consoleread+0xbe>

0000000080000284 <consputc>:
    80000284:	1141                	addi	sp,sp,-16
    80000286:	e406                	sd	ra,8(sp)
    80000288:	e022                	sd	s0,0(sp)
    8000028a:	0800                	addi	s0,sp,16
    8000028c:	10000793          	li	a5,256
    80000290:	00f50a63          	beq	a0,a5,800002a4 <consputc+0x20>
    80000294:	00000097          	auipc	ra,0x0
    80000298:	560080e7          	jalr	1376(ra) # 800007f4 <uartputc_sync>
    8000029c:	60a2                	ld	ra,8(sp)
    8000029e:	6402                	ld	s0,0(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret
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
    800002c6:	1101                	addi	sp,sp,-32
    800002c8:	ec06                	sd	ra,24(sp)
    800002ca:	e822                	sd	s0,16(sp)
    800002cc:	e426                	sd	s1,8(sp)
    800002ce:	e04a                	sd	s2,0(sp)
    800002d0:	1000                	addi	s0,sp,32
    800002d2:	84aa                	mv	s1,a0
    800002d4:	00011517          	auipc	a0,0x11
    800002d8:	e9c50513          	addi	a0,a0,-356 # 80011170 <cons>
    800002dc:	00001097          	auipc	ra,0x1
    800002e0:	a0a080e7          	jalr	-1526(ra) # 80000ce6 <acquire>
    800002e4:	47d5                	li	a5,21
    800002e6:	0af48663          	beq	s1,a5,80000392 <consoleintr+0xcc>
    800002ea:	0297ca63          	blt	a5,s1,8000031e <consoleintr+0x58>
    800002ee:	47a1                	li	a5,8
    800002f0:	0ef48763          	beq	s1,a5,800003de <consoleintr+0x118>
    800002f4:	47c1                	li	a5,16
    800002f6:	10f49a63          	bne	s1,a5,8000040a <consoleintr+0x144>
    800002fa:	00002097          	auipc	ra,0x2
    800002fe:	260080e7          	jalr	608(ra) # 8000255a <procdump>
    80000302:	00011517          	auipc	a0,0x11
    80000306:	e6e50513          	addi	a0,a0,-402 # 80011170 <cons>
    8000030a:	00001097          	auipc	ra,0x1
    8000030e:	a90080e7          	jalr	-1392(ra) # 80000d9a <release>
    80000312:	60e2                	ld	ra,24(sp)
    80000314:	6442                	ld	s0,16(sp)
    80000316:	64a2                	ld	s1,8(sp)
    80000318:	6902                	ld	s2,0(sp)
    8000031a:	6105                	addi	sp,sp,32
    8000031c:	8082                	ret
    8000031e:	07f00793          	li	a5,127
    80000322:	0af48e63          	beq	s1,a5,800003de <consoleintr+0x118>
    80000326:	00011717          	auipc	a4,0x11
    8000032a:	e4a70713          	addi	a4,a4,-438 # 80011170 <cons>
    8000032e:	0a072783          	lw	a5,160(a4)
    80000332:	09872703          	lw	a4,152(a4)
    80000336:	9f99                	subw	a5,a5,a4
    80000338:	07f00713          	li	a4,127
    8000033c:	fcf763e3          	bltu	a4,a5,80000302 <consoleintr+0x3c>
    80000340:	47b5                	li	a5,13
    80000342:	0cf48763          	beq	s1,a5,80000410 <consoleintr+0x14a>
    80000346:	8526                	mv	a0,s1
    80000348:	00000097          	auipc	ra,0x0
    8000034c:	f3c080e7          	jalr	-196(ra) # 80000284 <consputc>
    80000350:	00011797          	auipc	a5,0x11
    80000354:	e2078793          	addi	a5,a5,-480 # 80011170 <cons>
    80000358:	0a07a703          	lw	a4,160(a5)
    8000035c:	0017069b          	addiw	a3,a4,1
    80000360:	0006861b          	sext.w	a2,a3
    80000364:	0ad7a023          	sw	a3,160(a5)
    80000368:	07f77713          	andi	a4,a4,127
    8000036c:	97ba                	add	a5,a5,a4
    8000036e:	00978c23          	sb	s1,24(a5)
    80000372:	47a9                	li	a5,10
    80000374:	0cf48563          	beq	s1,a5,8000043e <consoleintr+0x178>
    80000378:	4791                	li	a5,4
    8000037a:	0cf48263          	beq	s1,a5,8000043e <consoleintr+0x178>
    8000037e:	00011797          	auipc	a5,0x11
    80000382:	e8a7a783          	lw	a5,-374(a5) # 80011208 <cons+0x98>
    80000386:	0807879b          	addiw	a5,a5,128
    8000038a:	f6f61ce3          	bne	a2,a5,80000302 <consoleintr+0x3c>
    8000038e:	863e                	mv	a2,a5
    80000390:	a07d                	j	8000043e <consoleintr+0x178>
    80000392:	00011717          	auipc	a4,0x11
    80000396:	dde70713          	addi	a4,a4,-546 # 80011170 <cons>
    8000039a:	0a072783          	lw	a5,160(a4)
    8000039e:	09c72703          	lw	a4,156(a4)
    800003a2:	00011497          	auipc	s1,0x11
    800003a6:	dce48493          	addi	s1,s1,-562 # 80011170 <cons>
    800003aa:	4929                	li	s2,10
    800003ac:	f4f70be3          	beq	a4,a5,80000302 <consoleintr+0x3c>
    800003b0:	37fd                	addiw	a5,a5,-1
    800003b2:	07f7f713          	andi	a4,a5,127
    800003b6:	9726                	add	a4,a4,s1
    800003b8:	01874703          	lbu	a4,24(a4)
    800003bc:	f52703e3          	beq	a4,s2,80000302 <consoleintr+0x3c>
    800003c0:	0af4a023          	sw	a5,160(s1)
    800003c4:	10000513          	li	a0,256
    800003c8:	00000097          	auipc	ra,0x0
    800003cc:	ebc080e7          	jalr	-324(ra) # 80000284 <consputc>
    800003d0:	0a04a783          	lw	a5,160(s1)
    800003d4:	09c4a703          	lw	a4,156(s1)
    800003d8:	fcf71ce3          	bne	a4,a5,800003b0 <consoleintr+0xea>
    800003dc:	b71d                	j	80000302 <consoleintr+0x3c>
    800003de:	00011717          	auipc	a4,0x11
    800003e2:	d9270713          	addi	a4,a4,-622 # 80011170 <cons>
    800003e6:	0a072783          	lw	a5,160(a4)
    800003ea:	09c72703          	lw	a4,156(a4)
    800003ee:	f0f70ae3          	beq	a4,a5,80000302 <consoleintr+0x3c>
    800003f2:	37fd                	addiw	a5,a5,-1
    800003f4:	00011717          	auipc	a4,0x11
    800003f8:	e0f72e23          	sw	a5,-484(a4) # 80011210 <cons+0xa0>
    800003fc:	10000513          	li	a0,256
    80000400:	00000097          	auipc	ra,0x0
    80000404:	e84080e7          	jalr	-380(ra) # 80000284 <consputc>
    80000408:	bded                	j	80000302 <consoleintr+0x3c>
    8000040a:	ee048ce3          	beqz	s1,80000302 <consoleintr+0x3c>
    8000040e:	bf21                	j	80000326 <consoleintr+0x60>
    80000410:	4529                	li	a0,10
    80000412:	00000097          	auipc	ra,0x0
    80000416:	e72080e7          	jalr	-398(ra) # 80000284 <consputc>
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
    8000043e:	00011797          	auipc	a5,0x11
    80000442:	dcc7a723          	sw	a2,-562(a5) # 8001120c <cons+0x9c>
    80000446:	00011517          	auipc	a0,0x11
    8000044a:	dc250513          	addi	a0,a0,-574 # 80011208 <cons+0x98>
    8000044e:	00002097          	auipc	ra,0x2
    80000452:	f86080e7          	jalr	-122(ra) # 800023d4 <wakeup>
    80000456:	b575                	j	80000302 <consoleintr+0x3c>

0000000080000458 <consoleinit>:
    80000458:	1141                	addi	sp,sp,-16
    8000045a:	e406                	sd	ra,8(sp)
    8000045c:	e022                	sd	s0,0(sp)
    8000045e:	0800                	addi	s0,sp,16
    80000460:	00008597          	auipc	a1,0x8
    80000464:	bb058593          	addi	a1,a1,-1104 # 80008010 <etext+0x10>
    80000468:	00011517          	auipc	a0,0x11
    8000046c:	d0850513          	addi	a0,a0,-760 # 80011170 <cons>
    80000470:	00000097          	auipc	ra,0x0
    80000474:	7e6080e7          	jalr	2022(ra) # 80000c56 <initlock>
    80000478:	00000097          	auipc	ra,0x0
    8000047c:	32c080e7          	jalr	812(ra) # 800007a4 <uartinit>
    80000480:	00021797          	auipc	a5,0x21
    80000484:	e7078793          	addi	a5,a5,-400 # 800212f0 <devsw>
    80000488:	00000717          	auipc	a4,0x0
    8000048c:	cee70713          	addi	a4,a4,-786 # 80000176 <consoleread>
    80000490:	eb98                	sd	a4,16(a5)
    80000492:	00000717          	auipc	a4,0x0
    80000496:	c6070713          	addi	a4,a4,-928 # 800000f2 <consolewrite>
    8000049a:	ef98                	sd	a4,24(a5)
    8000049c:	60a2                	ld	ra,8(sp)
    8000049e:	6402                	ld	s0,0(sp)
    800004a0:	0141                	addi	sp,sp,16
    800004a2:	8082                	ret

00000000800004a4 <printint>:
    800004a4:	7179                	addi	sp,sp,-48
    800004a6:	f406                	sd	ra,40(sp)
    800004a8:	f022                	sd	s0,32(sp)
    800004aa:	ec26                	sd	s1,24(sp)
    800004ac:	e84a                	sd	s2,16(sp)
    800004ae:	1800                	addi	s0,sp,48
    800004b0:	c219                	beqz	a2,800004b6 <printint+0x12>
    800004b2:	08054763          	bltz	a0,80000540 <printint+0x9c>
    800004b6:	2501                	sext.w	a0,a0
    800004b8:	4881                	li	a7,0
    800004ba:	fd040693          	addi	a3,s0,-48
    800004be:	4701                	li	a4,0
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
    800004e0:	0005079b          	sext.w	a5,a0
    800004e4:	02b5553b          	divuw	a0,a0,a1
    800004e8:	0685                	addi	a3,a3,1
    800004ea:	feb7f0e3          	bgeu	a5,a1,800004ca <printint+0x26>
    800004ee:	00088c63          	beqz	a7,80000506 <printint+0x62>
    800004f2:	fe070793          	addi	a5,a4,-32
    800004f6:	00878733          	add	a4,a5,s0
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2
    80000506:	02e05763          	blez	a4,80000534 <printint+0x90>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d5e080e7          	jalr	-674(ra) # 80000284 <consputc>
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7e>
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    80000540:	40a0053b          	negw	a0,a0
    80000544:	4885                	li	a7,1
    80000546:	bf95                	j	800004ba <printint+0x16>

0000000080000548 <panic>:
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
    80000554:	00011797          	auipc	a5,0x11
    80000558:	cc07ae23          	sw	zero,-804(a5) # 80011230 <pr+0x18>
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	abc50513          	addi	a0,a0,-1348 # 80008018 <etext+0x18>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5250513          	addi	a0,a0,-1198 # 800080c8 <digits+0x88>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598: