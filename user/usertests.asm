
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	642080e7          	jalr	1602(ra) # 5652 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	630080e7          	jalr	1584(ra) # 5652 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	e9a50513          	addi	a0,a0,-358 # 5ed8 <statistics+0x3ac>
      46:	00006097          	auipc	ra,0x6
      4a:	944080e7          	jalr	-1724(ra) # 598a <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	5c2080e7          	jalr	1474(ra) # 5612 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	3e878793          	addi	a5,a5,1000 # 9440 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	af068693          	addi	a3,a3,-1296 # bb50 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	e7850513          	addi	a0,a0,-392 # 5ef8 <statistics+0x3cc>
      88:	00006097          	auipc	ra,0x6
      8c:	902080e7          	jalr	-1790(ra) # 598a <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	580080e7          	jalr	1408(ra) # 5612 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	e6850513          	addi	a0,a0,-408 # 5f10 <statistics+0x3e4>
      b0:	00005097          	auipc	ra,0x5
      b4:	5a2080e7          	jalr	1442(ra) # 5652 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	57e080e7          	jalr	1406(ra) # 563a <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	e6a50513          	addi	a0,a0,-406 # 5f30 <statistics+0x404>
      ce:	00005097          	auipc	ra,0x5
      d2:	584080e7          	jalr	1412(ra) # 5652 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	e3250513          	addi	a0,a0,-462 # 5f18 <statistics+0x3ec>
      ee:	00006097          	auipc	ra,0x6
      f2:	89c080e7          	jalr	-1892(ra) # 598a <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	51a080e7          	jalr	1306(ra) # 5612 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	e3e50513          	addi	a0,a0,-450 # 5f40 <statistics+0x414>
     10a:	00006097          	auipc	ra,0x6
     10e:	880080e7          	jalr	-1920(ra) # 598a <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	4fe080e7          	jalr	1278(ra) # 5612 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	e3c50513          	addi	a0,a0,-452 # 5f68 <statistics+0x43c>
     134:	00005097          	auipc	ra,0x5
     138:	52e080e7          	jalr	1326(ra) # 5662 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	e2850513          	addi	a0,a0,-472 # 5f68 <statistics+0x43c>
     148:	00005097          	auipc	ra,0x5
     14c:	50a080e7          	jalr	1290(ra) # 5652 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	e2458593          	addi	a1,a1,-476 # 5f78 <statistics+0x44c>
     15c:	00005097          	auipc	ra,0x5
     160:	4d6080e7          	jalr	1238(ra) # 5632 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	e0050513          	addi	a0,a0,-512 # 5f68 <statistics+0x43c>
     170:	00005097          	auipc	ra,0x5
     174:	4e2080e7          	jalr	1250(ra) # 5652 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	e0458593          	addi	a1,a1,-508 # 5f80 <statistics+0x454>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	4ac080e7          	jalr	1196(ra) # 5632 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	dd450513          	addi	a0,a0,-556 # 5f68 <statistics+0x43c>
     19c:	00005097          	auipc	ra,0x5
     1a0:	4c6080e7          	jalr	1222(ra) # 5662 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	494080e7          	jalr	1172(ra) # 563a <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	48a080e7          	jalr	1162(ra) # 563a <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	dbe50513          	addi	a0,a0,-578 # 5f88 <statistics+0x45c>
     1d2:	00005097          	auipc	ra,0x5
     1d6:	7b8080e7          	jalr	1976(ra) # 598a <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	436080e7          	jalr	1078(ra) # 5612 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00005097          	auipc	ra,0x5
     214:	442080e7          	jalr	1090(ra) # 5652 <open>
    close(fd);
     218:	00005097          	auipc	ra,0x5
     21c:	422080e7          	jalr	1058(ra) # 563a <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00005097          	auipc	ra,0x5
     24a:	41c080e7          	jalr	1052(ra) # 5662 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	b0c50513          	addi	a0,a0,-1268 # 5d88 <statistics+0x25c>
     284:	00005097          	auipc	ra,0x5
     288:	3de080e7          	jalr	990(ra) # 5662 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	af8a8a93          	addi	s5,s5,-1288 # 5d88 <statistics+0x25c>
      int cc = write(fd, buf, sz);
     298:	0000ca17          	auipc	s4,0xc
     29c:	8b8a0a13          	addi	s4,s4,-1864 # bb50 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x173>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00005097          	auipc	ra,0x5
     2b0:	3a6080e7          	jalr	934(ra) # 5652 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00005097          	auipc	ra,0x5
     2c2:	374080e7          	jalr	884(ra) # 5632 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	360080e7          	jalr	864(ra) # 5632 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	35a080e7          	jalr	858(ra) # 563a <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00005097          	auipc	ra,0x5
     2ee:	378080e7          	jalr	888(ra) # 5662 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	c9e50513          	addi	a0,a0,-866 # 5fb0 <statistics+0x484>
     31a:	00005097          	auipc	ra,0x5
     31e:	670080e7          	jalr	1648(ra) # 598a <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	2ee080e7          	jalr	750(ra) # 5612 <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	c9a50513          	addi	a0,a0,-870 # 5fd0 <statistics+0x4a4>
     33e:	00005097          	auipc	ra,0x5
     342:	64c080e7          	jalr	1612(ra) # 598a <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	2ca080e7          	jalr	714(ra) # 5612 <exit>

0000000000000350 <copyin>:
{
     350:	715d                	addi	sp,sp,-80
     352:	e486                	sd	ra,72(sp)
     354:	e0a2                	sd	s0,64(sp)
     356:	fc26                	sd	s1,56(sp)
     358:	f84a                	sd	s2,48(sp)
     35a:	f44e                	sd	s3,40(sp)
     35c:	f052                	sd	s4,32(sp)
     35e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     360:	4785                	li	a5,1
     362:	07fe                	slli	a5,a5,0x1f
     364:	fcf43023          	sd	a5,-64(s0)
     368:	57fd                	li	a5,-1
     36a:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     36e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     372:	00006a17          	auipc	s4,0x6
     376:	c76a0a13          	addi	s4,s4,-906 # 5fe8 <statistics+0x4bc>
    uint64 addr = addrs[ai];
     37a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     37e:	20100593          	li	a1,513
     382:	8552                	mv	a0,s4
     384:	00005097          	auipc	ra,0x5
     388:	2ce080e7          	jalr	718(ra) # 5652 <open>
     38c:	84aa                	mv	s1,a0
    if(fd < 0){
     38e:	08054863          	bltz	a0,41e <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     392:	6609                	lui	a2,0x2
     394:	85ce                	mv	a1,s3
     396:	00005097          	auipc	ra,0x5
     39a:	29c080e7          	jalr	668(ra) # 5632 <write>
    if(n >= 0){
     39e:	08055d63          	bgez	a0,438 <copyin+0xe8>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00005097          	auipc	ra,0x5
     3a8:	296080e7          	jalr	662(ra) # 563a <close>
    unlink("copyin1");
     3ac:	8552                	mv	a0,s4
     3ae:	00005097          	auipc	ra,0x5
     3b2:	2b4080e7          	jalr	692(ra) # 5662 <unlink>
    n = write(1, (char*)addr, 8192);
     3b6:	6609                	lui	a2,0x2
     3b8:	85ce                	mv	a1,s3
     3ba:	4505                	li	a0,1
     3bc:	00005097          	auipc	ra,0x5
     3c0:	276080e7          	jalr	630(ra) # 5632 <write>
    if(n > 0){
     3c4:	08a04963          	bgtz	a0,456 <copyin+0x106>
    if(pipe(fds) < 0){
     3c8:	fb840513          	addi	a0,s0,-72
     3cc:	00005097          	auipc	ra,0x5
     3d0:	256080e7          	jalr	598(ra) # 5622 <pipe>
     3d4:	0a054063          	bltz	a0,474 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3d8:	6609                	lui	a2,0x2
     3da:	85ce                	mv	a1,s3
     3dc:	fbc42503          	lw	a0,-68(s0)
     3e0:	00005097          	auipc	ra,0x5
     3e4:	252080e7          	jalr	594(ra) # 5632 <write>
    if(n > 0){
     3e8:	0aa04363          	bgtz	a0,48e <copyin+0x13e>
    close(fds[0]);
     3ec:	fb842503          	lw	a0,-72(s0)
     3f0:	00005097          	auipc	ra,0x5
     3f4:	24a080e7          	jalr	586(ra) # 563a <close>
    close(fds[1]);
     3f8:	fbc42503          	lw	a0,-68(s0)
     3fc:	00005097          	auipc	ra,0x5
     400:	23e080e7          	jalr	574(ra) # 563a <close>
  for(int ai = 0; ai < 2; ai++){
     404:	0921                	addi	s2,s2,8
     406:	fd040793          	addi	a5,s0,-48
     40a:	f6f918e3          	bne	s2,a5,37a <copyin+0x2a>
}
     40e:	60a6                	ld	ra,72(sp)
     410:	6406                	ld	s0,64(sp)
     412:	74e2                	ld	s1,56(sp)
     414:	7942                	ld	s2,48(sp)
     416:	79a2                	ld	s3,40(sp)
     418:	7a02                	ld	s4,32(sp)
     41a:	6161                	addi	sp,sp,80
     41c:	8082                	ret
      printf("open(copyin1) failed\n");
     41e:	00006517          	auipc	a0,0x6
     422:	bd250513          	addi	a0,a0,-1070 # 5ff0 <statistics+0x4c4>
     426:	00005097          	auipc	ra,0x5
     42a:	564080e7          	jalr	1380(ra) # 598a <printf>
      exit(1);
     42e:	4505                	li	a0,1
     430:	00005097          	auipc	ra,0x5
     434:	1e2080e7          	jalr	482(ra) # 5612 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     438:	862a                	mv	a2,a0
     43a:	85ce                	mv	a1,s3
     43c:	00006517          	auipc	a0,0x6
     440:	bcc50513          	addi	a0,a0,-1076 # 6008 <statistics+0x4dc>
     444:	00005097          	auipc	ra,0x5
     448:	546080e7          	jalr	1350(ra) # 598a <printf>
      exit(1);
     44c:	4505                	li	a0,1
     44e:	00005097          	auipc	ra,0x5
     452:	1c4080e7          	jalr	452(ra) # 5612 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     456:	862a                	mv	a2,a0
     458:	85ce                	mv	a1,s3
     45a:	00006517          	auipc	a0,0x6
     45e:	bde50513          	addi	a0,a0,-1058 # 6038 <statistics+0x50c>
     462:	00005097          	auipc	ra,0x5
     466:	528080e7          	jalr	1320(ra) # 598a <printf>
      exit(1);
     46a:	4505                	li	a0,1
     46c:	00005097          	auipc	ra,0x5
     470:	1a6080e7          	jalr	422(ra) # 5612 <exit>
      printf("pipe() failed\n");
     474:	00006517          	auipc	a0,0x6
     478:	bf450513          	addi	a0,a0,-1036 # 6068 <statistics+0x53c>
     47c:	00005097          	auipc	ra,0x5
     480:	50e080e7          	jalr	1294(ra) # 598a <printf>
      exit(1);
     484:	4505                	li	a0,1
     486:	00005097          	auipc	ra,0x5
     48a:	18c080e7          	jalr	396(ra) # 5612 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     48e:	862a                	mv	a2,a0
     490:	85ce                	mv	a1,s3
     492:	00006517          	auipc	a0,0x6
     496:	be650513          	addi	a0,a0,-1050 # 6078 <statistics+0x54c>
     49a:	00005097          	auipc	ra,0x5
     49e:	4f0080e7          	jalr	1264(ra) # 598a <printf>
      exit(1);
     4a2:	4505                	li	a0,1
     4a4:	00005097          	auipc	ra,0x5
     4a8:	16e080e7          	jalr	366(ra) # 5612 <exit>

00000000000004ac <copyout>:
{
     4ac:	711d                	addi	sp,sp,-96
     4ae:	ec86                	sd	ra,88(sp)
     4b0:	e8a2                	sd	s0,80(sp)
     4b2:	e4a6                	sd	s1,72(sp)
     4b4:	e0ca                	sd	s2,64(sp)
     4b6:	fc4e                	sd	s3,56(sp)
     4b8:	f852                	sd	s4,48(sp)
     4ba:	f456                	sd	s5,40(sp)
     4bc:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4be:	4785                	li	a5,1
     4c0:	07fe                	slli	a5,a5,0x1f
     4c2:	faf43823          	sd	a5,-80(s0)
     4c6:	57fd                	li	a5,-1
     4c8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4cc:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4d0:	00006a17          	auipc	s4,0x6
     4d4:	bd8a0a13          	addi	s4,s4,-1064 # 60a8 <statistics+0x57c>
    n = write(fds[1], "x", 1);
     4d8:	00006a97          	auipc	s5,0x6
     4dc:	aa8a8a93          	addi	s5,s5,-1368 # 5f80 <statistics+0x454>
    uint64 addr = addrs[ai];
     4e0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4e4:	4581                	li	a1,0
     4e6:	8552                	mv	a0,s4
     4e8:	00005097          	auipc	ra,0x5
     4ec:	16a080e7          	jalr	362(ra) # 5652 <open>
     4f0:	84aa                	mv	s1,a0
    if(fd < 0){
     4f2:	08054663          	bltz	a0,57e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     4f6:	6609                	lui	a2,0x2
     4f8:	85ce                	mv	a1,s3
     4fa:	00005097          	auipc	ra,0x5
     4fe:	130080e7          	jalr	304(ra) # 562a <read>
    if(n > 0){
     502:	08a04b63          	bgtz	a0,598 <copyout+0xec>
    close(fd);
     506:	8526                	mv	a0,s1
     508:	00005097          	auipc	ra,0x5
     50c:	132080e7          	jalr	306(ra) # 563a <close>
    if(pipe(fds) < 0){
     510:	fa840513          	addi	a0,s0,-88
     514:	00005097          	auipc	ra,0x5
     518:	10e080e7          	jalr	270(ra) # 5622 <pipe>
     51c:	08054d63          	bltz	a0,5b6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     520:	4605                	li	a2,1
     522:	85d6                	mv	a1,s5
     524:	fac42503          	lw	a0,-84(s0)
     528:	00005097          	auipc	ra,0x5
     52c:	10a080e7          	jalr	266(ra) # 5632 <write>
    if(n != 1){
     530:	4785                	li	a5,1
     532:	08f51f63          	bne	a0,a5,5d0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     536:	6609                	lui	a2,0x2
     538:	85ce                	mv	a1,s3
     53a:	fa842503          	lw	a0,-88(s0)
     53e:	00005097          	auipc	ra,0x5
     542:	0ec080e7          	jalr	236(ra) # 562a <read>
    if(n > 0){
     546:	0aa04263          	bgtz	a0,5ea <copyout+0x13e>
    close(fds[0]);
     54a:	fa842503          	lw	a0,-88(s0)
     54e:	00005097          	auipc	ra,0x5
     552:	0ec080e7          	jalr	236(ra) # 563a <close>
    close(fds[1]);
     556:	fac42503          	lw	a0,-84(s0)
     55a:	00005097          	auipc	ra,0x5
     55e:	0e0080e7          	jalr	224(ra) # 563a <close>
  for(int ai = 0; ai < 2; ai++){
     562:	0921                	addi	s2,s2,8
     564:	fc040793          	addi	a5,s0,-64
     568:	f6f91ce3          	bne	s2,a5,4e0 <copyout+0x34>
}
     56c:	60e6                	ld	ra,88(sp)
     56e:	6446                	ld	s0,80(sp)
     570:	64a6                	ld	s1,72(sp)
     572:	6906                	ld	s2,64(sp)
     574:	79e2                	ld	s3,56(sp)
     576:	7a42                	ld	s4,48(sp)
     578:	7aa2                	ld	s5,40(sp)
     57a:	6125                	addi	sp,sp,96
     57c:	8082                	ret
      printf("open(README) failed\n");
     57e:	00006517          	auipc	a0,0x6
     582:	b3250513          	addi	a0,a0,-1230 # 60b0 <statistics+0x584>
     586:	00005097          	auipc	ra,0x5
     58a:	404080e7          	jalr	1028(ra) # 598a <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	00005097          	auipc	ra,0x5
     594:	082080e7          	jalr	130(ra) # 5612 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     598:	862a                	mv	a2,a0
     59a:	85ce                	mv	a1,s3
     59c:	00006517          	auipc	a0,0x6
     5a0:	b2c50513          	addi	a0,a0,-1236 # 60c8 <statistics+0x59c>
     5a4:	00005097          	auipc	ra,0x5
     5a8:	3e6080e7          	jalr	998(ra) # 598a <printf>
      exit(1);
     5ac:	4505                	li	a0,1
     5ae:	00005097          	auipc	ra,0x5
     5b2:	064080e7          	jalr	100(ra) # 5612 <exit>
      printf("pipe() failed\n");
     5b6:	00006517          	auipc	a0,0x6
     5ba:	ab250513          	addi	a0,a0,-1358 # 6068 <statistics+0x53c>
     5be:	00005097          	auipc	ra,0x5
     5c2:	3cc080e7          	jalr	972(ra) # 598a <printf>
      exit(1);
     5c6:	4505                	li	a0,1
     5c8:	00005097          	auipc	ra,0x5
     5cc:	04a080e7          	jalr	74(ra) # 5612 <exit>
      printf("pipe write failed\n");
     5d0:	00006517          	auipc	a0,0x6
     5d4:	b2850513          	addi	a0,a0,-1240 # 60f8 <statistics+0x5cc>
     5d8:	00005097          	auipc	ra,0x5
     5dc:	3b2080e7          	jalr	946(ra) # 598a <printf>
      exit(1);
     5e0:	4505                	li	a0,1
     5e2:	00005097          	auipc	ra,0x5
     5e6:	030080e7          	jalr	48(ra) # 5612 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ea:	862a                	mv	a2,a0
     5ec:	85ce                	mv	a1,s3
     5ee:	00006517          	auipc	a0,0x6
     5f2:	b2250513          	addi	a0,a0,-1246 # 6110 <statistics+0x5e4>
     5f6:	00005097          	auipc	ra,0x5
     5fa:	394080e7          	jalr	916(ra) # 598a <printf>
      exit(1);
     5fe:	4505                	li	a0,1
     600:	00005097          	auipc	ra,0x5
     604:	012080e7          	jalr	18(ra) # 5612 <exit>

0000000000000608 <truncate1>:
{
     608:	711d                	addi	sp,sp,-96
     60a:	ec86                	sd	ra,88(sp)
     60c:	e8a2                	sd	s0,80(sp)
     60e:	e4a6                	sd	s1,72(sp)
     610:	e0ca                	sd	s2,64(sp)
     612:	fc4e                	sd	s3,56(sp)
     614:	f852                	sd	s4,48(sp)
     616:	f456                	sd	s5,40(sp)
     618:	1080                	addi	s0,sp,96
     61a:	8aaa                	mv	s5,a0
  unlink("truncfile");
     61c:	00006517          	auipc	a0,0x6
     620:	94c50513          	addi	a0,a0,-1716 # 5f68 <statistics+0x43c>
     624:	00005097          	auipc	ra,0x5
     628:	03e080e7          	jalr	62(ra) # 5662 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     62c:	60100593          	li	a1,1537
     630:	00006517          	auipc	a0,0x6
     634:	93850513          	addi	a0,a0,-1736 # 5f68 <statistics+0x43c>
     638:	00005097          	auipc	ra,0x5
     63c:	01a080e7          	jalr	26(ra) # 5652 <open>
     640:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     642:	4611                	li	a2,4
     644:	00006597          	auipc	a1,0x6
     648:	93458593          	addi	a1,a1,-1740 # 5f78 <statistics+0x44c>
     64c:	00005097          	auipc	ra,0x5
     650:	fe6080e7          	jalr	-26(ra) # 5632 <write>
  close(fd1);
     654:	8526                	mv	a0,s1
     656:	00005097          	auipc	ra,0x5
     65a:	fe4080e7          	jalr	-28(ra) # 563a <close>
  int fd2 = open("truncfile", O_RDONLY);
     65e:	4581                	li	a1,0
     660:	00006517          	auipc	a0,0x6
     664:	90850513          	addi	a0,a0,-1784 # 5f68 <statistics+0x43c>
     668:	00005097          	auipc	ra,0x5
     66c:	fea080e7          	jalr	-22(ra) # 5652 <open>
     670:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     672:	02000613          	li	a2,32
     676:	fa040593          	addi	a1,s0,-96
     67a:	00005097          	auipc	ra,0x5
     67e:	fb0080e7          	jalr	-80(ra) # 562a <read>
  if(n != 4){
     682:	4791                	li	a5,4
     684:	0cf51e63          	bne	a0,a5,760 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     688:	40100593          	li	a1,1025
     68c:	00006517          	auipc	a0,0x6
     690:	8dc50513          	addi	a0,a0,-1828 # 5f68 <statistics+0x43c>
     694:	00005097          	auipc	ra,0x5
     698:	fbe080e7          	jalr	-66(ra) # 5652 <open>
     69c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     69e:	4581                	li	a1,0
     6a0:	00006517          	auipc	a0,0x6
     6a4:	8c850513          	addi	a0,a0,-1848 # 5f68 <statistics+0x43c>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	faa080e7          	jalr	-86(ra) # 5652 <open>
     6b0:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6b2:	02000613          	li	a2,32
     6b6:	fa040593          	addi	a1,s0,-96
     6ba:	00005097          	auipc	ra,0x5
     6be:	f70080e7          	jalr	-144(ra) # 562a <read>
     6c2:	8a2a                	mv	s4,a0
  if(n != 0){
     6c4:	ed4d                	bnez	a0,77e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	8526                	mv	a0,s1
     6d0:	00005097          	auipc	ra,0x5
     6d4:	f5a080e7          	jalr	-166(ra) # 562a <read>
     6d8:	8a2a                	mv	s4,a0
  if(n != 0){
     6da:	e971                	bnez	a0,7ae <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6dc:	4619                	li	a2,6
     6de:	00006597          	auipc	a1,0x6
     6e2:	ac258593          	addi	a1,a1,-1342 # 61a0 <statistics+0x674>
     6e6:	854e                	mv	a0,s3
     6e8:	00005097          	auipc	ra,0x5
     6ec:	f4a080e7          	jalr	-182(ra) # 5632 <write>
  n = read(fd3, buf, sizeof(buf));
     6f0:	02000613          	li	a2,32
     6f4:	fa040593          	addi	a1,s0,-96
     6f8:	854a                	mv	a0,s2
     6fa:	00005097          	auipc	ra,0x5
     6fe:	f30080e7          	jalr	-208(ra) # 562a <read>
  if(n != 6){
     702:	4799                	li	a5,6
     704:	0cf51d63          	bne	a0,a5,7de <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     708:	02000613          	li	a2,32
     70c:	fa040593          	addi	a1,s0,-96
     710:	8526                	mv	a0,s1
     712:	00005097          	auipc	ra,0x5
     716:	f18080e7          	jalr	-232(ra) # 562a <read>
  if(n != 2){
     71a:	4789                	li	a5,2
     71c:	0ef51063          	bne	a0,a5,7fc <truncate1+0x1f4>
  unlink("truncfile");
     720:	00006517          	auipc	a0,0x6
     724:	84850513          	addi	a0,a0,-1976 # 5f68 <statistics+0x43c>
     728:	00005097          	auipc	ra,0x5
     72c:	f3a080e7          	jalr	-198(ra) # 5662 <unlink>
  close(fd1);
     730:	854e                	mv	a0,s3
     732:	00005097          	auipc	ra,0x5
     736:	f08080e7          	jalr	-248(ra) # 563a <close>
  close(fd2);
     73a:	8526                	mv	a0,s1
     73c:	00005097          	auipc	ra,0x5
     740:	efe080e7          	jalr	-258(ra) # 563a <close>
  close(fd3);
     744:	854a                	mv	a0,s2
     746:	00005097          	auipc	ra,0x5
     74a:	ef4080e7          	jalr	-268(ra) # 563a <close>
}
     74e:	60e6                	ld	ra,88(sp)
     750:	6446                	ld	s0,80(sp)
     752:	64a6                	ld	s1,72(sp)
     754:	6906                	ld	s2,64(sp)
     756:	79e2                	ld	s3,56(sp)
     758:	7a42                	ld	s4,48(sp)
     75a:	7aa2                	ld	s5,40(sp)
     75c:	6125                	addi	sp,sp,96
     75e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     760:	862a                	mv	a2,a0
     762:	85d6                	mv	a1,s5
     764:	00006517          	auipc	a0,0x6
     768:	9dc50513          	addi	a0,a0,-1572 # 6140 <statistics+0x614>
     76c:	00005097          	auipc	ra,0x5
     770:	21e080e7          	jalr	542(ra) # 598a <printf>
    exit(1);
     774:	4505                	li	a0,1
     776:	00005097          	auipc	ra,0x5
     77a:	e9c080e7          	jalr	-356(ra) # 5612 <exit>
    printf("aaa fd3=%d\n", fd3);
     77e:	85ca                	mv	a1,s2
     780:	00006517          	auipc	a0,0x6
     784:	9e050513          	addi	a0,a0,-1568 # 6160 <statistics+0x634>
     788:	00005097          	auipc	ra,0x5
     78c:	202080e7          	jalr	514(ra) # 598a <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     790:	8652                	mv	a2,s4
     792:	85d6                	mv	a1,s5
     794:	00006517          	auipc	a0,0x6
     798:	9dc50513          	addi	a0,a0,-1572 # 6170 <statistics+0x644>
     79c:	00005097          	auipc	ra,0x5
     7a0:	1ee080e7          	jalr	494(ra) # 598a <printf>
    exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	e6c080e7          	jalr	-404(ra) # 5612 <exit>
    printf("bbb fd2=%d\n", fd2);
     7ae:	85a6                	mv	a1,s1
     7b0:	00006517          	auipc	a0,0x6
     7b4:	9e050513          	addi	a0,a0,-1568 # 6190 <statistics+0x664>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	1d2080e7          	jalr	466(ra) # 598a <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7c0:	8652                	mv	a2,s4
     7c2:	85d6                	mv	a1,s5
     7c4:	00006517          	auipc	a0,0x6
     7c8:	9ac50513          	addi	a0,a0,-1620 # 6170 <statistics+0x644>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	1be080e7          	jalr	446(ra) # 598a <printf>
    exit(1);
     7d4:	4505                	li	a0,1
     7d6:	00005097          	auipc	ra,0x5
     7da:	e3c080e7          	jalr	-452(ra) # 5612 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7de:	862a                	mv	a2,a0
     7e0:	85d6                	mv	a1,s5
     7e2:	00006517          	auipc	a0,0x6
     7e6:	9c650513          	addi	a0,a0,-1594 # 61a8 <statistics+0x67c>
     7ea:	00005097          	auipc	ra,0x5
     7ee:	1a0080e7          	jalr	416(ra) # 598a <printf>
    exit(1);
     7f2:	4505                	li	a0,1
     7f4:	00005097          	auipc	ra,0x5
     7f8:	e1e080e7          	jalr	-482(ra) # 5612 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     7fc:	862a                	mv	a2,a0
     7fe:	85d6                	mv	a1,s5
     800:	00006517          	auipc	a0,0x6
     804:	9c850513          	addi	a0,a0,-1592 # 61c8 <statistics+0x69c>
     808:	00005097          	auipc	ra,0x5
     80c:	182080e7          	jalr	386(ra) # 598a <printf>
    exit(1);
     810:	4505                	li	a0,1
     812:	00005097          	auipc	ra,0x5
     816:	e00080e7          	jalr	-512(ra) # 5612 <exit>

000000000000081a <writetest>:
{
     81a:	7139                	addi	sp,sp,-64
     81c:	fc06                	sd	ra,56(sp)
     81e:	f822                	sd	s0,48(sp)
     820:	f426                	sd	s1,40(sp)
     822:	f04a                	sd	s2,32(sp)
     824:	ec4e                	sd	s3,24(sp)
     826:	e852                	sd	s4,16(sp)
     828:	e456                	sd	s5,8(sp)
     82a:	e05a                	sd	s6,0(sp)
     82c:	0080                	addi	s0,sp,64
     82e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     830:	20200593          	li	a1,514
     834:	00006517          	auipc	a0,0x6
     838:	9b450513          	addi	a0,a0,-1612 # 61e8 <statistics+0x6bc>
     83c:	00005097          	auipc	ra,0x5
     840:	e16080e7          	jalr	-490(ra) # 5652 <open>
  if(fd < 0){
     844:	0a054d63          	bltz	a0,8fe <writetest+0xe4>
     848:	892a                	mv	s2,a0
     84a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     84c:	00006997          	auipc	s3,0x6
     850:	9c498993          	addi	s3,s3,-1596 # 6210 <statistics+0x6e4>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     854:	00006a97          	auipc	s5,0x6
     858:	9f4a8a93          	addi	s5,s5,-1548 # 6248 <statistics+0x71c>
  for(i = 0; i < N; i++){
     85c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	4629                	li	a2,10
     862:	85ce                	mv	a1,s3
     864:	854a                	mv	a0,s2
     866:	00005097          	auipc	ra,0x5
     86a:	dcc080e7          	jalr	-564(ra) # 5632 <write>
     86e:	47a9                	li	a5,10
     870:	0af51563          	bne	a0,a5,91a <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85d6                	mv	a1,s5
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	db8080e7          	jalr	-584(ra) # 5632 <write>
     882:	47a9                	li	a5,10
     884:	0af51a63          	bne	a0,a5,938 <writetest+0x11e>
  for(i = 0; i < N; i++){
     888:	2485                	addiw	s1,s1,1
     88a:	fd449be3          	bne	s1,s4,860 <writetest+0x46>
  close(fd);
     88e:	854a                	mv	a0,s2
     890:	00005097          	auipc	ra,0x5
     894:	daa080e7          	jalr	-598(ra) # 563a <close>
  fd = open("small", O_RDONLY);
     898:	4581                	li	a1,0
     89a:	00006517          	auipc	a0,0x6
     89e:	94e50513          	addi	a0,a0,-1714 # 61e8 <statistics+0x6bc>
     8a2:	00005097          	auipc	ra,0x5
     8a6:	db0080e7          	jalr	-592(ra) # 5652 <open>
     8aa:	84aa                	mv	s1,a0
  if(fd < 0){
     8ac:	0a054563          	bltz	a0,956 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8b0:	7d000613          	li	a2,2000
     8b4:	0000b597          	auipc	a1,0xb
     8b8:	29c58593          	addi	a1,a1,668 # bb50 <buf>
     8bc:	00005097          	auipc	ra,0x5
     8c0:	d6e080e7          	jalr	-658(ra) # 562a <read>
  if(i != N*SZ*2){
     8c4:	7d000793          	li	a5,2000
     8c8:	0af51563          	bne	a0,a5,972 <writetest+0x158>
  close(fd);
     8cc:	8526                	mv	a0,s1
     8ce:	00005097          	auipc	ra,0x5
     8d2:	d6c080e7          	jalr	-660(ra) # 563a <close>
  if(unlink("small") < 0){
     8d6:	00006517          	auipc	a0,0x6
     8da:	91250513          	addi	a0,a0,-1774 # 61e8 <statistics+0x6bc>
     8de:	00005097          	auipc	ra,0x5
     8e2:	d84080e7          	jalr	-636(ra) # 5662 <unlink>
     8e6:	0a054463          	bltz	a0,98e <writetest+0x174>
}
     8ea:	70e2                	ld	ra,56(sp)
     8ec:	7442                	ld	s0,48(sp)
     8ee:	74a2                	ld	s1,40(sp)
     8f0:	7902                	ld	s2,32(sp)
     8f2:	69e2                	ld	s3,24(sp)
     8f4:	6a42                	ld	s4,16(sp)
     8f6:	6aa2                	ld	s5,8(sp)
     8f8:	6b02                	ld	s6,0(sp)
     8fa:	6121                	addi	sp,sp,64
     8fc:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     8fe:	85da                	mv	a1,s6
     900:	00006517          	auipc	a0,0x6
     904:	8f050513          	addi	a0,a0,-1808 # 61f0 <statistics+0x6c4>
     908:	00005097          	auipc	ra,0x5
     90c:	082080e7          	jalr	130(ra) # 598a <printf>
    exit(1);
     910:	4505                	li	a0,1
     912:	00005097          	auipc	ra,0x5
     916:	d00080e7          	jalr	-768(ra) # 5612 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     91a:	8626                	mv	a2,s1
     91c:	85da                	mv	a1,s6
     91e:	00006517          	auipc	a0,0x6
     922:	90250513          	addi	a0,a0,-1790 # 6220 <statistics+0x6f4>
     926:	00005097          	auipc	ra,0x5
     92a:	064080e7          	jalr	100(ra) # 598a <printf>
      exit(1);
     92e:	4505                	li	a0,1
     930:	00005097          	auipc	ra,0x5
     934:	ce2080e7          	jalr	-798(ra) # 5612 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     938:	8626                	mv	a2,s1
     93a:	85da                	mv	a1,s6
     93c:	00006517          	auipc	a0,0x6
     940:	91c50513          	addi	a0,a0,-1764 # 6258 <statistics+0x72c>
     944:	00005097          	auipc	ra,0x5
     948:	046080e7          	jalr	70(ra) # 598a <printf>
      exit(1);
     94c:	4505                	li	a0,1
     94e:	00005097          	auipc	ra,0x5
     952:	cc4080e7          	jalr	-828(ra) # 5612 <exit>
    printf("%s: error: open small failed!\n", s);
     956:	85da                	mv	a1,s6
     958:	00006517          	auipc	a0,0x6
     95c:	92850513          	addi	a0,a0,-1752 # 6280 <statistics+0x754>
     960:	00005097          	auipc	ra,0x5
     964:	02a080e7          	jalr	42(ra) # 598a <printf>
    exit(1);
     968:	4505                	li	a0,1
     96a:	00005097          	auipc	ra,0x5
     96e:	ca8080e7          	jalr	-856(ra) # 5612 <exit>
    printf("%s: read failed\n", s);
     972:	85da                	mv	a1,s6
     974:	00006517          	auipc	a0,0x6
     978:	92c50513          	addi	a0,a0,-1748 # 62a0 <statistics+0x774>
     97c:	00005097          	auipc	ra,0x5
     980:	00e080e7          	jalr	14(ra) # 598a <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	c8c080e7          	jalr	-884(ra) # 5612 <exit>
    printf("%s: unlink small failed\n", s);
     98e:	85da                	mv	a1,s6
     990:	00006517          	auipc	a0,0x6
     994:	92850513          	addi	a0,a0,-1752 # 62b8 <statistics+0x78c>
     998:	00005097          	auipc	ra,0x5
     99c:	ff2080e7          	jalr	-14(ra) # 598a <printf>
    exit(1);
     9a0:	4505                	li	a0,1
     9a2:	00005097          	auipc	ra,0x5
     9a6:	c70080e7          	jalr	-912(ra) # 5612 <exit>

00000000000009aa <writebig>:
{
     9aa:	7139                	addi	sp,sp,-64
     9ac:	fc06                	sd	ra,56(sp)
     9ae:	f822                	sd	s0,48(sp)
     9b0:	f426                	sd	s1,40(sp)
     9b2:	f04a                	sd	s2,32(sp)
     9b4:	ec4e                	sd	s3,24(sp)
     9b6:	e852                	sd	s4,16(sp)
     9b8:	e456                	sd	s5,8(sp)
     9ba:	0080                	addi	s0,sp,64
     9bc:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9be:	20200593          	li	a1,514
     9c2:	00006517          	auipc	a0,0x6
     9c6:	91650513          	addi	a0,a0,-1770 # 62d8 <statistics+0x7ac>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	c88080e7          	jalr	-888(ra) # 5652 <open>
     9d2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9d4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9d6:	0000b917          	auipc	s2,0xb
     9da:	17a90913          	addi	s2,s2,378 # bb50 <buf>
  for(i = 0; i < MAXFILE; i++){
     9de:	10c00a13          	li	s4,268
  if(fd < 0){
     9e2:	06054c63          	bltz	a0,a5a <writebig+0xb0>
    ((int*)buf)[0] = i;
     9e6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9ea:	40000613          	li	a2,1024
     9ee:	85ca                	mv	a1,s2
     9f0:	854e                	mv	a0,s3
     9f2:	00005097          	auipc	ra,0x5
     9f6:	c40080e7          	jalr	-960(ra) # 5632 <write>
     9fa:	40000793          	li	a5,1024
     9fe:	06f51c63          	bne	a0,a5,a76 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a02:	2485                	addiw	s1,s1,1
     a04:	ff4491e3          	bne	s1,s4,9e6 <writebig+0x3c>
  close(fd);
     a08:	854e                	mv	a0,s3
     a0a:	00005097          	auipc	ra,0x5
     a0e:	c30080e7          	jalr	-976(ra) # 563a <close>
  fd = open("big", O_RDONLY);
     a12:	4581                	li	a1,0
     a14:	00006517          	auipc	a0,0x6
     a18:	8c450513          	addi	a0,a0,-1852 # 62d8 <statistics+0x7ac>
     a1c:	00005097          	auipc	ra,0x5
     a20:	c36080e7          	jalr	-970(ra) # 5652 <open>
     a24:	89aa                	mv	s3,a0
  n = 0;
     a26:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a28:	0000b917          	auipc	s2,0xb
     a2c:	12890913          	addi	s2,s2,296 # bb50 <buf>
  if(fd < 0){
     a30:	06054263          	bltz	a0,a94 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a34:	40000613          	li	a2,1024
     a38:	85ca                	mv	a1,s2
     a3a:	854e                	mv	a0,s3
     a3c:	00005097          	auipc	ra,0x5
     a40:	bee080e7          	jalr	-1042(ra) # 562a <read>
    if(i == 0){
     a44:	c535                	beqz	a0,ab0 <writebig+0x106>
    } else if(i != BSIZE){
     a46:	40000793          	li	a5,1024
     a4a:	0af51f63          	bne	a0,a5,b08 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0c969a63          	bne	a3,s1,b26 <writebig+0x17c>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	bff1                	j	a34 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00006517          	auipc	a0,0x6
     a60:	88450513          	addi	a0,a0,-1916 # 62e0 <statistics+0x7b4>
     a64:	00005097          	auipc	ra,0x5
     a68:	f26080e7          	jalr	-218(ra) # 598a <printf>
    exit(1);
     a6c:	4505                	li	a0,1
     a6e:	00005097          	auipc	ra,0x5
     a72:	ba4080e7          	jalr	-1116(ra) # 5612 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a76:	8626                	mv	a2,s1
     a78:	85d6                	mv	a1,s5
     a7a:	00006517          	auipc	a0,0x6
     a7e:	88650513          	addi	a0,a0,-1914 # 6300 <statistics+0x7d4>
     a82:	00005097          	auipc	ra,0x5
     a86:	f08080e7          	jalr	-248(ra) # 598a <printf>
      exit(1);
     a8a:	4505                	li	a0,1
     a8c:	00005097          	auipc	ra,0x5
     a90:	b86080e7          	jalr	-1146(ra) # 5612 <exit>
    printf("%s: error: open big failed!\n", s);
     a94:	85d6                	mv	a1,s5
     a96:	00006517          	auipc	a0,0x6
     a9a:	89250513          	addi	a0,a0,-1902 # 6328 <statistics+0x7fc>
     a9e:	00005097          	auipc	ra,0x5
     aa2:	eec080e7          	jalr	-276(ra) # 598a <printf>
    exit(1);
     aa6:	4505                	li	a0,1
     aa8:	00005097          	auipc	ra,0x5
     aac:	b6a080e7          	jalr	-1174(ra) # 5612 <exit>
      if(n == MAXFILE - 1){
     ab0:	10b00793          	li	a5,267
     ab4:	02f48a63          	beq	s1,a5,ae8 <writebig+0x13e>
  close(fd);
     ab8:	854e                	mv	a0,s3
     aba:	00005097          	auipc	ra,0x5
     abe:	b80080e7          	jalr	-1152(ra) # 563a <close>
  if(unlink("big") < 0){
     ac2:	00006517          	auipc	a0,0x6
     ac6:	81650513          	addi	a0,a0,-2026 # 62d8 <statistics+0x7ac>
     aca:	00005097          	auipc	ra,0x5
     ace:	b98080e7          	jalr	-1128(ra) # 5662 <unlink>
     ad2:	06054963          	bltz	a0,b44 <writebig+0x19a>
}
     ad6:	70e2                	ld	ra,56(sp)
     ad8:	7442                	ld	s0,48(sp)
     ada:	74a2                	ld	s1,40(sp)
     adc:	7902                	ld	s2,32(sp)
     ade:	69e2                	ld	s3,24(sp)
     ae0:	6a42                	ld	s4,16(sp)
     ae2:	6aa2                	ld	s5,8(sp)
     ae4:	6121                	addi	sp,sp,64
     ae6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ae8:	10b00613          	li	a2,267
     aec:	85d6                	mv	a1,s5
     aee:	00006517          	auipc	a0,0x6
     af2:	85a50513          	addi	a0,a0,-1958 # 6348 <statistics+0x81c>
     af6:	00005097          	auipc	ra,0x5
     afa:	e94080e7          	jalr	-364(ra) # 598a <printf>
        exit(1);
     afe:	4505                	li	a0,1
     b00:	00005097          	auipc	ra,0x5
     b04:	b12080e7          	jalr	-1262(ra) # 5612 <exit>
      printf("%s: read failed %d\n", s, i);
     b08:	862a                	mv	a2,a0
     b0a:	85d6                	mv	a1,s5
     b0c:	00006517          	auipc	a0,0x6
     b10:	86450513          	addi	a0,a0,-1948 # 6370 <statistics+0x844>
     b14:	00005097          	auipc	ra,0x5
     b18:	e76080e7          	jalr	-394(ra) # 598a <printf>
      exit(1);
     b1c:	4505                	li	a0,1
     b1e:	00005097          	auipc	ra,0x5
     b22:	af4080e7          	jalr	-1292(ra) # 5612 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b26:	8626                	mv	a2,s1
     b28:	85d6                	mv	a1,s5
     b2a:	00006517          	auipc	a0,0x6
     b2e:	85e50513          	addi	a0,a0,-1954 # 6388 <statistics+0x85c>
     b32:	00005097          	auipc	ra,0x5
     b36:	e58080e7          	jalr	-424(ra) # 598a <printf>
      exit(1);
     b3a:	4505                	li	a0,1
     b3c:	00005097          	auipc	ra,0x5
     b40:	ad6080e7          	jalr	-1322(ra) # 5612 <exit>
    printf("%s: unlink big failed\n", s);
     b44:	85d6                	mv	a1,s5
     b46:	00006517          	auipc	a0,0x6
     b4a:	86a50513          	addi	a0,a0,-1942 # 63b0 <statistics+0x884>
     b4e:	00005097          	auipc	ra,0x5
     b52:	e3c080e7          	jalr	-452(ra) # 598a <printf>
    exit(1);
     b56:	4505                	li	a0,1
     b58:	00005097          	auipc	ra,0x5
     b5c:	aba080e7          	jalr	-1350(ra) # 5612 <exit>

0000000000000b60 <unlinkread>:
{
     b60:	7179                	addi	sp,sp,-48
     b62:	f406                	sd	ra,40(sp)
     b64:	f022                	sd	s0,32(sp)
     b66:	ec26                	sd	s1,24(sp)
     b68:	e84a                	sd	s2,16(sp)
     b6a:	e44e                	sd	s3,8(sp)
     b6c:	1800                	addi	s0,sp,48
     b6e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b70:	20200593          	li	a1,514
     b74:	00005517          	auipc	a0,0x5
     b78:	1a450513          	addi	a0,a0,420 # 5d18 <statistics+0x1ec>
     b7c:	00005097          	auipc	ra,0x5
     b80:	ad6080e7          	jalr	-1322(ra) # 5652 <open>
  if(fd < 0){
     b84:	0e054563          	bltz	a0,c6e <unlinkread+0x10e>
     b88:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b8a:	4615                	li	a2,5
     b8c:	00006597          	auipc	a1,0x6
     b90:	85c58593          	addi	a1,a1,-1956 # 63e8 <statistics+0x8bc>
     b94:	00005097          	auipc	ra,0x5
     b98:	a9e080e7          	jalr	-1378(ra) # 5632 <write>
  close(fd);
     b9c:	8526                	mv	a0,s1
     b9e:	00005097          	auipc	ra,0x5
     ba2:	a9c080e7          	jalr	-1380(ra) # 563a <close>
  fd = open("unlinkread", O_RDWR);
     ba6:	4589                	li	a1,2
     ba8:	00005517          	auipc	a0,0x5
     bac:	17050513          	addi	a0,a0,368 # 5d18 <statistics+0x1ec>
     bb0:	00005097          	auipc	ra,0x5
     bb4:	aa2080e7          	jalr	-1374(ra) # 5652 <open>
     bb8:	84aa                	mv	s1,a0
  if(fd < 0){
     bba:	0c054863          	bltz	a0,c8a <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bbe:	00005517          	auipc	a0,0x5
     bc2:	15a50513          	addi	a0,a0,346 # 5d18 <statistics+0x1ec>
     bc6:	00005097          	auipc	ra,0x5
     bca:	a9c080e7          	jalr	-1380(ra) # 5662 <unlink>
     bce:	ed61                	bnez	a0,ca6 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd0:	20200593          	li	a1,514
     bd4:	00005517          	auipc	a0,0x5
     bd8:	14450513          	addi	a0,a0,324 # 5d18 <statistics+0x1ec>
     bdc:	00005097          	auipc	ra,0x5
     be0:	a76080e7          	jalr	-1418(ra) # 5652 <open>
     be4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     be6:	460d                	li	a2,3
     be8:	00006597          	auipc	a1,0x6
     bec:	84858593          	addi	a1,a1,-1976 # 6430 <statistics+0x904>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	a42080e7          	jalr	-1470(ra) # 5632 <write>
  close(fd1);
     bf8:	854a                	mv	a0,s2
     bfa:	00005097          	auipc	ra,0x5
     bfe:	a40080e7          	jalr	-1472(ra) # 563a <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c02:	660d                	lui	a2,0x3
     c04:	0000b597          	auipc	a1,0xb
     c08:	f4c58593          	addi	a1,a1,-180 # bb50 <buf>
     c0c:	8526                	mv	a0,s1
     c0e:	00005097          	auipc	ra,0x5
     c12:	a1c080e7          	jalr	-1508(ra) # 562a <read>
     c16:	4795                	li	a5,5
     c18:	0af51563          	bne	a0,a5,cc2 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c1c:	0000b717          	auipc	a4,0xb
     c20:	f3474703          	lbu	a4,-204(a4) # bb50 <buf>
     c24:	06800793          	li	a5,104
     c28:	0af71b63          	bne	a4,a5,cde <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c2c:	4629                	li	a2,10
     c2e:	0000b597          	auipc	a1,0xb
     c32:	f2258593          	addi	a1,a1,-222 # bb50 <buf>
     c36:	8526                	mv	a0,s1
     c38:	00005097          	auipc	ra,0x5
     c3c:	9fa080e7          	jalr	-1542(ra) # 5632 <write>
     c40:	47a9                	li	a5,10
     c42:	0af51c63          	bne	a0,a5,cfa <unlinkread+0x19a>
  close(fd);
     c46:	8526                	mv	a0,s1
     c48:	00005097          	auipc	ra,0x5
     c4c:	9f2080e7          	jalr	-1550(ra) # 563a <close>
  unlink("unlinkread");
     c50:	00005517          	auipc	a0,0x5
     c54:	0c850513          	addi	a0,a0,200 # 5d18 <statistics+0x1ec>
     c58:	00005097          	auipc	ra,0x5
     c5c:	a0a080e7          	jalr	-1526(ra) # 5662 <unlink>
}
     c60:	70a2                	ld	ra,40(sp)
     c62:	7402                	ld	s0,32(sp)
     c64:	64e2                	ld	s1,24(sp)
     c66:	6942                	ld	s2,16(sp)
     c68:	69a2                	ld	s3,8(sp)
     c6a:	6145                	addi	sp,sp,48
     c6c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c6e:	85ce                	mv	a1,s3
     c70:	00005517          	auipc	a0,0x5
     c74:	75850513          	addi	a0,a0,1880 # 63c8 <statistics+0x89c>
     c78:	00005097          	auipc	ra,0x5
     c7c:	d12080e7          	jalr	-750(ra) # 598a <printf>
    exit(1);
     c80:	4505                	li	a0,1
     c82:	00005097          	auipc	ra,0x5
     c86:	990080e7          	jalr	-1648(ra) # 5612 <exit>
    printf("%s: open unlinkread failed\n", s);
     c8a:	85ce                	mv	a1,s3
     c8c:	00005517          	auipc	a0,0x5
     c90:	76450513          	addi	a0,a0,1892 # 63f0 <statistics+0x8c4>
     c94:	00005097          	auipc	ra,0x5
     c98:	cf6080e7          	jalr	-778(ra) # 598a <printf>
    exit(1);
     c9c:	4505                	li	a0,1
     c9e:	00005097          	auipc	ra,0x5
     ca2:	974080e7          	jalr	-1676(ra) # 5612 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ca6:	85ce                	mv	a1,s3
     ca8:	00005517          	auipc	a0,0x5
     cac:	76850513          	addi	a0,a0,1896 # 6410 <statistics+0x8e4>
     cb0:	00005097          	auipc	ra,0x5
     cb4:	cda080e7          	jalr	-806(ra) # 598a <printf>
    exit(1);
     cb8:	4505                	li	a0,1
     cba:	00005097          	auipc	ra,0x5
     cbe:	958080e7          	jalr	-1704(ra) # 5612 <exit>
    printf("%s: unlinkread read failed", s);
     cc2:	85ce                	mv	a1,s3
     cc4:	00005517          	auipc	a0,0x5
     cc8:	77450513          	addi	a0,a0,1908 # 6438 <statistics+0x90c>
     ccc:	00005097          	auipc	ra,0x5
     cd0:	cbe080e7          	jalr	-834(ra) # 598a <printf>
    exit(1);
     cd4:	4505                	li	a0,1
     cd6:	00005097          	auipc	ra,0x5
     cda:	93c080e7          	jalr	-1732(ra) # 5612 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cde:	85ce                	mv	a1,s3
     ce0:	00005517          	auipc	a0,0x5
     ce4:	77850513          	addi	a0,a0,1912 # 6458 <statistics+0x92c>
     ce8:	00005097          	auipc	ra,0x5
     cec:	ca2080e7          	jalr	-862(ra) # 598a <printf>
    exit(1);
     cf0:	4505                	li	a0,1
     cf2:	00005097          	auipc	ra,0x5
     cf6:	920080e7          	jalr	-1760(ra) # 5612 <exit>
    printf("%s: unlinkread write failed\n", s);
     cfa:	85ce                	mv	a1,s3
     cfc:	00005517          	auipc	a0,0x5
     d00:	77c50513          	addi	a0,a0,1916 # 6478 <statistics+0x94c>
     d04:	00005097          	auipc	ra,0x5
     d08:	c86080e7          	jalr	-890(ra) # 598a <printf>
    exit(1);
     d0c:	4505                	li	a0,1
     d0e:	00005097          	auipc	ra,0x5
     d12:	904080e7          	jalr	-1788(ra) # 5612 <exit>

0000000000000d16 <linktest>:
{
     d16:	1101                	addi	sp,sp,-32
     d18:	ec06                	sd	ra,24(sp)
     d1a:	e822                	sd	s0,16(sp)
     d1c:	e426                	sd	s1,8(sp)
     d1e:	e04a                	sd	s2,0(sp)
     d20:	1000                	addi	s0,sp,32
     d22:	892a                	mv	s2,a0
  unlink("lf1");
     d24:	00005517          	auipc	a0,0x5
     d28:	77450513          	addi	a0,a0,1908 # 6498 <statistics+0x96c>
     d2c:	00005097          	auipc	ra,0x5
     d30:	936080e7          	jalr	-1738(ra) # 5662 <unlink>
  unlink("lf2");
     d34:	00005517          	auipc	a0,0x5
     d38:	76c50513          	addi	a0,a0,1900 # 64a0 <statistics+0x974>
     d3c:	00005097          	auipc	ra,0x5
     d40:	926080e7          	jalr	-1754(ra) # 5662 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d44:	20200593          	li	a1,514
     d48:	00005517          	auipc	a0,0x5
     d4c:	75050513          	addi	a0,a0,1872 # 6498 <statistics+0x96c>
     d50:	00005097          	auipc	ra,0x5
     d54:	902080e7          	jalr	-1790(ra) # 5652 <open>
  if(fd < 0){
     d58:	10054763          	bltz	a0,e66 <linktest+0x150>
     d5c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d5e:	4615                	li	a2,5
     d60:	00005597          	auipc	a1,0x5
     d64:	68858593          	addi	a1,a1,1672 # 63e8 <statistics+0x8bc>
     d68:	00005097          	auipc	ra,0x5
     d6c:	8ca080e7          	jalr	-1846(ra) # 5632 <write>
     d70:	4795                	li	a5,5
     d72:	10f51863          	bne	a0,a5,e82 <linktest+0x16c>
  close(fd);
     d76:	8526                	mv	a0,s1
     d78:	00005097          	auipc	ra,0x5
     d7c:	8c2080e7          	jalr	-1854(ra) # 563a <close>
  if(link("lf1", "lf2") < 0){
     d80:	00005597          	auipc	a1,0x5
     d84:	72058593          	addi	a1,a1,1824 # 64a0 <statistics+0x974>
     d88:	00005517          	auipc	a0,0x5
     d8c:	71050513          	addi	a0,a0,1808 # 6498 <statistics+0x96c>
     d90:	00005097          	auipc	ra,0x5
     d94:	8e2080e7          	jalr	-1822(ra) # 5672 <link>
     d98:	10054363          	bltz	a0,e9e <linktest+0x188>
  unlink("lf1");
     d9c:	00005517          	auipc	a0,0x5
     da0:	6fc50513          	addi	a0,a0,1788 # 6498 <statistics+0x96c>
     da4:	00005097          	auipc	ra,0x5
     da8:	8be080e7          	jalr	-1858(ra) # 5662 <unlink>
  if(open("lf1", 0) >= 0){
     dac:	4581                	li	a1,0
     dae:	00005517          	auipc	a0,0x5
     db2:	6ea50513          	addi	a0,a0,1770 # 6498 <statistics+0x96c>
     db6:	00005097          	auipc	ra,0x5
     dba:	89c080e7          	jalr	-1892(ra) # 5652 <open>
     dbe:	0e055e63          	bgez	a0,eba <linktest+0x1a4>
  fd = open("lf2", 0);
     dc2:	4581                	li	a1,0
     dc4:	00005517          	auipc	a0,0x5
     dc8:	6dc50513          	addi	a0,a0,1756 # 64a0 <statistics+0x974>
     dcc:	00005097          	auipc	ra,0x5
     dd0:	886080e7          	jalr	-1914(ra) # 5652 <open>
     dd4:	84aa                	mv	s1,a0
  if(fd < 0){
     dd6:	10054063          	bltz	a0,ed6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dda:	660d                	lui	a2,0x3
     ddc:	0000b597          	auipc	a1,0xb
     de0:	d7458593          	addi	a1,a1,-652 # bb50 <buf>
     de4:	00005097          	auipc	ra,0x5
     de8:	846080e7          	jalr	-1978(ra) # 562a <read>
     dec:	4795                	li	a5,5
     dee:	10f51263          	bne	a0,a5,ef2 <linktest+0x1dc>
  close(fd);
     df2:	8526                	mv	a0,s1
     df4:	00005097          	auipc	ra,0x5
     df8:	846080e7          	jalr	-1978(ra) # 563a <close>
  if(link("lf2", "lf2") >= 0){
     dfc:	00005597          	auipc	a1,0x5
     e00:	6a458593          	addi	a1,a1,1700 # 64a0 <statistics+0x974>
     e04:	852e                	mv	a0,a1
     e06:	00005097          	auipc	ra,0x5
     e0a:	86c080e7          	jalr	-1940(ra) # 5672 <link>
     e0e:	10055063          	bgez	a0,f0e <linktest+0x1f8>
  unlink("lf2");
     e12:	00005517          	auipc	a0,0x5
     e16:	68e50513          	addi	a0,a0,1678 # 64a0 <statistics+0x974>
     e1a:	00005097          	auipc	ra,0x5
     e1e:	848080e7          	jalr	-1976(ra) # 5662 <unlink>
  if(link("lf2", "lf1") >= 0){
     e22:	00005597          	auipc	a1,0x5
     e26:	67658593          	addi	a1,a1,1654 # 6498 <statistics+0x96c>
     e2a:	00005517          	auipc	a0,0x5
     e2e:	67650513          	addi	a0,a0,1654 # 64a0 <statistics+0x974>
     e32:	00005097          	auipc	ra,0x5
     e36:	840080e7          	jalr	-1984(ra) # 5672 <link>
     e3a:	0e055863          	bgez	a0,f2a <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e3e:	00005597          	auipc	a1,0x5
     e42:	65a58593          	addi	a1,a1,1626 # 6498 <statistics+0x96c>
     e46:	00005517          	auipc	a0,0x5
     e4a:	76250513          	addi	a0,a0,1890 # 65a8 <statistics+0xa7c>
     e4e:	00005097          	auipc	ra,0x5
     e52:	824080e7          	jalr	-2012(ra) # 5672 <link>
     e56:	0e055863          	bgez	a0,f46 <linktest+0x230>
}
     e5a:	60e2                	ld	ra,24(sp)
     e5c:	6442                	ld	s0,16(sp)
     e5e:	64a2                	ld	s1,8(sp)
     e60:	6902                	ld	s2,0(sp)
     e62:	6105                	addi	sp,sp,32
     e64:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e66:	85ca                	mv	a1,s2
     e68:	00005517          	auipc	a0,0x5
     e6c:	64050513          	addi	a0,a0,1600 # 64a8 <statistics+0x97c>
     e70:	00005097          	auipc	ra,0x5
     e74:	b1a080e7          	jalr	-1254(ra) # 598a <printf>
    exit(1);
     e78:	4505                	li	a0,1
     e7a:	00004097          	auipc	ra,0x4
     e7e:	798080e7          	jalr	1944(ra) # 5612 <exit>
    printf("%s: write lf1 failed\n", s);
     e82:	85ca                	mv	a1,s2
     e84:	00005517          	auipc	a0,0x5
     e88:	63c50513          	addi	a0,a0,1596 # 64c0 <statistics+0x994>
     e8c:	00005097          	auipc	ra,0x5
     e90:	afe080e7          	jalr	-1282(ra) # 598a <printf>
    exit(1);
     e94:	4505                	li	a0,1
     e96:	00004097          	auipc	ra,0x4
     e9a:	77c080e7          	jalr	1916(ra) # 5612 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     e9e:	85ca                	mv	a1,s2
     ea0:	00005517          	auipc	a0,0x5
     ea4:	63850513          	addi	a0,a0,1592 # 64d8 <statistics+0x9ac>
     ea8:	00005097          	auipc	ra,0x5
     eac:	ae2080e7          	jalr	-1310(ra) # 598a <printf>
    exit(1);
     eb0:	4505                	li	a0,1
     eb2:	00004097          	auipc	ra,0x4
     eb6:	760080e7          	jalr	1888(ra) # 5612 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     eba:	85ca                	mv	a1,s2
     ebc:	00005517          	auipc	a0,0x5
     ec0:	63c50513          	addi	a0,a0,1596 # 64f8 <statistics+0x9cc>
     ec4:	00005097          	auipc	ra,0x5
     ec8:	ac6080e7          	jalr	-1338(ra) # 598a <printf>
    exit(1);
     ecc:	4505                	li	a0,1
     ece:	00004097          	auipc	ra,0x4
     ed2:	744080e7          	jalr	1860(ra) # 5612 <exit>
    printf("%s: open lf2 failed\n", s);
     ed6:	85ca                	mv	a1,s2
     ed8:	00005517          	auipc	a0,0x5
     edc:	65050513          	addi	a0,a0,1616 # 6528 <statistics+0x9fc>
     ee0:	00005097          	auipc	ra,0x5
     ee4:	aaa080e7          	jalr	-1366(ra) # 598a <printf>
    exit(1);
     ee8:	4505                	li	a0,1
     eea:	00004097          	auipc	ra,0x4
     eee:	728080e7          	jalr	1832(ra) # 5612 <exit>
    printf("%s: read lf2 failed\n", s);
     ef2:	85ca                	mv	a1,s2
     ef4:	00005517          	auipc	a0,0x5
     ef8:	64c50513          	addi	a0,a0,1612 # 6540 <statistics+0xa14>
     efc:	00005097          	auipc	ra,0x5
     f00:	a8e080e7          	jalr	-1394(ra) # 598a <printf>
    exit(1);
     f04:	4505                	li	a0,1
     f06:	00004097          	auipc	ra,0x4
     f0a:	70c080e7          	jalr	1804(ra) # 5612 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f0e:	85ca                	mv	a1,s2
     f10:	00005517          	auipc	a0,0x5
     f14:	64850513          	addi	a0,a0,1608 # 6558 <statistics+0xa2c>
     f18:	00005097          	auipc	ra,0x5
     f1c:	a72080e7          	jalr	-1422(ra) # 598a <printf>
    exit(1);
     f20:	4505                	li	a0,1
     f22:	00004097          	auipc	ra,0x4
     f26:	6f0080e7          	jalr	1776(ra) # 5612 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f2a:	85ca                	mv	a1,s2
     f2c:	00005517          	auipc	a0,0x5
     f30:	65450513          	addi	a0,a0,1620 # 6580 <statistics+0xa54>
     f34:	00005097          	auipc	ra,0x5
     f38:	a56080e7          	jalr	-1450(ra) # 598a <printf>
    exit(1);
     f3c:	4505                	li	a0,1
     f3e:	00004097          	auipc	ra,0x4
     f42:	6d4080e7          	jalr	1748(ra) # 5612 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f46:	85ca                	mv	a1,s2
     f48:	00005517          	auipc	a0,0x5
     f4c:	66850513          	addi	a0,a0,1640 # 65b0 <statistics+0xa84>
     f50:	00005097          	auipc	ra,0x5
     f54:	a3a080e7          	jalr	-1478(ra) # 598a <printf>
    exit(1);
     f58:	4505                	li	a0,1
     f5a:	00004097          	auipc	ra,0x4
     f5e:	6b8080e7          	jalr	1720(ra) # 5612 <exit>

0000000000000f62 <bigdir>:
{
     f62:	715d                	addi	sp,sp,-80
     f64:	e486                	sd	ra,72(sp)
     f66:	e0a2                	sd	s0,64(sp)
     f68:	fc26                	sd	s1,56(sp)
     f6a:	f84a                	sd	s2,48(sp)
     f6c:	f44e                	sd	s3,40(sp)
     f6e:	f052                	sd	s4,32(sp)
     f70:	ec56                	sd	s5,24(sp)
     f72:	e85a                	sd	s6,16(sp)
     f74:	0880                	addi	s0,sp,80
     f76:	89aa                	mv	s3,a0
  unlink("bd");
     f78:	00005517          	auipc	a0,0x5
     f7c:	65850513          	addi	a0,a0,1624 # 65d0 <statistics+0xaa4>
     f80:	00004097          	auipc	ra,0x4
     f84:	6e2080e7          	jalr	1762(ra) # 5662 <unlink>
  fd = open("bd", O_CREATE);
     f88:	20000593          	li	a1,512
     f8c:	00005517          	auipc	a0,0x5
     f90:	64450513          	addi	a0,a0,1604 # 65d0 <statistics+0xaa4>
     f94:	00004097          	auipc	ra,0x4
     f98:	6be080e7          	jalr	1726(ra) # 5652 <open>
  if(fd < 0){
     f9c:	0c054963          	bltz	a0,106e <bigdir+0x10c>
  close(fd);
     fa0:	00004097          	auipc	ra,0x4
     fa4:	69a080e7          	jalr	1690(ra) # 563a <close>
  for(i = 0; i < N; i++){
     fa8:	4901                	li	s2,0
    name[0] = 'x';
     faa:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fae:	00005a17          	auipc	s4,0x5
     fb2:	622a0a13          	addi	s4,s4,1570 # 65d0 <statistics+0xaa4>
  for(i = 0; i < N; i++){
     fb6:	1f400b13          	li	s6,500
    name[0] = 'x';
     fba:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fbe:	41f9579b          	sraiw	a5,s2,0x1f
     fc2:	01a7d71b          	srliw	a4,a5,0x1a
     fc6:	012707bb          	addw	a5,a4,s2
     fca:	4067d69b          	sraiw	a3,a5,0x6
     fce:	0306869b          	addiw	a3,a3,48
     fd2:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fd6:	03f7f793          	andi	a5,a5,63
     fda:	9f99                	subw	a5,a5,a4
     fdc:	0307879b          	addiw	a5,a5,48
     fe0:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     fe4:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     fe8:	fb040593          	addi	a1,s0,-80
     fec:	8552                	mv	a0,s4
     fee:	00004097          	auipc	ra,0x4
     ff2:	684080e7          	jalr	1668(ra) # 5672 <link>
     ff6:	84aa                	mv	s1,a0
     ff8:	e949                	bnez	a0,108a <bigdir+0x128>
  for(i = 0; i < N; i++){
     ffa:	2905                	addiw	s2,s2,1
     ffc:	fb691fe3          	bne	s2,s6,fba <bigdir+0x58>
  unlink("bd");
    1000:	00005517          	auipc	a0,0x5
    1004:	5d050513          	addi	a0,a0,1488 # 65d0 <statistics+0xaa4>
    1008:	00004097          	auipc	ra,0x4
    100c:	65a080e7          	jalr	1626(ra) # 5662 <unlink>
    name[0] = 'x';
    1010:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1014:	1f400a13          	li	s4,500
    name[0] = 'x';
    1018:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    101c:	41f4d79b          	sraiw	a5,s1,0x1f
    1020:	01a7d71b          	srliw	a4,a5,0x1a
    1024:	009707bb          	addw	a5,a4,s1
    1028:	4067d69b          	sraiw	a3,a5,0x6
    102c:	0306869b          	addiw	a3,a3,48
    1030:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1034:	03f7f793          	andi	a5,a5,63
    1038:	9f99                	subw	a5,a5,a4
    103a:	0307879b          	addiw	a5,a5,48
    103e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1042:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1046:	fb040513          	addi	a0,s0,-80
    104a:	00004097          	auipc	ra,0x4
    104e:	618080e7          	jalr	1560(ra) # 5662 <unlink>
    1052:	ed21                	bnez	a0,10aa <bigdir+0x148>
  for(i = 0; i < N; i++){
    1054:	2485                	addiw	s1,s1,1
    1056:	fd4491e3          	bne	s1,s4,1018 <bigdir+0xb6>
}
    105a:	60a6                	ld	ra,72(sp)
    105c:	6406                	ld	s0,64(sp)
    105e:	74e2                	ld	s1,56(sp)
    1060:	7942                	ld	s2,48(sp)
    1062:	79a2                	ld	s3,40(sp)
    1064:	7a02                	ld	s4,32(sp)
    1066:	6ae2                	ld	s5,24(sp)
    1068:	6b42                	ld	s6,16(sp)
    106a:	6161                	addi	sp,sp,80
    106c:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    106e:	85ce                	mv	a1,s3
    1070:	00005517          	auipc	a0,0x5
    1074:	56850513          	addi	a0,a0,1384 # 65d8 <statistics+0xaac>
    1078:	00005097          	auipc	ra,0x5
    107c:	912080e7          	jalr	-1774(ra) # 598a <printf>
    exit(1);
    1080:	4505                	li	a0,1
    1082:	00004097          	auipc	ra,0x4
    1086:	590080e7          	jalr	1424(ra) # 5612 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    108a:	fb040613          	addi	a2,s0,-80
    108e:	85ce                	mv	a1,s3
    1090:	00005517          	auipc	a0,0x5
    1094:	56850513          	addi	a0,a0,1384 # 65f8 <statistics+0xacc>
    1098:	00005097          	auipc	ra,0x5
    109c:	8f2080e7          	jalr	-1806(ra) # 598a <printf>
      exit(1);
    10a0:	4505                	li	a0,1
    10a2:	00004097          	auipc	ra,0x4
    10a6:	570080e7          	jalr	1392(ra) # 5612 <exit>
      printf("%s: bigdir unlink failed", s);
    10aa:	85ce                	mv	a1,s3
    10ac:	00005517          	auipc	a0,0x5
    10b0:	56c50513          	addi	a0,a0,1388 # 6618 <statistics+0xaec>
    10b4:	00005097          	auipc	ra,0x5
    10b8:	8d6080e7          	jalr	-1834(ra) # 598a <printf>
      exit(1);
    10bc:	4505                	li	a0,1
    10be:	00004097          	auipc	ra,0x4
    10c2:	554080e7          	jalr	1364(ra) # 5612 <exit>

00000000000010c6 <validatetest>:
{
    10c6:	7139                	addi	sp,sp,-64
    10c8:	fc06                	sd	ra,56(sp)
    10ca:	f822                	sd	s0,48(sp)
    10cc:	f426                	sd	s1,40(sp)
    10ce:	f04a                	sd	s2,32(sp)
    10d0:	ec4e                	sd	s3,24(sp)
    10d2:	e852                	sd	s4,16(sp)
    10d4:	e456                	sd	s5,8(sp)
    10d6:	e05a                	sd	s6,0(sp)
    10d8:	0080                	addi	s0,sp,64
    10da:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10dc:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10de:	00005997          	auipc	s3,0x5
    10e2:	55a98993          	addi	s3,s3,1370 # 6638 <statistics+0xb0c>
    10e6:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10e8:	6a85                	lui	s5,0x1
    10ea:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    10ee:	85a6                	mv	a1,s1
    10f0:	854e                	mv	a0,s3
    10f2:	00004097          	auipc	ra,0x4
    10f6:	580080e7          	jalr	1408(ra) # 5672 <link>
    10fa:	01251f63          	bne	a0,s2,1118 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fe:	94d6                	add	s1,s1,s5
    1100:	ff4497e3          	bne	s1,s4,10ee <validatetest+0x28>
}
    1104:	70e2                	ld	ra,56(sp)
    1106:	7442                	ld	s0,48(sp)
    1108:	74a2                	ld	s1,40(sp)
    110a:	7902                	ld	s2,32(sp)
    110c:	69e2                	ld	s3,24(sp)
    110e:	6a42                	ld	s4,16(sp)
    1110:	6aa2                	ld	s5,8(sp)
    1112:	6b02                	ld	s6,0(sp)
    1114:	6121                	addi	sp,sp,64
    1116:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1118:	85da                	mv	a1,s6
    111a:	00005517          	auipc	a0,0x5
    111e:	52e50513          	addi	a0,a0,1326 # 6648 <statistics+0xb1c>
    1122:	00005097          	auipc	ra,0x5
    1126:	868080e7          	jalr	-1944(ra) # 598a <printf>
      exit(1);
    112a:	4505                	li	a0,1
    112c:	00004097          	auipc	ra,0x4
    1130:	4e6080e7          	jalr	1254(ra) # 5612 <exit>

0000000000001134 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1134:	7179                	addi	sp,sp,-48
    1136:	f406                	sd	ra,40(sp)
    1138:	f022                	sd	s0,32(sp)
    113a:	ec26                	sd	s1,24(sp)
    113c:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    113e:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1142:	00007497          	auipc	s1,0x7
    1146:	1de4b483          	ld	s1,478(s1) # 8320 <__SDATA_BEGIN__>
    114a:	fd840593          	addi	a1,s0,-40
    114e:	8526                	mv	a0,s1
    1150:	00004097          	auipc	ra,0x4
    1154:	4fa080e7          	jalr	1274(ra) # 564a <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1158:	8526                	mv	a0,s1
    115a:	00004097          	auipc	ra,0x4
    115e:	4c8080e7          	jalr	1224(ra) # 5622 <pipe>

  exit(0);
    1162:	4501                	li	a0,0
    1164:	00004097          	auipc	ra,0x4
    1168:	4ae080e7          	jalr	1198(ra) # 5612 <exit>

000000000000116c <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    116c:	7139                	addi	sp,sp,-64
    116e:	fc06                	sd	ra,56(sp)
    1170:	f822                	sd	s0,48(sp)
    1172:	f426                	sd	s1,40(sp)
    1174:	f04a                	sd	s2,32(sp)
    1176:	ec4e                	sd	s3,24(sp)
    1178:	0080                	addi	s0,sp,64
    117a:	64b1                	lui	s1,0xc
    117c:	35048493          	addi	s1,s1,848 # c350 <buf+0x800>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1180:	597d                	li	s2,-1
    1182:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1186:	00005997          	auipc	s3,0x5
    118a:	d8a98993          	addi	s3,s3,-630 # 5f10 <statistics+0x3e4>
    argv[0] = (char*)0xffffffff;
    118e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1192:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1196:	fc040593          	addi	a1,s0,-64
    119a:	854e                	mv	a0,s3
    119c:	00004097          	auipc	ra,0x4
    11a0:	4ae080e7          	jalr	1198(ra) # 564a <exec>
  for(int i = 0; i < 50000; i++){
    11a4:	34fd                	addiw	s1,s1,-1
    11a6:	f4e5                	bnez	s1,118e <badarg+0x22>
  }
  
  exit(0);
    11a8:	4501                	li	a0,0
    11aa:	00004097          	auipc	ra,0x4
    11ae:	468080e7          	jalr	1128(ra) # 5612 <exit>

00000000000011b2 <copyinstr2>:
{
    11b2:	7155                	addi	sp,sp,-208
    11b4:	e586                	sd	ra,200(sp)
    11b6:	e1a2                	sd	s0,192(sp)
    11b8:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ba:	f6840793          	addi	a5,s0,-152
    11be:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11c2:	07800713          	li	a4,120
    11c6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11ca:	0785                	addi	a5,a5,1
    11cc:	fed79de3          	bne	a5,a3,11c6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11d0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11d4:	f6840513          	addi	a0,s0,-152
    11d8:	00004097          	auipc	ra,0x4
    11dc:	48a080e7          	jalr	1162(ra) # 5662 <unlink>
  if(ret != -1){
    11e0:	57fd                	li	a5,-1
    11e2:	0ef51063          	bne	a0,a5,12c2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11e6:	20100593          	li	a1,513
    11ea:	f6840513          	addi	a0,s0,-152
    11ee:	00004097          	auipc	ra,0x4
    11f2:	464080e7          	jalr	1124(ra) # 5652 <open>
  if(fd != -1){
    11f6:	57fd                	li	a5,-1
    11f8:	0ef51563          	bne	a0,a5,12e2 <copyinstr2+0x130>
  ret = link(b, b);
    11fc:	f6840593          	addi	a1,s0,-152
    1200:	852e                	mv	a0,a1
    1202:	00004097          	auipc	ra,0x4
    1206:	470080e7          	jalr	1136(ra) # 5672 <link>
  if(ret != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51b63          	bne	a0,a5,1302 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1210:	00006797          	auipc	a5,0x6
    1214:	60878793          	addi	a5,a5,1544 # 7818 <statistics+0x1cec>
    1218:	f4f43c23          	sd	a5,-168(s0)
    121c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1220:	f5840593          	addi	a1,s0,-168
    1224:	f6840513          	addi	a0,s0,-152
    1228:	00004097          	auipc	ra,0x4
    122c:	422080e7          	jalr	1058(ra) # 564a <exec>
  if(ret != -1){
    1230:	57fd                	li	a5,-1
    1232:	0ef51963          	bne	a0,a5,1324 <copyinstr2+0x172>
  int pid = fork();
    1236:	00004097          	auipc	ra,0x4
    123a:	3d4080e7          	jalr	980(ra) # 560a <fork>
  if(pid < 0){
    123e:	10054363          	bltz	a0,1344 <copyinstr2+0x192>
  if(pid == 0){
    1242:	12051463          	bnez	a0,136a <copyinstr2+0x1b8>
    1246:	00007797          	auipc	a5,0x7
    124a:	1f278793          	addi	a5,a5,498 # 8438 <big.1268>
    124e:	00008697          	auipc	a3,0x8
    1252:	1ea68693          	addi	a3,a3,490 # 9438 <__global_pointer$+0x918>
      big[i] = 'x';
    1256:	07800713          	li	a4,120
    125a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    125e:	0785                	addi	a5,a5,1
    1260:	fed79de3          	bne	a5,a3,125a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1264:	00008797          	auipc	a5,0x8
    1268:	1c078a23          	sb	zero,468(a5) # 9438 <__global_pointer$+0x918>
    char *args2[] = { big, big, big, 0 };
    126c:	00007797          	auipc	a5,0x7
    1270:	c9c78793          	addi	a5,a5,-868 # 7f08 <statistics+0x23dc>
    1274:	6390                	ld	a2,0(a5)
    1276:	6794                	ld	a3,8(a5)
    1278:	6b98                	ld	a4,16(a5)
    127a:	6f9c                	ld	a5,24(a5)
    127c:	f2c43823          	sd	a2,-208(s0)
    1280:	f2d43c23          	sd	a3,-200(s0)
    1284:	f4e43023          	sd	a4,-192(s0)
    1288:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    128c:	f3040593          	addi	a1,s0,-208
    1290:	00005517          	auipc	a0,0x5
    1294:	c8050513          	addi	a0,a0,-896 # 5f10 <statistics+0x3e4>
    1298:	00004097          	auipc	ra,0x4
    129c:	3b2080e7          	jalr	946(ra) # 564a <exec>
    if(ret != -1){
    12a0:	57fd                	li	a5,-1
    12a2:	0af50e63          	beq	a0,a5,135e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12a6:	55fd                	li	a1,-1
    12a8:	00005517          	auipc	a0,0x5
    12ac:	44850513          	addi	a0,a0,1096 # 66f0 <statistics+0xbc4>
    12b0:	00004097          	auipc	ra,0x4
    12b4:	6da080e7          	jalr	1754(ra) # 598a <printf>
      exit(1);
    12b8:	4505                	li	a0,1
    12ba:	00004097          	auipc	ra,0x4
    12be:	358080e7          	jalr	856(ra) # 5612 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12c2:	862a                	mv	a2,a0
    12c4:	f6840593          	addi	a1,s0,-152
    12c8:	00005517          	auipc	a0,0x5
    12cc:	3a050513          	addi	a0,a0,928 # 6668 <statistics+0xb3c>
    12d0:	00004097          	auipc	ra,0x4
    12d4:	6ba080e7          	jalr	1722(ra) # 598a <printf>
    exit(1);
    12d8:	4505                	li	a0,1
    12da:	00004097          	auipc	ra,0x4
    12de:	338080e7          	jalr	824(ra) # 5612 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12e2:	862a                	mv	a2,a0
    12e4:	f6840593          	addi	a1,s0,-152
    12e8:	00005517          	auipc	a0,0x5
    12ec:	3a050513          	addi	a0,a0,928 # 6688 <statistics+0xb5c>
    12f0:	00004097          	auipc	ra,0x4
    12f4:	69a080e7          	jalr	1690(ra) # 598a <printf>
    exit(1);
    12f8:	4505                	li	a0,1
    12fa:	00004097          	auipc	ra,0x4
    12fe:	318080e7          	jalr	792(ra) # 5612 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1302:	86aa                	mv	a3,a0
    1304:	f6840613          	addi	a2,s0,-152
    1308:	85b2                	mv	a1,a2
    130a:	00005517          	auipc	a0,0x5
    130e:	39e50513          	addi	a0,a0,926 # 66a8 <statistics+0xb7c>
    1312:	00004097          	auipc	ra,0x4
    1316:	678080e7          	jalr	1656(ra) # 598a <printf>
    exit(1);
    131a:	4505                	li	a0,1
    131c:	00004097          	auipc	ra,0x4
    1320:	2f6080e7          	jalr	758(ra) # 5612 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1324:	567d                	li	a2,-1
    1326:	f6840593          	addi	a1,s0,-152
    132a:	00005517          	auipc	a0,0x5
    132e:	3a650513          	addi	a0,a0,934 # 66d0 <statistics+0xba4>
    1332:	00004097          	auipc	ra,0x4
    1336:	658080e7          	jalr	1624(ra) # 598a <printf>
    exit(1);
    133a:	4505                	li	a0,1
    133c:	00004097          	auipc	ra,0x4
    1340:	2d6080e7          	jalr	726(ra) # 5612 <exit>
    printf("fork failed\n");
    1344:	00006517          	auipc	a0,0x6
    1348:	80c50513          	addi	a0,a0,-2036 # 6b50 <statistics+0x1024>
    134c:	00004097          	auipc	ra,0x4
    1350:	63e080e7          	jalr	1598(ra) # 598a <printf>
    exit(1);
    1354:	4505                	li	a0,1
    1356:	00004097          	auipc	ra,0x4
    135a:	2bc080e7          	jalr	700(ra) # 5612 <exit>
    exit(747); // OK
    135e:	2eb00513          	li	a0,747
    1362:	00004097          	auipc	ra,0x4
    1366:	2b0080e7          	jalr	688(ra) # 5612 <exit>
  int st = 0;
    136a:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    136e:	f5440513          	addi	a0,s0,-172
    1372:	00004097          	auipc	ra,0x4
    1376:	2a8080e7          	jalr	680(ra) # 561a <wait>
  if(st != 747){
    137a:	f5442703          	lw	a4,-172(s0)
    137e:	2eb00793          	li	a5,747
    1382:	00f71663          	bne	a4,a5,138e <copyinstr2+0x1dc>
}
    1386:	60ae                	ld	ra,200(sp)
    1388:	640e                	ld	s0,192(sp)
    138a:	6169                	addi	sp,sp,208
    138c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    138e:	00005517          	auipc	a0,0x5
    1392:	38a50513          	addi	a0,a0,906 # 6718 <statistics+0xbec>
    1396:	00004097          	auipc	ra,0x4
    139a:	5f4080e7          	jalr	1524(ra) # 598a <printf>
    exit(1);
    139e:	4505                	li	a0,1
    13a0:	00004097          	auipc	ra,0x4
    13a4:	272080e7          	jalr	626(ra) # 5612 <exit>

00000000000013a8 <truncate3>:
{
    13a8:	7159                	addi	sp,sp,-112
    13aa:	f486                	sd	ra,104(sp)
    13ac:	f0a2                	sd	s0,96(sp)
    13ae:	eca6                	sd	s1,88(sp)
    13b0:	e8ca                	sd	s2,80(sp)
    13b2:	e4ce                	sd	s3,72(sp)
    13b4:	e0d2                	sd	s4,64(sp)
    13b6:	fc56                	sd	s5,56(sp)
    13b8:	1880                	addi	s0,sp,112
    13ba:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13bc:	60100593          	li	a1,1537
    13c0:	00005517          	auipc	a0,0x5
    13c4:	ba850513          	addi	a0,a0,-1112 # 5f68 <statistics+0x43c>
    13c8:	00004097          	auipc	ra,0x4
    13cc:	28a080e7          	jalr	650(ra) # 5652 <open>
    13d0:	00004097          	auipc	ra,0x4
    13d4:	26a080e7          	jalr	618(ra) # 563a <close>
  pid = fork();
    13d8:	00004097          	auipc	ra,0x4
    13dc:	232080e7          	jalr	562(ra) # 560a <fork>
  if(pid < 0){
    13e0:	08054063          	bltz	a0,1460 <truncate3+0xb8>
  if(pid == 0){
    13e4:	e969                	bnez	a0,14b6 <truncate3+0x10e>
    13e6:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13ea:	00005a17          	auipc	s4,0x5
    13ee:	b7ea0a13          	addi	s4,s4,-1154 # 5f68 <statistics+0x43c>
      int n = write(fd, "1234567890", 10);
    13f2:	00005a97          	auipc	s5,0x5
    13f6:	386a8a93          	addi	s5,s5,902 # 6778 <statistics+0xc4c>
      int fd = open("truncfile", O_WRONLY);
    13fa:	4585                	li	a1,1
    13fc:	8552                	mv	a0,s4
    13fe:	00004097          	auipc	ra,0x4
    1402:	254080e7          	jalr	596(ra) # 5652 <open>
    1406:	84aa                	mv	s1,a0
      if(fd < 0){
    1408:	06054a63          	bltz	a0,147c <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    140c:	4629                	li	a2,10
    140e:	85d6                	mv	a1,s5
    1410:	00004097          	auipc	ra,0x4
    1414:	222080e7          	jalr	546(ra) # 5632 <write>
      if(n != 10){
    1418:	47a9                	li	a5,10
    141a:	06f51f63          	bne	a0,a5,1498 <truncate3+0xf0>
      close(fd);
    141e:	8526                	mv	a0,s1
    1420:	00004097          	auipc	ra,0x4
    1424:	21a080e7          	jalr	538(ra) # 563a <close>
      fd = open("truncfile", O_RDONLY);
    1428:	4581                	li	a1,0
    142a:	8552                	mv	a0,s4
    142c:	00004097          	auipc	ra,0x4
    1430:	226080e7          	jalr	550(ra) # 5652 <open>
    1434:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1436:	02000613          	li	a2,32
    143a:	f9840593          	addi	a1,s0,-104
    143e:	00004097          	auipc	ra,0x4
    1442:	1ec080e7          	jalr	492(ra) # 562a <read>
      close(fd);
    1446:	8526                	mv	a0,s1
    1448:	00004097          	auipc	ra,0x4
    144c:	1f2080e7          	jalr	498(ra) # 563a <close>
    for(int i = 0; i < 100; i++){
    1450:	39fd                	addiw	s3,s3,-1
    1452:	fa0994e3          	bnez	s3,13fa <truncate3+0x52>
    exit(0);
    1456:	4501                	li	a0,0
    1458:	00004097          	auipc	ra,0x4
    145c:	1ba080e7          	jalr	442(ra) # 5612 <exit>
    printf("%s: fork failed\n", s);
    1460:	85ca                	mv	a1,s2
    1462:	00005517          	auipc	a0,0x5
    1466:	2e650513          	addi	a0,a0,742 # 6748 <statistics+0xc1c>
    146a:	00004097          	auipc	ra,0x4
    146e:	520080e7          	jalr	1312(ra) # 598a <printf>
    exit(1);
    1472:	4505                	li	a0,1
    1474:	00004097          	auipc	ra,0x4
    1478:	19e080e7          	jalr	414(ra) # 5612 <exit>
        printf("%s: open failed\n", s);
    147c:	85ca                	mv	a1,s2
    147e:	00005517          	auipc	a0,0x5
    1482:	2e250513          	addi	a0,a0,738 # 6760 <statistics+0xc34>
    1486:	00004097          	auipc	ra,0x4
    148a:	504080e7          	jalr	1284(ra) # 598a <printf>
        exit(1);
    148e:	4505                	li	a0,1
    1490:	00004097          	auipc	ra,0x4
    1494:	182080e7          	jalr	386(ra) # 5612 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1498:	862a                	mv	a2,a0
    149a:	85ca                	mv	a1,s2
    149c:	00005517          	auipc	a0,0x5
    14a0:	2ec50513          	addi	a0,a0,748 # 6788 <statistics+0xc5c>
    14a4:	00004097          	auipc	ra,0x4
    14a8:	4e6080e7          	jalr	1254(ra) # 598a <printf>
        exit(1);
    14ac:	4505                	li	a0,1
    14ae:	00004097          	auipc	ra,0x4
    14b2:	164080e7          	jalr	356(ra) # 5612 <exit>
    14b6:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ba:	00005a17          	auipc	s4,0x5
    14be:	aaea0a13          	addi	s4,s4,-1362 # 5f68 <statistics+0x43c>
    int n = write(fd, "xxx", 3);
    14c2:	00005a97          	auipc	s5,0x5
    14c6:	2e6a8a93          	addi	s5,s5,742 # 67a8 <statistics+0xc7c>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ca:	60100593          	li	a1,1537
    14ce:	8552                	mv	a0,s4
    14d0:	00004097          	auipc	ra,0x4
    14d4:	182080e7          	jalr	386(ra) # 5652 <open>
    14d8:	84aa                	mv	s1,a0
    if(fd < 0){
    14da:	04054763          	bltz	a0,1528 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14de:	460d                	li	a2,3
    14e0:	85d6                	mv	a1,s5
    14e2:	00004097          	auipc	ra,0x4
    14e6:	150080e7          	jalr	336(ra) # 5632 <write>
    if(n != 3){
    14ea:	478d                	li	a5,3
    14ec:	04f51c63          	bne	a0,a5,1544 <truncate3+0x19c>
    close(fd);
    14f0:	8526                	mv	a0,s1
    14f2:	00004097          	auipc	ra,0x4
    14f6:	148080e7          	jalr	328(ra) # 563a <close>
  for(int i = 0; i < 150; i++){
    14fa:	39fd                	addiw	s3,s3,-1
    14fc:	fc0997e3          	bnez	s3,14ca <truncate3+0x122>
  wait(&xstatus);
    1500:	fbc40513          	addi	a0,s0,-68
    1504:	00004097          	auipc	ra,0x4
    1508:	116080e7          	jalr	278(ra) # 561a <wait>
  unlink("truncfile");
    150c:	00005517          	auipc	a0,0x5
    1510:	a5c50513          	addi	a0,a0,-1444 # 5f68 <statistics+0x43c>
    1514:	00004097          	auipc	ra,0x4
    1518:	14e080e7          	jalr	334(ra) # 5662 <unlink>
  exit(xstatus);
    151c:	fbc42503          	lw	a0,-68(s0)
    1520:	00004097          	auipc	ra,0x4
    1524:	0f2080e7          	jalr	242(ra) # 5612 <exit>
      printf("%s: open failed\n", s);
    1528:	85ca                	mv	a1,s2
    152a:	00005517          	auipc	a0,0x5
    152e:	23650513          	addi	a0,a0,566 # 6760 <statistics+0xc34>
    1532:	00004097          	auipc	ra,0x4
    1536:	458080e7          	jalr	1112(ra) # 598a <printf>
      exit(1);
    153a:	4505                	li	a0,1
    153c:	00004097          	auipc	ra,0x4
    1540:	0d6080e7          	jalr	214(ra) # 5612 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1544:	862a                	mv	a2,a0
    1546:	85ca                	mv	a1,s2
    1548:	00005517          	auipc	a0,0x5
    154c:	26850513          	addi	a0,a0,616 # 67b0 <statistics+0xc84>
    1550:	00004097          	auipc	ra,0x4
    1554:	43a080e7          	jalr	1082(ra) # 598a <printf>
      exit(1);
    1558:	4505                	li	a0,1
    155a:	00004097          	auipc	ra,0x4
    155e:	0b8080e7          	jalr	184(ra) # 5612 <exit>

0000000000001562 <exectest>:
{
    1562:	715d                	addi	sp,sp,-80
    1564:	e486                	sd	ra,72(sp)
    1566:	e0a2                	sd	s0,64(sp)
    1568:	fc26                	sd	s1,56(sp)
    156a:	f84a                	sd	s2,48(sp)
    156c:	0880                	addi	s0,sp,80
    156e:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1570:	00005797          	auipc	a5,0x5
    1574:	9a078793          	addi	a5,a5,-1632 # 5f10 <statistics+0x3e4>
    1578:	fcf43023          	sd	a5,-64(s0)
    157c:	00005797          	auipc	a5,0x5
    1580:	25478793          	addi	a5,a5,596 # 67d0 <statistics+0xca4>
    1584:	fcf43423          	sd	a5,-56(s0)
    1588:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    158c:	00005517          	auipc	a0,0x5
    1590:	24c50513          	addi	a0,a0,588 # 67d8 <statistics+0xcac>
    1594:	00004097          	auipc	ra,0x4
    1598:	0ce080e7          	jalr	206(ra) # 5662 <unlink>
  pid = fork();
    159c:	00004097          	auipc	ra,0x4
    15a0:	06e080e7          	jalr	110(ra) # 560a <fork>
  if(pid < 0) {
    15a4:	04054663          	bltz	a0,15f0 <exectest+0x8e>
    15a8:	84aa                	mv	s1,a0
  if(pid == 0) {
    15aa:	e959                	bnez	a0,1640 <exectest+0xde>
    close(1);
    15ac:	4505                	li	a0,1
    15ae:	00004097          	auipc	ra,0x4
    15b2:	08c080e7          	jalr	140(ra) # 563a <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15b6:	20100593          	li	a1,513
    15ba:	00005517          	auipc	a0,0x5
    15be:	21e50513          	addi	a0,a0,542 # 67d8 <statistics+0xcac>
    15c2:	00004097          	auipc	ra,0x4
    15c6:	090080e7          	jalr	144(ra) # 5652 <open>
    if(fd < 0) {
    15ca:	04054163          	bltz	a0,160c <exectest+0xaa>
    if(fd != 1) {
    15ce:	4785                	li	a5,1
    15d0:	04f50c63          	beq	a0,a5,1628 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15d4:	85ca                	mv	a1,s2
    15d6:	00005517          	auipc	a0,0x5
    15da:	22250513          	addi	a0,a0,546 # 67f8 <statistics+0xccc>
    15de:	00004097          	auipc	ra,0x4
    15e2:	3ac080e7          	jalr	940(ra) # 598a <printf>
      exit(1);
    15e6:	4505                	li	a0,1
    15e8:	00004097          	auipc	ra,0x4
    15ec:	02a080e7          	jalr	42(ra) # 5612 <exit>
     printf("%s: fork failed\n", s);
    15f0:	85ca                	mv	a1,s2
    15f2:	00005517          	auipc	a0,0x5
    15f6:	15650513          	addi	a0,a0,342 # 6748 <statistics+0xc1c>
    15fa:	00004097          	auipc	ra,0x4
    15fe:	390080e7          	jalr	912(ra) # 598a <printf>
     exit(1);
    1602:	4505                	li	a0,1
    1604:	00004097          	auipc	ra,0x4
    1608:	00e080e7          	jalr	14(ra) # 5612 <exit>
      printf("%s: create failed\n", s);
    160c:	85ca                	mv	a1,s2
    160e:	00005517          	auipc	a0,0x5
    1612:	1d250513          	addi	a0,a0,466 # 67e0 <statistics+0xcb4>
    1616:	00004097          	auipc	ra,0x4
    161a:	374080e7          	jalr	884(ra) # 598a <printf>
      exit(1);
    161e:	4505                	li	a0,1
    1620:	00004097          	auipc	ra,0x4
    1624:	ff2080e7          	jalr	-14(ra) # 5612 <exit>
    if(exec("echo", echoargv) < 0){
    1628:	fc040593          	addi	a1,s0,-64
    162c:	00005517          	auipc	a0,0x5
    1630:	8e450513          	addi	a0,a0,-1820 # 5f10 <statistics+0x3e4>
    1634:	00004097          	auipc	ra,0x4
    1638:	016080e7          	jalr	22(ra) # 564a <exec>
    163c:	02054163          	bltz	a0,165e <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1640:	fdc40513          	addi	a0,s0,-36
    1644:	00004097          	auipc	ra,0x4
    1648:	fd6080e7          	jalr	-42(ra) # 561a <wait>
    164c:	02951763          	bne	a0,s1,167a <exectest+0x118>
  if(xstatus != 0)
    1650:	fdc42503          	lw	a0,-36(s0)
    1654:	cd0d                	beqz	a0,168e <exectest+0x12c>
    exit(xstatus);
    1656:	00004097          	auipc	ra,0x4
    165a:	fbc080e7          	jalr	-68(ra) # 5612 <exit>
      printf("%s: exec echo failed\n", s);
    165e:	85ca                	mv	a1,s2
    1660:	00005517          	auipc	a0,0x5
    1664:	1a850513          	addi	a0,a0,424 # 6808 <statistics+0xcdc>
    1668:	00004097          	auipc	ra,0x4
    166c:	322080e7          	jalr	802(ra) # 598a <printf>
      exit(1);
    1670:	4505                	li	a0,1
    1672:	00004097          	auipc	ra,0x4
    1676:	fa0080e7          	jalr	-96(ra) # 5612 <exit>
    printf("%s: wait failed!\n", s);
    167a:	85ca                	mv	a1,s2
    167c:	00005517          	auipc	a0,0x5
    1680:	1a450513          	addi	a0,a0,420 # 6820 <statistics+0xcf4>
    1684:	00004097          	auipc	ra,0x4
    1688:	306080e7          	jalr	774(ra) # 598a <printf>
    168c:	b7d1                	j	1650 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    168e:	4581                	li	a1,0
    1690:	00005517          	auipc	a0,0x5
    1694:	14850513          	addi	a0,a0,328 # 67d8 <statistics+0xcac>
    1698:	00004097          	auipc	ra,0x4
    169c:	fba080e7          	jalr	-70(ra) # 5652 <open>
  if(fd < 0) {
    16a0:	02054a63          	bltz	a0,16d4 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16a4:	4609                	li	a2,2
    16a6:	fb840593          	addi	a1,s0,-72
    16aa:	00004097          	auipc	ra,0x4
    16ae:	f80080e7          	jalr	-128(ra) # 562a <read>
    16b2:	4789                	li	a5,2
    16b4:	02f50e63          	beq	a0,a5,16f0 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16b8:	85ca                	mv	a1,s2
    16ba:	00005517          	auipc	a0,0x5
    16be:	be650513          	addi	a0,a0,-1050 # 62a0 <statistics+0x774>
    16c2:	00004097          	auipc	ra,0x4
    16c6:	2c8080e7          	jalr	712(ra) # 598a <printf>
    exit(1);
    16ca:	4505                	li	a0,1
    16cc:	00004097          	auipc	ra,0x4
    16d0:	f46080e7          	jalr	-186(ra) # 5612 <exit>
    printf("%s: open failed\n", s);
    16d4:	85ca                	mv	a1,s2
    16d6:	00005517          	auipc	a0,0x5
    16da:	08a50513          	addi	a0,a0,138 # 6760 <statistics+0xc34>
    16de:	00004097          	auipc	ra,0x4
    16e2:	2ac080e7          	jalr	684(ra) # 598a <printf>
    exit(1);
    16e6:	4505                	li	a0,1
    16e8:	00004097          	auipc	ra,0x4
    16ec:	f2a080e7          	jalr	-214(ra) # 5612 <exit>
  unlink("echo-ok");
    16f0:	00005517          	auipc	a0,0x5
    16f4:	0e850513          	addi	a0,a0,232 # 67d8 <statistics+0xcac>
    16f8:	00004097          	auipc	ra,0x4
    16fc:	f6a080e7          	jalr	-150(ra) # 5662 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1700:	fb844703          	lbu	a4,-72(s0)
    1704:	04f00793          	li	a5,79
    1708:	00f71863          	bne	a4,a5,1718 <exectest+0x1b6>
    170c:	fb944703          	lbu	a4,-71(s0)
    1710:	04b00793          	li	a5,75
    1714:	02f70063          	beq	a4,a5,1734 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1718:	85ca                	mv	a1,s2
    171a:	00005517          	auipc	a0,0x5
    171e:	11e50513          	addi	a0,a0,286 # 6838 <statistics+0xd0c>
    1722:	00004097          	auipc	ra,0x4
    1726:	268080e7          	jalr	616(ra) # 598a <printf>
    exit(1);
    172a:	4505                	li	a0,1
    172c:	00004097          	auipc	ra,0x4
    1730:	ee6080e7          	jalr	-282(ra) # 5612 <exit>
    exit(0);
    1734:	4501                	li	a0,0
    1736:	00004097          	auipc	ra,0x4
    173a:	edc080e7          	jalr	-292(ra) # 5612 <exit>

000000000000173e <pipe1>:
{
    173e:	711d                	addi	sp,sp,-96
    1740:	ec86                	sd	ra,88(sp)
    1742:	e8a2                	sd	s0,80(sp)
    1744:	e4a6                	sd	s1,72(sp)
    1746:	e0ca                	sd	s2,64(sp)
    1748:	fc4e                	sd	s3,56(sp)
    174a:	f852                	sd	s4,48(sp)
    174c:	f456                	sd	s5,40(sp)
    174e:	f05a                	sd	s6,32(sp)
    1750:	ec5e                	sd	s7,24(sp)
    1752:	1080                	addi	s0,sp,96
    1754:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1756:	fa840513          	addi	a0,s0,-88
    175a:	00004097          	auipc	ra,0x4
    175e:	ec8080e7          	jalr	-312(ra) # 5622 <pipe>
    1762:	ed25                	bnez	a0,17da <pipe1+0x9c>
    1764:	84aa                	mv	s1,a0
  pid = fork();
    1766:	00004097          	auipc	ra,0x4
    176a:	ea4080e7          	jalr	-348(ra) # 560a <fork>
    176e:	8a2a                	mv	s4,a0
  if(pid == 0){
    1770:	c159                	beqz	a0,17f6 <pipe1+0xb8>
  } else if(pid > 0){
    1772:	16a05e63          	blez	a0,18ee <pipe1+0x1b0>
    close(fds[1]);
    1776:	fac42503          	lw	a0,-84(s0)
    177a:	00004097          	auipc	ra,0x4
    177e:	ec0080e7          	jalr	-320(ra) # 563a <close>
    total = 0;
    1782:	8a26                	mv	s4,s1
    cc = 1;
    1784:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1786:	0000aa97          	auipc	s5,0xa
    178a:	3caa8a93          	addi	s5,s5,970 # bb50 <buf>
      if(cc > sizeof(buf))
    178e:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1790:	864e                	mv	a2,s3
    1792:	85d6                	mv	a1,s5
    1794:	fa842503          	lw	a0,-88(s0)
    1798:	00004097          	auipc	ra,0x4
    179c:	e92080e7          	jalr	-366(ra) # 562a <read>
    17a0:	10a05263          	blez	a0,18a4 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17a4:	0000a717          	auipc	a4,0xa
    17a8:	3ac70713          	addi	a4,a4,940 # bb50 <buf>
    17ac:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b0:	00074683          	lbu	a3,0(a4)
    17b4:	0ff4f793          	andi	a5,s1,255
    17b8:	2485                	addiw	s1,s1,1
    17ba:	0cf69163          	bne	a3,a5,187c <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17be:	0705                	addi	a4,a4,1
    17c0:	fec498e3          	bne	s1,a2,17b0 <pipe1+0x72>
      total += n;
    17c4:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17c8:	0019979b          	slliw	a5,s3,0x1
    17cc:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17d0:	013b7363          	bgeu	s6,s3,17d6 <pipe1+0x98>
        cc = sizeof(buf);
    17d4:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17d6:	84b2                	mv	s1,a2
    17d8:	bf65                	j	1790 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17da:	85ca                	mv	a1,s2
    17dc:	00005517          	auipc	a0,0x5
    17e0:	07450513          	addi	a0,a0,116 # 6850 <statistics+0xd24>
    17e4:	00004097          	auipc	ra,0x4
    17e8:	1a6080e7          	jalr	422(ra) # 598a <printf>
    exit(1);
    17ec:	4505                	li	a0,1
    17ee:	00004097          	auipc	ra,0x4
    17f2:	e24080e7          	jalr	-476(ra) # 5612 <exit>
    close(fds[0]);
    17f6:	fa842503          	lw	a0,-88(s0)
    17fa:	00004097          	auipc	ra,0x4
    17fe:	e40080e7          	jalr	-448(ra) # 563a <close>
    for(n = 0; n < N; n++){
    1802:	0000ab17          	auipc	s6,0xa
    1806:	34eb0b13          	addi	s6,s6,846 # bb50 <buf>
    180a:	416004bb          	negw	s1,s6
    180e:	0ff4f493          	andi	s1,s1,255
    1812:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1816:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1818:	6a85                	lui	s5,0x1
    181a:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x85>
{
    181e:	87da                	mv	a5,s6
        buf[i] = seq++;
    1820:	0097873b          	addw	a4,a5,s1
    1824:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1828:	0785                	addi	a5,a5,1
    182a:	fef99be3          	bne	s3,a5,1820 <pipe1+0xe2>
    182e:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1832:	40900613          	li	a2,1033
    1836:	85de                	mv	a1,s7
    1838:	fac42503          	lw	a0,-84(s0)
    183c:	00004097          	auipc	ra,0x4
    1840:	df6080e7          	jalr	-522(ra) # 5632 <write>
    1844:	40900793          	li	a5,1033
    1848:	00f51c63          	bne	a0,a5,1860 <pipe1+0x122>
    for(n = 0; n < N; n++){
    184c:	24a5                	addiw	s1,s1,9
    184e:	0ff4f493          	andi	s1,s1,255
    1852:	fd5a16e3          	bne	s4,s5,181e <pipe1+0xe0>
    exit(0);
    1856:	4501                	li	a0,0
    1858:	00004097          	auipc	ra,0x4
    185c:	dba080e7          	jalr	-582(ra) # 5612 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1860:	85ca                	mv	a1,s2
    1862:	00005517          	auipc	a0,0x5
    1866:	00650513          	addi	a0,a0,6 # 6868 <statistics+0xd3c>
    186a:	00004097          	auipc	ra,0x4
    186e:	120080e7          	jalr	288(ra) # 598a <printf>
        exit(1);
    1872:	4505                	li	a0,1
    1874:	00004097          	auipc	ra,0x4
    1878:	d9e080e7          	jalr	-610(ra) # 5612 <exit>
          printf("%s: pipe1 oops 2\n", s);
    187c:	85ca                	mv	a1,s2
    187e:	00005517          	auipc	a0,0x5
    1882:	00250513          	addi	a0,a0,2 # 6880 <statistics+0xd54>
    1886:	00004097          	auipc	ra,0x4
    188a:	104080e7          	jalr	260(ra) # 598a <printf>
}
    188e:	60e6                	ld	ra,88(sp)
    1890:	6446                	ld	s0,80(sp)
    1892:	64a6                	ld	s1,72(sp)
    1894:	6906                	ld	s2,64(sp)
    1896:	79e2                	ld	s3,56(sp)
    1898:	7a42                	ld	s4,48(sp)
    189a:	7aa2                	ld	s5,40(sp)
    189c:	7b02                	ld	s6,32(sp)
    189e:	6be2                	ld	s7,24(sp)
    18a0:	6125                	addi	sp,sp,96
    18a2:	8082                	ret
    if(total != N * SZ){
    18a4:	6785                	lui	a5,0x1
    18a6:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x85>
    18aa:	02fa0063          	beq	s4,a5,18ca <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18ae:	85d2                	mv	a1,s4
    18b0:	00005517          	auipc	a0,0x5
    18b4:	fe850513          	addi	a0,a0,-24 # 6898 <statistics+0xd6c>
    18b8:	00004097          	auipc	ra,0x4
    18bc:	0d2080e7          	jalr	210(ra) # 598a <printf>
      exit(1);
    18c0:	4505                	li	a0,1
    18c2:	00004097          	auipc	ra,0x4
    18c6:	d50080e7          	jalr	-688(ra) # 5612 <exit>
    close(fds[0]);
    18ca:	fa842503          	lw	a0,-88(s0)
    18ce:	00004097          	auipc	ra,0x4
    18d2:	d6c080e7          	jalr	-660(ra) # 563a <close>
    wait(&xstatus);
    18d6:	fa440513          	addi	a0,s0,-92
    18da:	00004097          	auipc	ra,0x4
    18de:	d40080e7          	jalr	-704(ra) # 561a <wait>
    exit(xstatus);
    18e2:	fa442503          	lw	a0,-92(s0)
    18e6:	00004097          	auipc	ra,0x4
    18ea:	d2c080e7          	jalr	-724(ra) # 5612 <exit>
    printf("%s: fork() failed\n", s);
    18ee:	85ca                	mv	a1,s2
    18f0:	00005517          	auipc	a0,0x5
    18f4:	fc850513          	addi	a0,a0,-56 # 68b8 <statistics+0xd8c>
    18f8:	00004097          	auipc	ra,0x4
    18fc:	092080e7          	jalr	146(ra) # 598a <printf>
    exit(1);
    1900:	4505                	li	a0,1
    1902:	00004097          	auipc	ra,0x4
    1906:	d10080e7          	jalr	-752(ra) # 5612 <exit>

000000000000190a <exitwait>:
{
    190a:	7139                	addi	sp,sp,-64
    190c:	fc06                	sd	ra,56(sp)
    190e:	f822                	sd	s0,48(sp)
    1910:	f426                	sd	s1,40(sp)
    1912:	f04a                	sd	s2,32(sp)
    1914:	ec4e                	sd	s3,24(sp)
    1916:	e852                	sd	s4,16(sp)
    1918:	0080                	addi	s0,sp,64
    191a:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    191c:	4901                	li	s2,0
    191e:	06400993          	li	s3,100
    pid = fork();
    1922:	00004097          	auipc	ra,0x4
    1926:	ce8080e7          	jalr	-792(ra) # 560a <fork>
    192a:	84aa                	mv	s1,a0
    if(pid < 0){
    192c:	02054a63          	bltz	a0,1960 <exitwait+0x56>
    if(pid){
    1930:	c151                	beqz	a0,19b4 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1932:	fcc40513          	addi	a0,s0,-52
    1936:	00004097          	auipc	ra,0x4
    193a:	ce4080e7          	jalr	-796(ra) # 561a <wait>
    193e:	02951f63          	bne	a0,s1,197c <exitwait+0x72>
      if(i != xstate) {
    1942:	fcc42783          	lw	a5,-52(s0)
    1946:	05279963          	bne	a5,s2,1998 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    194a:	2905                	addiw	s2,s2,1
    194c:	fd391be3          	bne	s2,s3,1922 <exitwait+0x18>
}
    1950:	70e2                	ld	ra,56(sp)
    1952:	7442                	ld	s0,48(sp)
    1954:	74a2                	ld	s1,40(sp)
    1956:	7902                	ld	s2,32(sp)
    1958:	69e2                	ld	s3,24(sp)
    195a:	6a42                	ld	s4,16(sp)
    195c:	6121                	addi	sp,sp,64
    195e:	8082                	ret
      printf("%s: fork failed\n", s);
    1960:	85d2                	mv	a1,s4
    1962:	00005517          	auipc	a0,0x5
    1966:	de650513          	addi	a0,a0,-538 # 6748 <statistics+0xc1c>
    196a:	00004097          	auipc	ra,0x4
    196e:	020080e7          	jalr	32(ra) # 598a <printf>
      exit(1);
    1972:	4505                	li	a0,1
    1974:	00004097          	auipc	ra,0x4
    1978:	c9e080e7          	jalr	-866(ra) # 5612 <exit>
        printf("%s: wait wrong pid\n", s);
    197c:	85d2                	mv	a1,s4
    197e:	00005517          	auipc	a0,0x5
    1982:	f5250513          	addi	a0,a0,-174 # 68d0 <statistics+0xda4>
    1986:	00004097          	auipc	ra,0x4
    198a:	004080e7          	jalr	4(ra) # 598a <printf>
        exit(1);
    198e:	4505                	li	a0,1
    1990:	00004097          	auipc	ra,0x4
    1994:	c82080e7          	jalr	-894(ra) # 5612 <exit>
        printf("%s: wait wrong exit status\n", s);
    1998:	85d2                	mv	a1,s4
    199a:	00005517          	auipc	a0,0x5
    199e:	f4e50513          	addi	a0,a0,-178 # 68e8 <statistics+0xdbc>
    19a2:	00004097          	auipc	ra,0x4
    19a6:	fe8080e7          	jalr	-24(ra) # 598a <printf>
        exit(1);
    19aa:	4505                	li	a0,1
    19ac:	00004097          	auipc	ra,0x4
    19b0:	c66080e7          	jalr	-922(ra) # 5612 <exit>
      exit(i);
    19b4:	854a                	mv	a0,s2
    19b6:	00004097          	auipc	ra,0x4
    19ba:	c5c080e7          	jalr	-932(ra) # 5612 <exit>

00000000000019be <twochildren>:
{
    19be:	1101                	addi	sp,sp,-32
    19c0:	ec06                	sd	ra,24(sp)
    19c2:	e822                	sd	s0,16(sp)
    19c4:	e426                	sd	s1,8(sp)
    19c6:	e04a                	sd	s2,0(sp)
    19c8:	1000                	addi	s0,sp,32
    19ca:	892a                	mv	s2,a0
    19cc:	3e800493          	li	s1,1000
    int pid1 = fork();
    19d0:	00004097          	auipc	ra,0x4
    19d4:	c3a080e7          	jalr	-966(ra) # 560a <fork>
    if(pid1 < 0){
    19d8:	02054c63          	bltz	a0,1a10 <twochildren+0x52>
    if(pid1 == 0){
    19dc:	c921                	beqz	a0,1a2c <twochildren+0x6e>
      int pid2 = fork();
    19de:	00004097          	auipc	ra,0x4
    19e2:	c2c080e7          	jalr	-980(ra) # 560a <fork>
      if(pid2 < 0){
    19e6:	04054763          	bltz	a0,1a34 <twochildren+0x76>
      if(pid2 == 0){
    19ea:	c13d                	beqz	a0,1a50 <twochildren+0x92>
        wait(0);
    19ec:	4501                	li	a0,0
    19ee:	00004097          	auipc	ra,0x4
    19f2:	c2c080e7          	jalr	-980(ra) # 561a <wait>
        wait(0);
    19f6:	4501                	li	a0,0
    19f8:	00004097          	auipc	ra,0x4
    19fc:	c22080e7          	jalr	-990(ra) # 561a <wait>
  for(int i = 0; i < 1000; i++){
    1a00:	34fd                	addiw	s1,s1,-1
    1a02:	f4f9                	bnez	s1,19d0 <twochildren+0x12>
}
    1a04:	60e2                	ld	ra,24(sp)
    1a06:	6442                	ld	s0,16(sp)
    1a08:	64a2                	ld	s1,8(sp)
    1a0a:	6902                	ld	s2,0(sp)
    1a0c:	6105                	addi	sp,sp,32
    1a0e:	8082                	ret
      printf("%s: fork failed\n", s);
    1a10:	85ca                	mv	a1,s2
    1a12:	00005517          	auipc	a0,0x5
    1a16:	d3650513          	addi	a0,a0,-714 # 6748 <statistics+0xc1c>
    1a1a:	00004097          	auipc	ra,0x4
    1a1e:	f70080e7          	jalr	-144(ra) # 598a <printf>
      exit(1);
    1a22:	4505                	li	a0,1
    1a24:	00004097          	auipc	ra,0x4
    1a28:	bee080e7          	jalr	-1042(ra) # 5612 <exit>
      exit(0);
    1a2c:	00004097          	auipc	ra,0x4
    1a30:	be6080e7          	jalr	-1050(ra) # 5612 <exit>
        printf("%s: fork failed\n", s);
    1a34:	85ca                	mv	a1,s2
    1a36:	00005517          	auipc	a0,0x5
    1a3a:	d1250513          	addi	a0,a0,-750 # 6748 <statistics+0xc1c>
    1a3e:	00004097          	auipc	ra,0x4
    1a42:	f4c080e7          	jalr	-180(ra) # 598a <printf>
        exit(1);
    1a46:	4505                	li	a0,1
    1a48:	00004097          	auipc	ra,0x4
    1a4c:	bca080e7          	jalr	-1078(ra) # 5612 <exit>
        exit(0);
    1a50:	00004097          	auipc	ra,0x4
    1a54:	bc2080e7          	jalr	-1086(ra) # 5612 <exit>

0000000000001a58 <forkfork>:
{
    1a58:	7179                	addi	sp,sp,-48
    1a5a:	f406                	sd	ra,40(sp)
    1a5c:	f022                	sd	s0,32(sp)
    1a5e:	ec26                	sd	s1,24(sp)
    1a60:	1800                	addi	s0,sp,48
    1a62:	84aa                	mv	s1,a0
    int pid = fork();
    1a64:	00004097          	auipc	ra,0x4
    1a68:	ba6080e7          	jalr	-1114(ra) # 560a <fork>
    if(pid < 0){
    1a6c:	04054163          	bltz	a0,1aae <forkfork+0x56>
    if(pid == 0){
    1a70:	cd29                	beqz	a0,1aca <forkfork+0x72>
    int pid = fork();
    1a72:	00004097          	auipc	ra,0x4
    1a76:	b98080e7          	jalr	-1128(ra) # 560a <fork>
    if(pid < 0){
    1a7a:	02054a63          	bltz	a0,1aae <forkfork+0x56>
    if(pid == 0){
    1a7e:	c531                	beqz	a0,1aca <forkfork+0x72>
    wait(&xstatus);
    1a80:	fdc40513          	addi	a0,s0,-36
    1a84:	00004097          	auipc	ra,0x4
    1a88:	b96080e7          	jalr	-1130(ra) # 561a <wait>
    if(xstatus != 0) {
    1a8c:	fdc42783          	lw	a5,-36(s0)
    1a90:	ebbd                	bnez	a5,1b06 <forkfork+0xae>
    wait(&xstatus);
    1a92:	fdc40513          	addi	a0,s0,-36
    1a96:	00004097          	auipc	ra,0x4
    1a9a:	b84080e7          	jalr	-1148(ra) # 561a <wait>
    if(xstatus != 0) {
    1a9e:	fdc42783          	lw	a5,-36(s0)
    1aa2:	e3b5                	bnez	a5,1b06 <forkfork+0xae>
}
    1aa4:	70a2                	ld	ra,40(sp)
    1aa6:	7402                	ld	s0,32(sp)
    1aa8:	64e2                	ld	s1,24(sp)
    1aaa:	6145                	addi	sp,sp,48
    1aac:	8082                	ret
      printf("%s: fork failed", s);
    1aae:	85a6                	mv	a1,s1
    1ab0:	00005517          	auipc	a0,0x5
    1ab4:	e5850513          	addi	a0,a0,-424 # 6908 <statistics+0xddc>
    1ab8:	00004097          	auipc	ra,0x4
    1abc:	ed2080e7          	jalr	-302(ra) # 598a <printf>
      exit(1);
    1ac0:	4505                	li	a0,1
    1ac2:	00004097          	auipc	ra,0x4
    1ac6:	b50080e7          	jalr	-1200(ra) # 5612 <exit>
{
    1aca:	0c800493          	li	s1,200
        int pid1 = fork();
    1ace:	00004097          	auipc	ra,0x4
    1ad2:	b3c080e7          	jalr	-1220(ra) # 560a <fork>
        if(pid1 < 0){
    1ad6:	00054f63          	bltz	a0,1af4 <forkfork+0x9c>
        if(pid1 == 0){
    1ada:	c115                	beqz	a0,1afe <forkfork+0xa6>
        wait(0);
    1adc:	4501                	li	a0,0
    1ade:	00004097          	auipc	ra,0x4
    1ae2:	b3c080e7          	jalr	-1220(ra) # 561a <wait>
      for(int j = 0; j < 200; j++){
    1ae6:	34fd                	addiw	s1,s1,-1
    1ae8:	f0fd                	bnez	s1,1ace <forkfork+0x76>
      exit(0);
    1aea:	4501                	li	a0,0
    1aec:	00004097          	auipc	ra,0x4
    1af0:	b26080e7          	jalr	-1242(ra) # 5612 <exit>
          exit(1);
    1af4:	4505                	li	a0,1
    1af6:	00004097          	auipc	ra,0x4
    1afa:	b1c080e7          	jalr	-1252(ra) # 5612 <exit>
          exit(0);
    1afe:	00004097          	auipc	ra,0x4
    1b02:	b14080e7          	jalr	-1260(ra) # 5612 <exit>
      printf("%s: fork in child failed", s);
    1b06:	85a6                	mv	a1,s1
    1b08:	00005517          	auipc	a0,0x5
    1b0c:	e1050513          	addi	a0,a0,-496 # 6918 <statistics+0xdec>
    1b10:	00004097          	auipc	ra,0x4
    1b14:	e7a080e7          	jalr	-390(ra) # 598a <printf>
      exit(1);
    1b18:	4505                	li	a0,1
    1b1a:	00004097          	auipc	ra,0x4
    1b1e:	af8080e7          	jalr	-1288(ra) # 5612 <exit>

0000000000001b22 <reparent2>:
{
    1b22:	1101                	addi	sp,sp,-32
    1b24:	ec06                	sd	ra,24(sp)
    1b26:	e822                	sd	s0,16(sp)
    1b28:	e426                	sd	s1,8(sp)
    1b2a:	1000                	addi	s0,sp,32
    1b2c:	32000493          	li	s1,800
    int pid1 = fork();
    1b30:	00004097          	auipc	ra,0x4
    1b34:	ada080e7          	jalr	-1318(ra) # 560a <fork>
    if(pid1 < 0){
    1b38:	00054f63          	bltz	a0,1b56 <reparent2+0x34>
    if(pid1 == 0){
    1b3c:	c915                	beqz	a0,1b70 <reparent2+0x4e>
    wait(0);
    1b3e:	4501                	li	a0,0
    1b40:	00004097          	auipc	ra,0x4
    1b44:	ada080e7          	jalr	-1318(ra) # 561a <wait>
  for(int i = 0; i < 800; i++){
    1b48:	34fd                	addiw	s1,s1,-1
    1b4a:	f0fd                	bnez	s1,1b30 <reparent2+0xe>
  exit(0);
    1b4c:	4501                	li	a0,0
    1b4e:	00004097          	auipc	ra,0x4
    1b52:	ac4080e7          	jalr	-1340(ra) # 5612 <exit>
      printf("fork failed\n");
    1b56:	00005517          	auipc	a0,0x5
    1b5a:	ffa50513          	addi	a0,a0,-6 # 6b50 <statistics+0x1024>
    1b5e:	00004097          	auipc	ra,0x4
    1b62:	e2c080e7          	jalr	-468(ra) # 598a <printf>
      exit(1);
    1b66:	4505                	li	a0,1
    1b68:	00004097          	auipc	ra,0x4
    1b6c:	aaa080e7          	jalr	-1366(ra) # 5612 <exit>
      fork();
    1b70:	00004097          	auipc	ra,0x4
    1b74:	a9a080e7          	jalr	-1382(ra) # 560a <fork>
      fork();
    1b78:	00004097          	auipc	ra,0x4
    1b7c:	a92080e7          	jalr	-1390(ra) # 560a <fork>
      exit(0);
    1b80:	4501                	li	a0,0
    1b82:	00004097          	auipc	ra,0x4
    1b86:	a90080e7          	jalr	-1392(ra) # 5612 <exit>

0000000000001b8a <createdelete>:
{
    1b8a:	7175                	addi	sp,sp,-144
    1b8c:	e506                	sd	ra,136(sp)
    1b8e:	e122                	sd	s0,128(sp)
    1b90:	fca6                	sd	s1,120(sp)
    1b92:	f8ca                	sd	s2,112(sp)
    1b94:	f4ce                	sd	s3,104(sp)
    1b96:	f0d2                	sd	s4,96(sp)
    1b98:	ecd6                	sd	s5,88(sp)
    1b9a:	e8da                	sd	s6,80(sp)
    1b9c:	e4de                	sd	s7,72(sp)
    1b9e:	e0e2                	sd	s8,64(sp)
    1ba0:	fc66                	sd	s9,56(sp)
    1ba2:	0900                	addi	s0,sp,144
    1ba4:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1ba6:	4901                	li	s2,0
    1ba8:	4991                	li	s3,4
    pid = fork();
    1baa:	00004097          	auipc	ra,0x4
    1bae:	a60080e7          	jalr	-1440(ra) # 560a <fork>
    1bb2:	84aa                	mv	s1,a0
    if(pid < 0){
    1bb4:	02054f63          	bltz	a0,1bf2 <createdelete+0x68>
    if(pid == 0){
    1bb8:	c939                	beqz	a0,1c0e <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bba:	2905                	addiw	s2,s2,1
    1bbc:	ff3917e3          	bne	s2,s3,1baa <createdelete+0x20>
    1bc0:	4491                	li	s1,4
    wait(&xstatus);
    1bc2:	f7c40513          	addi	a0,s0,-132
    1bc6:	00004097          	auipc	ra,0x4
    1bca:	a54080e7          	jalr	-1452(ra) # 561a <wait>
    if(xstatus != 0)
    1bce:	f7c42903          	lw	s2,-132(s0)
    1bd2:	0e091263          	bnez	s2,1cb6 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bd6:	34fd                	addiw	s1,s1,-1
    1bd8:	f4ed                	bnez	s1,1bc2 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bda:	f8040123          	sb	zero,-126(s0)
    1bde:	03000993          	li	s3,48
    1be2:	5a7d                	li	s4,-1
    1be4:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1be8:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bea:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1bec:	07400a93          	li	s5,116
    1bf0:	a29d                	j	1d56 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1bf2:	85e6                	mv	a1,s9
    1bf4:	00005517          	auipc	a0,0x5
    1bf8:	f5c50513          	addi	a0,a0,-164 # 6b50 <statistics+0x1024>
    1bfc:	00004097          	auipc	ra,0x4
    1c00:	d8e080e7          	jalr	-626(ra) # 598a <printf>
      exit(1);
    1c04:	4505                	li	a0,1
    1c06:	00004097          	auipc	ra,0x4
    1c0a:	a0c080e7          	jalr	-1524(ra) # 5612 <exit>
      name[0] = 'p' + pi;
    1c0e:	0709091b          	addiw	s2,s2,112
    1c12:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c16:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c1a:	4951                	li	s2,20
    1c1c:	a015                	j	1c40 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c1e:	85e6                	mv	a1,s9
    1c20:	00005517          	auipc	a0,0x5
    1c24:	bc050513          	addi	a0,a0,-1088 # 67e0 <statistics+0xcb4>
    1c28:	00004097          	auipc	ra,0x4
    1c2c:	d62080e7          	jalr	-670(ra) # 598a <printf>
          exit(1);
    1c30:	4505                	li	a0,1
    1c32:	00004097          	auipc	ra,0x4
    1c36:	9e0080e7          	jalr	-1568(ra) # 5612 <exit>
      for(i = 0; i < N; i++){
    1c3a:	2485                	addiw	s1,s1,1
    1c3c:	07248863          	beq	s1,s2,1cac <createdelete+0x122>
        name[1] = '0' + i;
    1c40:	0304879b          	addiw	a5,s1,48
    1c44:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c48:	20200593          	li	a1,514
    1c4c:	f8040513          	addi	a0,s0,-128
    1c50:	00004097          	auipc	ra,0x4
    1c54:	a02080e7          	jalr	-1534(ra) # 5652 <open>
        if(fd < 0){
    1c58:	fc0543e3          	bltz	a0,1c1e <createdelete+0x94>
        close(fd);
    1c5c:	00004097          	auipc	ra,0x4
    1c60:	9de080e7          	jalr	-1570(ra) # 563a <close>
        if(i > 0 && (i % 2 ) == 0){
    1c64:	fc905be3          	blez	s1,1c3a <createdelete+0xb0>
    1c68:	0014f793          	andi	a5,s1,1
    1c6c:	f7f9                	bnez	a5,1c3a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c6e:	01f4d79b          	srliw	a5,s1,0x1f
    1c72:	9fa5                	addw	a5,a5,s1
    1c74:	4017d79b          	sraiw	a5,a5,0x1
    1c78:	0307879b          	addiw	a5,a5,48
    1c7c:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c80:	f8040513          	addi	a0,s0,-128
    1c84:	00004097          	auipc	ra,0x4
    1c88:	9de080e7          	jalr	-1570(ra) # 5662 <unlink>
    1c8c:	fa0557e3          	bgez	a0,1c3a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1c90:	85e6                	mv	a1,s9
    1c92:	00005517          	auipc	a0,0x5
    1c96:	ca650513          	addi	a0,a0,-858 # 6938 <statistics+0xe0c>
    1c9a:	00004097          	auipc	ra,0x4
    1c9e:	cf0080e7          	jalr	-784(ra) # 598a <printf>
            exit(1);
    1ca2:	4505                	li	a0,1
    1ca4:	00004097          	auipc	ra,0x4
    1ca8:	96e080e7          	jalr	-1682(ra) # 5612 <exit>
      exit(0);
    1cac:	4501                	li	a0,0
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	964080e7          	jalr	-1692(ra) # 5612 <exit>
      exit(1);
    1cb6:	4505                	li	a0,1
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	95a080e7          	jalr	-1702(ra) # 5612 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cc0:	f8040613          	addi	a2,s0,-128
    1cc4:	85e6                	mv	a1,s9
    1cc6:	00005517          	auipc	a0,0x5
    1cca:	c8a50513          	addi	a0,a0,-886 # 6950 <statistics+0xe24>
    1cce:	00004097          	auipc	ra,0x4
    1cd2:	cbc080e7          	jalr	-836(ra) # 598a <printf>
        exit(1);
    1cd6:	4505                	li	a0,1
    1cd8:	00004097          	auipc	ra,0x4
    1cdc:	93a080e7          	jalr	-1734(ra) # 5612 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ce0:	054b7163          	bgeu	s6,s4,1d22 <createdelete+0x198>
      if(fd >= 0)
    1ce4:	02055a63          	bgez	a0,1d18 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1ce8:	2485                	addiw	s1,s1,1
    1cea:	0ff4f493          	andi	s1,s1,255
    1cee:	05548c63          	beq	s1,s5,1d46 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1cf2:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1cf6:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1cfa:	4581                	li	a1,0
    1cfc:	f8040513          	addi	a0,s0,-128
    1d00:	00004097          	auipc	ra,0x4
    1d04:	952080e7          	jalr	-1710(ra) # 5652 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d08:	00090463          	beqz	s2,1d10 <createdelete+0x186>
    1d0c:	fd2bdae3          	bge	s7,s2,1ce0 <createdelete+0x156>
    1d10:	fa0548e3          	bltz	a0,1cc0 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d14:	014b7963          	bgeu	s6,s4,1d26 <createdelete+0x19c>
        close(fd);
    1d18:	00004097          	auipc	ra,0x4
    1d1c:	922080e7          	jalr	-1758(ra) # 563a <close>
    1d20:	b7e1                	j	1ce8 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d22:	fc0543e3          	bltz	a0,1ce8 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d26:	f8040613          	addi	a2,s0,-128
    1d2a:	85e6                	mv	a1,s9
    1d2c:	00005517          	auipc	a0,0x5
    1d30:	c4c50513          	addi	a0,a0,-948 # 6978 <statistics+0xe4c>
    1d34:	00004097          	auipc	ra,0x4
    1d38:	c56080e7          	jalr	-938(ra) # 598a <printf>
        exit(1);
    1d3c:	4505                	li	a0,1
    1d3e:	00004097          	auipc	ra,0x4
    1d42:	8d4080e7          	jalr	-1836(ra) # 5612 <exit>
  for(i = 0; i < N; i++){
    1d46:	2905                	addiw	s2,s2,1
    1d48:	2a05                	addiw	s4,s4,1
    1d4a:	2985                	addiw	s3,s3,1
    1d4c:	0ff9f993          	andi	s3,s3,255
    1d50:	47d1                	li	a5,20
    1d52:	02f90a63          	beq	s2,a5,1d86 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d56:	84e2                	mv	s1,s8
    1d58:	bf69                	j	1cf2 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d5a:	2905                	addiw	s2,s2,1
    1d5c:	0ff97913          	andi	s2,s2,255
    1d60:	2985                	addiw	s3,s3,1
    1d62:	0ff9f993          	andi	s3,s3,255
    1d66:	03490863          	beq	s2,s4,1d96 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d6a:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d6c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d70:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d74:	f8040513          	addi	a0,s0,-128
    1d78:	00004097          	auipc	ra,0x4
    1d7c:	8ea080e7          	jalr	-1814(ra) # 5662 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d80:	34fd                	addiw	s1,s1,-1
    1d82:	f4ed                	bnez	s1,1d6c <createdelete+0x1e2>
    1d84:	bfd9                	j	1d5a <createdelete+0x1d0>
    1d86:	03000993          	li	s3,48
    1d8a:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1d8e:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1d90:	08400a13          	li	s4,132
    1d94:	bfd9                	j	1d6a <createdelete+0x1e0>
}
    1d96:	60aa                	ld	ra,136(sp)
    1d98:	640a                	ld	s0,128(sp)
    1d9a:	74e6                	ld	s1,120(sp)
    1d9c:	7946                	ld	s2,112(sp)
    1d9e:	79a6                	ld	s3,104(sp)
    1da0:	7a06                	ld	s4,96(sp)
    1da2:	6ae6                	ld	s5,88(sp)
    1da4:	6b46                	ld	s6,80(sp)
    1da6:	6ba6                	ld	s7,72(sp)
    1da8:	6c06                	ld	s8,64(sp)
    1daa:	7ce2                	ld	s9,56(sp)
    1dac:	6149                	addi	sp,sp,144
    1dae:	8082                	ret

0000000000001db0 <linkunlink>:
{
    1db0:	711d                	addi	sp,sp,-96
    1db2:	ec86                	sd	ra,88(sp)
    1db4:	e8a2                	sd	s0,80(sp)
    1db6:	e4a6                	sd	s1,72(sp)
    1db8:	e0ca                	sd	s2,64(sp)
    1dba:	fc4e                	sd	s3,56(sp)
    1dbc:	f852                	sd	s4,48(sp)
    1dbe:	f456                	sd	s5,40(sp)
    1dc0:	f05a                	sd	s6,32(sp)
    1dc2:	ec5e                	sd	s7,24(sp)
    1dc4:	e862                	sd	s8,16(sp)
    1dc6:	e466                	sd	s9,8(sp)
    1dc8:	1080                	addi	s0,sp,96
    1dca:	84aa                	mv	s1,a0
  unlink("x");
    1dcc:	00004517          	auipc	a0,0x4
    1dd0:	1b450513          	addi	a0,a0,436 # 5f80 <statistics+0x454>
    1dd4:	00004097          	auipc	ra,0x4
    1dd8:	88e080e7          	jalr	-1906(ra) # 5662 <unlink>
  pid = fork();
    1ddc:	00004097          	auipc	ra,0x4
    1de0:	82e080e7          	jalr	-2002(ra) # 560a <fork>
  if(pid < 0){
    1de4:	02054b63          	bltz	a0,1e1a <linkunlink+0x6a>
    1de8:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dea:	4c85                	li	s9,1
    1dec:	e119                	bnez	a0,1df2 <linkunlink+0x42>
    1dee:	06100c93          	li	s9,97
    1df2:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1df6:	41c659b7          	lui	s3,0x41c65
    1dfa:	e6d9899b          	addiw	s3,s3,-403
    1dfe:	690d                	lui	s2,0x3
    1e00:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e04:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e06:	4b05                	li	s6,1
      unlink("x");
    1e08:	00004a97          	auipc	s5,0x4
    1e0c:	178a8a93          	addi	s5,s5,376 # 5f80 <statistics+0x454>
      link("cat", "x");
    1e10:	00005b97          	auipc	s7,0x5
    1e14:	b90b8b93          	addi	s7,s7,-1136 # 69a0 <statistics+0xe74>
    1e18:	a091                	j	1e5c <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e1a:	85a6                	mv	a1,s1
    1e1c:	00005517          	auipc	a0,0x5
    1e20:	92c50513          	addi	a0,a0,-1748 # 6748 <statistics+0xc1c>
    1e24:	00004097          	auipc	ra,0x4
    1e28:	b66080e7          	jalr	-1178(ra) # 598a <printf>
    exit(1);
    1e2c:	4505                	li	a0,1
    1e2e:	00003097          	auipc	ra,0x3
    1e32:	7e4080e7          	jalr	2020(ra) # 5612 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e36:	20200593          	li	a1,514
    1e3a:	8556                	mv	a0,s5
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	816080e7          	jalr	-2026(ra) # 5652 <open>
    1e44:	00003097          	auipc	ra,0x3
    1e48:	7f6080e7          	jalr	2038(ra) # 563a <close>
    1e4c:	a031                	j	1e58 <linkunlink+0xa8>
      unlink("x");
    1e4e:	8556                	mv	a0,s5
    1e50:	00004097          	auipc	ra,0x4
    1e54:	812080e7          	jalr	-2030(ra) # 5662 <unlink>
  for(i = 0; i < 100; i++){
    1e58:	34fd                	addiw	s1,s1,-1
    1e5a:	c09d                	beqz	s1,1e80 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e5c:	033c87bb          	mulw	a5,s9,s3
    1e60:	012787bb          	addw	a5,a5,s2
    1e64:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e68:	0347f7bb          	remuw	a5,a5,s4
    1e6c:	d7e9                	beqz	a5,1e36 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e6e:	ff6790e3          	bne	a5,s6,1e4e <linkunlink+0x9e>
      link("cat", "x");
    1e72:	85d6                	mv	a1,s5
    1e74:	855e                	mv	a0,s7
    1e76:	00003097          	auipc	ra,0x3
    1e7a:	7fc080e7          	jalr	2044(ra) # 5672 <link>
    1e7e:	bfe9                	j	1e58 <linkunlink+0xa8>
  if(pid)
    1e80:	020c0463          	beqz	s8,1ea8 <linkunlink+0xf8>
    wait(0);
    1e84:	4501                	li	a0,0
    1e86:	00003097          	auipc	ra,0x3
    1e8a:	794080e7          	jalr	1940(ra) # 561a <wait>
}
    1e8e:	60e6                	ld	ra,88(sp)
    1e90:	6446                	ld	s0,80(sp)
    1e92:	64a6                	ld	s1,72(sp)
    1e94:	6906                	ld	s2,64(sp)
    1e96:	79e2                	ld	s3,56(sp)
    1e98:	7a42                	ld	s4,48(sp)
    1e9a:	7aa2                	ld	s5,40(sp)
    1e9c:	7b02                	ld	s6,32(sp)
    1e9e:	6be2                	ld	s7,24(sp)
    1ea0:	6c42                	ld	s8,16(sp)
    1ea2:	6ca2                	ld	s9,8(sp)
    1ea4:	6125                	addi	sp,sp,96
    1ea6:	8082                	ret
    exit(0);
    1ea8:	4501                	li	a0,0
    1eaa:	00003097          	auipc	ra,0x3
    1eae:	768080e7          	jalr	1896(ra) # 5612 <exit>

0000000000001eb2 <manywrites>:
{
    1eb2:	711d                	addi	sp,sp,-96
    1eb4:	ec86                	sd	ra,88(sp)
    1eb6:	e8a2                	sd	s0,80(sp)
    1eb8:	e4a6                	sd	s1,72(sp)
    1eba:	e0ca                	sd	s2,64(sp)
    1ebc:	fc4e                	sd	s3,56(sp)
    1ebe:	f852                	sd	s4,48(sp)
    1ec0:	f456                	sd	s5,40(sp)
    1ec2:	f05a                	sd	s6,32(sp)
    1ec4:	ec5e                	sd	s7,24(sp)
    1ec6:	1080                	addi	s0,sp,96
    1ec8:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1eca:	4901                	li	s2,0
    1ecc:	4991                	li	s3,4
    int pid = fork();
    1ece:	00003097          	auipc	ra,0x3
    1ed2:	73c080e7          	jalr	1852(ra) # 560a <fork>
    1ed6:	84aa                	mv	s1,a0
    if(pid < 0){
    1ed8:	02054963          	bltz	a0,1f0a <manywrites+0x58>
    if(pid == 0){
    1edc:	c521                	beqz	a0,1f24 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    1ede:	2905                	addiw	s2,s2,1
    1ee0:	ff3917e3          	bne	s2,s3,1ece <manywrites+0x1c>
    1ee4:	4491                	li	s1,4
    int st = 0;
    1ee6:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1eea:	fa840513          	addi	a0,s0,-88
    1eee:	00003097          	auipc	ra,0x3
    1ef2:	72c080e7          	jalr	1836(ra) # 561a <wait>
    if(st != 0)
    1ef6:	fa842503          	lw	a0,-88(s0)
    1efa:	ed6d                	bnez	a0,1ff4 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    1efc:	34fd                	addiw	s1,s1,-1
    1efe:	f4e5                	bnez	s1,1ee6 <manywrites+0x34>
  exit(0);
    1f00:	4501                	li	a0,0
    1f02:	00003097          	auipc	ra,0x3
    1f06:	710080e7          	jalr	1808(ra) # 5612 <exit>
      printf("fork failed\n");
    1f0a:	00005517          	auipc	a0,0x5
    1f0e:	c4650513          	addi	a0,a0,-954 # 6b50 <statistics+0x1024>
    1f12:	00004097          	auipc	ra,0x4
    1f16:	a78080e7          	jalr	-1416(ra) # 598a <printf>
      exit(1);
    1f1a:	4505                	li	a0,1
    1f1c:	00003097          	auipc	ra,0x3
    1f20:	6f6080e7          	jalr	1782(ra) # 5612 <exit>
      name[0] = 'b';
    1f24:	06200793          	li	a5,98
    1f28:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1f2c:	0619079b          	addiw	a5,s2,97
    1f30:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1f34:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1f38:	fa840513          	addi	a0,s0,-88
    1f3c:	00003097          	auipc	ra,0x3
    1f40:	726080e7          	jalr	1830(ra) # 5662 <unlink>
    1f44:	4b79                	li	s6,30
          int cc = write(fd, buf, sz);
    1f46:	0000ab97          	auipc	s7,0xa
    1f4a:	c0ab8b93          	addi	s7,s7,-1014 # bb50 <buf>
        for(int i = 0; i < ci+1; i++){
    1f4e:	8a26                	mv	s4,s1
    1f50:	02094e63          	bltz	s2,1f8c <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    1f54:	20200593          	li	a1,514
    1f58:	fa840513          	addi	a0,s0,-88
    1f5c:	00003097          	auipc	ra,0x3
    1f60:	6f6080e7          	jalr	1782(ra) # 5652 <open>
    1f64:	89aa                	mv	s3,a0
          if(fd < 0){
    1f66:	04054763          	bltz	a0,1fb4 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    1f6a:	660d                	lui	a2,0x3
    1f6c:	85de                	mv	a1,s7
    1f6e:	00003097          	auipc	ra,0x3
    1f72:	6c4080e7          	jalr	1732(ra) # 5632 <write>
          if(cc != sz){
    1f76:	678d                	lui	a5,0x3
    1f78:	04f51e63          	bne	a0,a5,1fd4 <manywrites+0x122>
          close(fd);
    1f7c:	854e                	mv	a0,s3
    1f7e:	00003097          	auipc	ra,0x3
    1f82:	6bc080e7          	jalr	1724(ra) # 563a <close>
        for(int i = 0; i < ci+1; i++){
    1f86:	2a05                	addiw	s4,s4,1
    1f88:	fd4956e3          	bge	s2,s4,1f54 <manywrites+0xa2>
        unlink(name);
    1f8c:	fa840513          	addi	a0,s0,-88
    1f90:	00003097          	auipc	ra,0x3
    1f94:	6d2080e7          	jalr	1746(ra) # 5662 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1f98:	3b7d                	addiw	s6,s6,-1
    1f9a:	fa0b1ae3          	bnez	s6,1f4e <manywrites+0x9c>
      unlink(name);
    1f9e:	fa840513          	addi	a0,s0,-88
    1fa2:	00003097          	auipc	ra,0x3
    1fa6:	6c0080e7          	jalr	1728(ra) # 5662 <unlink>
      exit(0);
    1faa:	4501                	li	a0,0
    1fac:	00003097          	auipc	ra,0x3
    1fb0:	666080e7          	jalr	1638(ra) # 5612 <exit>
            printf("%s: cannot create %s\n", s, name);
    1fb4:	fa840613          	addi	a2,s0,-88
    1fb8:	85d6                	mv	a1,s5
    1fba:	00005517          	auipc	a0,0x5
    1fbe:	9ee50513          	addi	a0,a0,-1554 # 69a8 <statistics+0xe7c>
    1fc2:	00004097          	auipc	ra,0x4
    1fc6:	9c8080e7          	jalr	-1592(ra) # 598a <printf>
            exit(1);
    1fca:	4505                	li	a0,1
    1fcc:	00003097          	auipc	ra,0x3
    1fd0:	646080e7          	jalr	1606(ra) # 5612 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1fd4:	86aa                	mv	a3,a0
    1fd6:	660d                	lui	a2,0x3
    1fd8:	85d6                	mv	a1,s5
    1fda:	00004517          	auipc	a0,0x4
    1fde:	ff650513          	addi	a0,a0,-10 # 5fd0 <statistics+0x4a4>
    1fe2:	00004097          	auipc	ra,0x4
    1fe6:	9a8080e7          	jalr	-1624(ra) # 598a <printf>
            exit(1);
    1fea:	4505                	li	a0,1
    1fec:	00003097          	auipc	ra,0x3
    1ff0:	626080e7          	jalr	1574(ra) # 5612 <exit>
      exit(st);
    1ff4:	00003097          	auipc	ra,0x3
    1ff8:	61e080e7          	jalr	1566(ra) # 5612 <exit>

0000000000001ffc <forktest>:
{
    1ffc:	7179                	addi	sp,sp,-48
    1ffe:	f406                	sd	ra,40(sp)
    2000:	f022                	sd	s0,32(sp)
    2002:	ec26                	sd	s1,24(sp)
    2004:	e84a                	sd	s2,16(sp)
    2006:	e44e                	sd	s3,8(sp)
    2008:	1800                	addi	s0,sp,48
    200a:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    200c:	4481                	li	s1,0
    200e:	3e800913          	li	s2,1000
    pid = fork();
    2012:	00003097          	auipc	ra,0x3
    2016:	5f8080e7          	jalr	1528(ra) # 560a <fork>
    if(pid < 0)
    201a:	02054863          	bltz	a0,204a <forktest+0x4e>
    if(pid == 0)
    201e:	c115                	beqz	a0,2042 <forktest+0x46>
  for(n=0; n<N; n++){
    2020:	2485                	addiw	s1,s1,1
    2022:	ff2498e3          	bne	s1,s2,2012 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    2026:	85ce                	mv	a1,s3
    2028:	00005517          	auipc	a0,0x5
    202c:	9b050513          	addi	a0,a0,-1616 # 69d8 <statistics+0xeac>
    2030:	00004097          	auipc	ra,0x4
    2034:	95a080e7          	jalr	-1702(ra) # 598a <printf>
    exit(1);
    2038:	4505                	li	a0,1
    203a:	00003097          	auipc	ra,0x3
    203e:	5d8080e7          	jalr	1496(ra) # 5612 <exit>
      exit(0);
    2042:	00003097          	auipc	ra,0x3
    2046:	5d0080e7          	jalr	1488(ra) # 5612 <exit>
  if (n == 0) {
    204a:	cc9d                	beqz	s1,2088 <forktest+0x8c>
  if(n == N){
    204c:	3e800793          	li	a5,1000
    2050:	fcf48be3          	beq	s1,a5,2026 <forktest+0x2a>
  for(; n > 0; n--){
    2054:	00905b63          	blez	s1,206a <forktest+0x6e>
    if(wait(0) < 0){
    2058:	4501                	li	a0,0
    205a:	00003097          	auipc	ra,0x3
    205e:	5c0080e7          	jalr	1472(ra) # 561a <wait>
    2062:	04054163          	bltz	a0,20a4 <forktest+0xa8>
  for(; n > 0; n--){
    2066:	34fd                	addiw	s1,s1,-1
    2068:	f8e5                	bnez	s1,2058 <forktest+0x5c>
  if(wait(0) != -1){
    206a:	4501                	li	a0,0
    206c:	00003097          	auipc	ra,0x3
    2070:	5ae080e7          	jalr	1454(ra) # 561a <wait>
    2074:	57fd                	li	a5,-1
    2076:	04f51563          	bne	a0,a5,20c0 <forktest+0xc4>
}
    207a:	70a2                	ld	ra,40(sp)
    207c:	7402                	ld	s0,32(sp)
    207e:	64e2                	ld	s1,24(sp)
    2080:	6942                	ld	s2,16(sp)
    2082:	69a2                	ld	s3,8(sp)
    2084:	6145                	addi	sp,sp,48
    2086:	8082                	ret
    printf("%s: no fork at all!\n", s);
    2088:	85ce                	mv	a1,s3
    208a:	00005517          	auipc	a0,0x5
    208e:	93650513          	addi	a0,a0,-1738 # 69c0 <statistics+0xe94>
    2092:	00004097          	auipc	ra,0x4
    2096:	8f8080e7          	jalr	-1800(ra) # 598a <printf>
    exit(1);
    209a:	4505                	li	a0,1
    209c:	00003097          	auipc	ra,0x3
    20a0:	576080e7          	jalr	1398(ra) # 5612 <exit>
      printf("%s: wait stopped early\n", s);
    20a4:	85ce                	mv	a1,s3
    20a6:	00005517          	auipc	a0,0x5
    20aa:	95a50513          	addi	a0,a0,-1702 # 6a00 <statistics+0xed4>
    20ae:	00004097          	auipc	ra,0x4
    20b2:	8dc080e7          	jalr	-1828(ra) # 598a <printf>
      exit(1);
    20b6:	4505                	li	a0,1
    20b8:	00003097          	auipc	ra,0x3
    20bc:	55a080e7          	jalr	1370(ra) # 5612 <exit>
    printf("%s: wait got too many\n", s);
    20c0:	85ce                	mv	a1,s3
    20c2:	00005517          	auipc	a0,0x5
    20c6:	95650513          	addi	a0,a0,-1706 # 6a18 <statistics+0xeec>
    20ca:	00004097          	auipc	ra,0x4
    20ce:	8c0080e7          	jalr	-1856(ra) # 598a <printf>
    exit(1);
    20d2:	4505                	li	a0,1
    20d4:	00003097          	auipc	ra,0x3
    20d8:	53e080e7          	jalr	1342(ra) # 5612 <exit>

00000000000020dc <kernmem>:
{
    20dc:	715d                	addi	sp,sp,-80
    20de:	e486                	sd	ra,72(sp)
    20e0:	e0a2                	sd	s0,64(sp)
    20e2:	fc26                	sd	s1,56(sp)
    20e4:	f84a                	sd	s2,48(sp)
    20e6:	f44e                	sd	s3,40(sp)
    20e8:	f052                	sd	s4,32(sp)
    20ea:	ec56                	sd	s5,24(sp)
    20ec:	0880                	addi	s0,sp,80
    20ee:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f0:	4485                	li	s1,1
    20f2:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    20f4:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f6:	69b1                	lui	s3,0xc
    20f8:	35098993          	addi	s3,s3,848 # c350 <buf+0x800>
    20fc:	1003d937          	lui	s2,0x1003d
    2100:	090e                	slli	s2,s2,0x3
    2102:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e920>
    pid = fork();
    2106:	00003097          	auipc	ra,0x3
    210a:	504080e7          	jalr	1284(ra) # 560a <fork>
    if(pid < 0){
    210e:	02054963          	bltz	a0,2140 <kernmem+0x64>
    if(pid == 0){
    2112:	c529                	beqz	a0,215c <kernmem+0x80>
    wait(&xstatus);
    2114:	fbc40513          	addi	a0,s0,-68
    2118:	00003097          	auipc	ra,0x3
    211c:	502080e7          	jalr	1282(ra) # 561a <wait>
    if(xstatus != -1)  // did kernel kill child?
    2120:	fbc42783          	lw	a5,-68(s0)
    2124:	05579d63          	bne	a5,s5,217e <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2128:	94ce                	add	s1,s1,s3
    212a:	fd249ee3          	bne	s1,s2,2106 <kernmem+0x2a>
}
    212e:	60a6                	ld	ra,72(sp)
    2130:	6406                	ld	s0,64(sp)
    2132:	74e2                	ld	s1,56(sp)
    2134:	7942                	ld	s2,48(sp)
    2136:	79a2                	ld	s3,40(sp)
    2138:	7a02                	ld	s4,32(sp)
    213a:	6ae2                	ld	s5,24(sp)
    213c:	6161                	addi	sp,sp,80
    213e:	8082                	ret
      printf("%s: fork failed\n", s);
    2140:	85d2                	mv	a1,s4
    2142:	00004517          	auipc	a0,0x4
    2146:	60650513          	addi	a0,a0,1542 # 6748 <statistics+0xc1c>
    214a:	00004097          	auipc	ra,0x4
    214e:	840080e7          	jalr	-1984(ra) # 598a <printf>
      exit(1);
    2152:	4505                	li	a0,1
    2154:	00003097          	auipc	ra,0x3
    2158:	4be080e7          	jalr	1214(ra) # 5612 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    215c:	0004c683          	lbu	a3,0(s1)
    2160:	8626                	mv	a2,s1
    2162:	85d2                	mv	a1,s4
    2164:	00005517          	auipc	a0,0x5
    2168:	8cc50513          	addi	a0,a0,-1844 # 6a30 <statistics+0xf04>
    216c:	00004097          	auipc	ra,0x4
    2170:	81e080e7          	jalr	-2018(ra) # 598a <printf>
      exit(1);
    2174:	4505                	li	a0,1
    2176:	00003097          	auipc	ra,0x3
    217a:	49c080e7          	jalr	1180(ra) # 5612 <exit>
      exit(1);
    217e:	4505                	li	a0,1
    2180:	00003097          	auipc	ra,0x3
    2184:	492080e7          	jalr	1170(ra) # 5612 <exit>

0000000000002188 <bigargtest>:
{
    2188:	7179                	addi	sp,sp,-48
    218a:	f406                	sd	ra,40(sp)
    218c:	f022                	sd	s0,32(sp)
    218e:	ec26                	sd	s1,24(sp)
    2190:	1800                	addi	s0,sp,48
    2192:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2194:	00005517          	auipc	a0,0x5
    2198:	8bc50513          	addi	a0,a0,-1860 # 6a50 <statistics+0xf24>
    219c:	00003097          	auipc	ra,0x3
    21a0:	4c6080e7          	jalr	1222(ra) # 5662 <unlink>
  pid = fork();
    21a4:	00003097          	auipc	ra,0x3
    21a8:	466080e7          	jalr	1126(ra) # 560a <fork>
  if(pid == 0){
    21ac:	c121                	beqz	a0,21ec <bigargtest+0x64>
  } else if(pid < 0){
    21ae:	0a054063          	bltz	a0,224e <bigargtest+0xc6>
  wait(&xstatus);
    21b2:	fdc40513          	addi	a0,s0,-36
    21b6:	00003097          	auipc	ra,0x3
    21ba:	464080e7          	jalr	1124(ra) # 561a <wait>
  if(xstatus != 0)
    21be:	fdc42503          	lw	a0,-36(s0)
    21c2:	e545                	bnez	a0,226a <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    21c4:	4581                	li	a1,0
    21c6:	00005517          	auipc	a0,0x5
    21ca:	88a50513          	addi	a0,a0,-1910 # 6a50 <statistics+0xf24>
    21ce:	00003097          	auipc	ra,0x3
    21d2:	484080e7          	jalr	1156(ra) # 5652 <open>
  if(fd < 0){
    21d6:	08054e63          	bltz	a0,2272 <bigargtest+0xea>
  close(fd);
    21da:	00003097          	auipc	ra,0x3
    21de:	460080e7          	jalr	1120(ra) # 563a <close>
}
    21e2:	70a2                	ld	ra,40(sp)
    21e4:	7402                	ld	s0,32(sp)
    21e6:	64e2                	ld	s1,24(sp)
    21e8:	6145                	addi	sp,sp,48
    21ea:	8082                	ret
    21ec:	00006797          	auipc	a5,0x6
    21f0:	14c78793          	addi	a5,a5,332 # 8338 <args.1838>
    21f4:	00006697          	auipc	a3,0x6
    21f8:	23c68693          	addi	a3,a3,572 # 8430 <args.1838+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    21fc:	00005717          	auipc	a4,0x5
    2200:	86470713          	addi	a4,a4,-1948 # 6a60 <statistics+0xf34>
    2204:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    2206:	07a1                	addi	a5,a5,8
    2208:	fed79ee3          	bne	a5,a3,2204 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    220c:	00006597          	auipc	a1,0x6
    2210:	12c58593          	addi	a1,a1,300 # 8338 <args.1838>
    2214:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2218:	00004517          	auipc	a0,0x4
    221c:	cf850513          	addi	a0,a0,-776 # 5f10 <statistics+0x3e4>
    2220:	00003097          	auipc	ra,0x3
    2224:	42a080e7          	jalr	1066(ra) # 564a <exec>
    fd = open("bigarg-ok", O_CREATE);
    2228:	20000593          	li	a1,512
    222c:	00005517          	auipc	a0,0x5
    2230:	82450513          	addi	a0,a0,-2012 # 6a50 <statistics+0xf24>
    2234:	00003097          	auipc	ra,0x3
    2238:	41e080e7          	jalr	1054(ra) # 5652 <open>
    close(fd);
    223c:	00003097          	auipc	ra,0x3
    2240:	3fe080e7          	jalr	1022(ra) # 563a <close>
    exit(0);
    2244:	4501                	li	a0,0
    2246:	00003097          	auipc	ra,0x3
    224a:	3cc080e7          	jalr	972(ra) # 5612 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    224e:	85a6                	mv	a1,s1
    2250:	00005517          	auipc	a0,0x5
    2254:	8f050513          	addi	a0,a0,-1808 # 6b40 <statistics+0x1014>
    2258:	00003097          	auipc	ra,0x3
    225c:	732080e7          	jalr	1842(ra) # 598a <printf>
    exit(1);
    2260:	4505                	li	a0,1
    2262:	00003097          	auipc	ra,0x3
    2266:	3b0080e7          	jalr	944(ra) # 5612 <exit>
    exit(xstatus);
    226a:	00003097          	auipc	ra,0x3
    226e:	3a8080e7          	jalr	936(ra) # 5612 <exit>
    printf("%s: bigarg test failed!\n", s);
    2272:	85a6                	mv	a1,s1
    2274:	00005517          	auipc	a0,0x5
    2278:	8ec50513          	addi	a0,a0,-1812 # 6b60 <statistics+0x1034>
    227c:	00003097          	auipc	ra,0x3
    2280:	70e080e7          	jalr	1806(ra) # 598a <printf>
    exit(1);
    2284:	4505                	li	a0,1
    2286:	00003097          	auipc	ra,0x3
    228a:	38c080e7          	jalr	908(ra) # 5612 <exit>

000000000000228e <stacktest>:
{
    228e:	7179                	addi	sp,sp,-48
    2290:	f406                	sd	ra,40(sp)
    2292:	f022                	sd	s0,32(sp)
    2294:	ec26                	sd	s1,24(sp)
    2296:	1800                	addi	s0,sp,48
    2298:	84aa                	mv	s1,a0
  pid = fork();
    229a:	00003097          	auipc	ra,0x3
    229e:	370080e7          	jalr	880(ra) # 560a <fork>
  if(pid == 0) {
    22a2:	c115                	beqz	a0,22c6 <stacktest+0x38>
  } else if(pid < 0){
    22a4:	04054463          	bltz	a0,22ec <stacktest+0x5e>
  wait(&xstatus);
    22a8:	fdc40513          	addi	a0,s0,-36
    22ac:	00003097          	auipc	ra,0x3
    22b0:	36e080e7          	jalr	878(ra) # 561a <wait>
  if(xstatus == -1)  // kernel killed child?
    22b4:	fdc42503          	lw	a0,-36(s0)
    22b8:	57fd                	li	a5,-1
    22ba:	04f50763          	beq	a0,a5,2308 <stacktest+0x7a>
    exit(xstatus);
    22be:	00003097          	auipc	ra,0x3
    22c2:	354080e7          	jalr	852(ra) # 5612 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    22c6:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    22c8:	77fd                	lui	a5,0xfffff
    22ca:	97ba                	add	a5,a5,a4
    22cc:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff04a0>
    22d0:	85a6                	mv	a1,s1
    22d2:	00005517          	auipc	a0,0x5
    22d6:	8ae50513          	addi	a0,a0,-1874 # 6b80 <statistics+0x1054>
    22da:	00003097          	auipc	ra,0x3
    22de:	6b0080e7          	jalr	1712(ra) # 598a <printf>
    exit(1);
    22e2:	4505                	li	a0,1
    22e4:	00003097          	auipc	ra,0x3
    22e8:	32e080e7          	jalr	814(ra) # 5612 <exit>
    printf("%s: fork failed\n", s);
    22ec:	85a6                	mv	a1,s1
    22ee:	00004517          	auipc	a0,0x4
    22f2:	45a50513          	addi	a0,a0,1114 # 6748 <statistics+0xc1c>
    22f6:	00003097          	auipc	ra,0x3
    22fa:	694080e7          	jalr	1684(ra) # 598a <printf>
    exit(1);
    22fe:	4505                	li	a0,1
    2300:	00003097          	auipc	ra,0x3
    2304:	312080e7          	jalr	786(ra) # 5612 <exit>
    exit(0);
    2308:	4501                	li	a0,0
    230a:	00003097          	auipc	ra,0x3
    230e:	308080e7          	jalr	776(ra) # 5612 <exit>

0000000000002312 <copyinstr3>:
{
    2312:	7179                	addi	sp,sp,-48
    2314:	f406                	sd	ra,40(sp)
    2316:	f022                	sd	s0,32(sp)
    2318:	ec26                	sd	s1,24(sp)
    231a:	1800                	addi	s0,sp,48
  sbrk(8192);
    231c:	6509                	lui	a0,0x2
    231e:	00003097          	auipc	ra,0x3
    2322:	37c080e7          	jalr	892(ra) # 569a <sbrk>
  uint64 top = (uint64) sbrk(0);
    2326:	4501                	li	a0,0
    2328:	00003097          	auipc	ra,0x3
    232c:	372080e7          	jalr	882(ra) # 569a <sbrk>
  if((top % PGSIZE) != 0){
    2330:	03451793          	slli	a5,a0,0x34
    2334:	e3c9                	bnez	a5,23b6 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2336:	4501                	li	a0,0
    2338:	00003097          	auipc	ra,0x3
    233c:	362080e7          	jalr	866(ra) # 569a <sbrk>
  if(top % PGSIZE){
    2340:	03451793          	slli	a5,a0,0x34
    2344:	e3d9                	bnez	a5,23ca <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2346:	fff50493          	addi	s1,a0,-1 # 1fff <forktest+0x3>
  *b = 'x';
    234a:	07800793          	li	a5,120
    234e:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2352:	8526                	mv	a0,s1
    2354:	00003097          	auipc	ra,0x3
    2358:	30e080e7          	jalr	782(ra) # 5662 <unlink>
  if(ret != -1){
    235c:	57fd                	li	a5,-1
    235e:	08f51363          	bne	a0,a5,23e4 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2362:	20100593          	li	a1,513
    2366:	8526                	mv	a0,s1
    2368:	00003097          	auipc	ra,0x3
    236c:	2ea080e7          	jalr	746(ra) # 5652 <open>
  if(fd != -1){
    2370:	57fd                	li	a5,-1
    2372:	08f51863          	bne	a0,a5,2402 <copyinstr3+0xf0>
  ret = link(b, b);
    2376:	85a6                	mv	a1,s1
    2378:	8526                	mv	a0,s1
    237a:	00003097          	auipc	ra,0x3
    237e:	2f8080e7          	jalr	760(ra) # 5672 <link>
  if(ret != -1){
    2382:	57fd                	li	a5,-1
    2384:	08f51e63          	bne	a0,a5,2420 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2388:	00005797          	auipc	a5,0x5
    238c:	49078793          	addi	a5,a5,1168 # 7818 <statistics+0x1cec>
    2390:	fcf43823          	sd	a5,-48(s0)
    2394:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2398:	fd040593          	addi	a1,s0,-48
    239c:	8526                	mv	a0,s1
    239e:	00003097          	auipc	ra,0x3
    23a2:	2ac080e7          	jalr	684(ra) # 564a <exec>
  if(ret != -1){
    23a6:	57fd                	li	a5,-1
    23a8:	08f51c63          	bne	a0,a5,2440 <copyinstr3+0x12e>
}
    23ac:	70a2                	ld	ra,40(sp)
    23ae:	7402                	ld	s0,32(sp)
    23b0:	64e2                	ld	s1,24(sp)
    23b2:	6145                	addi	sp,sp,48
    23b4:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    23b6:	0347d513          	srli	a0,a5,0x34
    23ba:	6785                	lui	a5,0x1
    23bc:	40a7853b          	subw	a0,a5,a0
    23c0:	00003097          	auipc	ra,0x3
    23c4:	2da080e7          	jalr	730(ra) # 569a <sbrk>
    23c8:	b7bd                	j	2336 <copyinstr3+0x24>
    printf("oops\n");
    23ca:	00004517          	auipc	a0,0x4
    23ce:	7de50513          	addi	a0,a0,2014 # 6ba8 <statistics+0x107c>
    23d2:	00003097          	auipc	ra,0x3
    23d6:	5b8080e7          	jalr	1464(ra) # 598a <printf>
    exit(1);
    23da:	4505                	li	a0,1
    23dc:	00003097          	auipc	ra,0x3
    23e0:	236080e7          	jalr	566(ra) # 5612 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    23e4:	862a                	mv	a2,a0
    23e6:	85a6                	mv	a1,s1
    23e8:	00004517          	auipc	a0,0x4
    23ec:	28050513          	addi	a0,a0,640 # 6668 <statistics+0xb3c>
    23f0:	00003097          	auipc	ra,0x3
    23f4:	59a080e7          	jalr	1434(ra) # 598a <printf>
    exit(1);
    23f8:	4505                	li	a0,1
    23fa:	00003097          	auipc	ra,0x3
    23fe:	218080e7          	jalr	536(ra) # 5612 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2402:	862a                	mv	a2,a0
    2404:	85a6                	mv	a1,s1
    2406:	00004517          	auipc	a0,0x4
    240a:	28250513          	addi	a0,a0,642 # 6688 <statistics+0xb5c>
    240e:	00003097          	auipc	ra,0x3
    2412:	57c080e7          	jalr	1404(ra) # 598a <printf>
    exit(1);
    2416:	4505                	li	a0,1
    2418:	00003097          	auipc	ra,0x3
    241c:	1fa080e7          	jalr	506(ra) # 5612 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2420:	86aa                	mv	a3,a0
    2422:	8626                	mv	a2,s1
    2424:	85a6                	mv	a1,s1
    2426:	00004517          	auipc	a0,0x4
    242a:	28250513          	addi	a0,a0,642 # 66a8 <statistics+0xb7c>
    242e:	00003097          	auipc	ra,0x3
    2432:	55c080e7          	jalr	1372(ra) # 598a <printf>
    exit(1);
    2436:	4505                	li	a0,1
    2438:	00003097          	auipc	ra,0x3
    243c:	1da080e7          	jalr	474(ra) # 5612 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2440:	567d                	li	a2,-1
    2442:	85a6                	mv	a1,s1
    2444:	00004517          	auipc	a0,0x4
    2448:	28c50513          	addi	a0,a0,652 # 66d0 <statistics+0xba4>
    244c:	00003097          	auipc	ra,0x3
    2450:	53e080e7          	jalr	1342(ra) # 598a <printf>
    exit(1);
    2454:	4505                	li	a0,1
    2456:	00003097          	auipc	ra,0x3
    245a:	1bc080e7          	jalr	444(ra) # 5612 <exit>

000000000000245e <rwsbrk>:
{
    245e:	1101                	addi	sp,sp,-32
    2460:	ec06                	sd	ra,24(sp)
    2462:	e822                	sd	s0,16(sp)
    2464:	e426                	sd	s1,8(sp)
    2466:	e04a                	sd	s2,0(sp)
    2468:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    246a:	6509                	lui	a0,0x2
    246c:	00003097          	auipc	ra,0x3
    2470:	22e080e7          	jalr	558(ra) # 569a <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2474:	57fd                	li	a5,-1
    2476:	06f50363          	beq	a0,a5,24dc <rwsbrk+0x7e>
    247a:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    247c:	7579                	lui	a0,0xffffe
    247e:	00003097          	auipc	ra,0x3
    2482:	21c080e7          	jalr	540(ra) # 569a <sbrk>
    2486:	57fd                	li	a5,-1
    2488:	06f50763          	beq	a0,a5,24f6 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    248c:	20100593          	li	a1,513
    2490:	00003517          	auipc	a0,0x3
    2494:	7a050513          	addi	a0,a0,1952 # 5c30 <statistics+0x104>
    2498:	00003097          	auipc	ra,0x3
    249c:	1ba080e7          	jalr	442(ra) # 5652 <open>
    24a0:	892a                	mv	s2,a0
  if(fd < 0){
    24a2:	06054763          	bltz	a0,2510 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    24a6:	6505                	lui	a0,0x1
    24a8:	94aa                	add	s1,s1,a0
    24aa:	40000613          	li	a2,1024
    24ae:	85a6                	mv	a1,s1
    24b0:	854a                	mv	a0,s2
    24b2:	00003097          	auipc	ra,0x3
    24b6:	180080e7          	jalr	384(ra) # 5632 <write>
    24ba:	862a                	mv	a2,a0
  if(n >= 0){
    24bc:	06054763          	bltz	a0,252a <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    24c0:	85a6                	mv	a1,s1
    24c2:	00004517          	auipc	a0,0x4
    24c6:	73e50513          	addi	a0,a0,1854 # 6c00 <statistics+0x10d4>
    24ca:	00003097          	auipc	ra,0x3
    24ce:	4c0080e7          	jalr	1216(ra) # 598a <printf>
    exit(1);
    24d2:	4505                	li	a0,1
    24d4:	00003097          	auipc	ra,0x3
    24d8:	13e080e7          	jalr	318(ra) # 5612 <exit>
    printf("sbrk(rwsbrk) failed\n");
    24dc:	00004517          	auipc	a0,0x4
    24e0:	6d450513          	addi	a0,a0,1748 # 6bb0 <statistics+0x1084>
    24e4:	00003097          	auipc	ra,0x3
    24e8:	4a6080e7          	jalr	1190(ra) # 598a <printf>
    exit(1);
    24ec:	4505                	li	a0,1
    24ee:	00003097          	auipc	ra,0x3
    24f2:	124080e7          	jalr	292(ra) # 5612 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    24f6:	00004517          	auipc	a0,0x4
    24fa:	6d250513          	addi	a0,a0,1746 # 6bc8 <statistics+0x109c>
    24fe:	00003097          	auipc	ra,0x3
    2502:	48c080e7          	jalr	1164(ra) # 598a <printf>
    exit(1);
    2506:	4505                	li	a0,1
    2508:	00003097          	auipc	ra,0x3
    250c:	10a080e7          	jalr	266(ra) # 5612 <exit>
    printf("open(rwsbrk) failed\n");
    2510:	00004517          	auipc	a0,0x4
    2514:	6d850513          	addi	a0,a0,1752 # 6be8 <statistics+0x10bc>
    2518:	00003097          	auipc	ra,0x3
    251c:	472080e7          	jalr	1138(ra) # 598a <printf>
    exit(1);
    2520:	4505                	li	a0,1
    2522:	00003097          	auipc	ra,0x3
    2526:	0f0080e7          	jalr	240(ra) # 5612 <exit>
  close(fd);
    252a:	854a                	mv	a0,s2
    252c:	00003097          	auipc	ra,0x3
    2530:	10e080e7          	jalr	270(ra) # 563a <close>
  unlink("rwsbrk");
    2534:	00003517          	auipc	a0,0x3
    2538:	6fc50513          	addi	a0,a0,1788 # 5c30 <statistics+0x104>
    253c:	00003097          	auipc	ra,0x3
    2540:	126080e7          	jalr	294(ra) # 5662 <unlink>
  fd = open("README", O_RDONLY);
    2544:	4581                	li	a1,0
    2546:	00004517          	auipc	a0,0x4
    254a:	b6250513          	addi	a0,a0,-1182 # 60a8 <statistics+0x57c>
    254e:	00003097          	auipc	ra,0x3
    2552:	104080e7          	jalr	260(ra) # 5652 <open>
    2556:	892a                	mv	s2,a0
  if(fd < 0){
    2558:	02054963          	bltz	a0,258a <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    255c:	4629                	li	a2,10
    255e:	85a6                	mv	a1,s1
    2560:	00003097          	auipc	ra,0x3
    2564:	0ca080e7          	jalr	202(ra) # 562a <read>
    2568:	862a                	mv	a2,a0
  if(n >= 0){
    256a:	02054d63          	bltz	a0,25a4 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    256e:	85a6                	mv	a1,s1
    2570:	00004517          	auipc	a0,0x4
    2574:	6c050513          	addi	a0,a0,1728 # 6c30 <statistics+0x1104>
    2578:	00003097          	auipc	ra,0x3
    257c:	412080e7          	jalr	1042(ra) # 598a <printf>
    exit(1);
    2580:	4505                	li	a0,1
    2582:	00003097          	auipc	ra,0x3
    2586:	090080e7          	jalr	144(ra) # 5612 <exit>
    printf("open(rwsbrk) failed\n");
    258a:	00004517          	auipc	a0,0x4
    258e:	65e50513          	addi	a0,a0,1630 # 6be8 <statistics+0x10bc>
    2592:	00003097          	auipc	ra,0x3
    2596:	3f8080e7          	jalr	1016(ra) # 598a <printf>
    exit(1);
    259a:	4505                	li	a0,1
    259c:	00003097          	auipc	ra,0x3
    25a0:	076080e7          	jalr	118(ra) # 5612 <exit>
  close(fd);
    25a4:	854a                	mv	a0,s2
    25a6:	00003097          	auipc	ra,0x3
    25aa:	094080e7          	jalr	148(ra) # 563a <close>
  exit(0);
    25ae:	4501                	li	a0,0
    25b0:	00003097          	auipc	ra,0x3
    25b4:	062080e7          	jalr	98(ra) # 5612 <exit>

00000000000025b8 <sbrkbasic>:
{
    25b8:	7139                	addi	sp,sp,-64
    25ba:	fc06                	sd	ra,56(sp)
    25bc:	f822                	sd	s0,48(sp)
    25be:	f426                	sd	s1,40(sp)
    25c0:	f04a                	sd	s2,32(sp)
    25c2:	ec4e                	sd	s3,24(sp)
    25c4:	e852                	sd	s4,16(sp)
    25c6:	0080                	addi	s0,sp,64
    25c8:	8a2a                	mv	s4,a0
  pid = fork();
    25ca:	00003097          	auipc	ra,0x3
    25ce:	040080e7          	jalr	64(ra) # 560a <fork>
  if(pid < 0){
    25d2:	02054c63          	bltz	a0,260a <sbrkbasic+0x52>
  if(pid == 0){
    25d6:	ed21                	bnez	a0,262e <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    25d8:	40000537          	lui	a0,0x40000
    25dc:	00003097          	auipc	ra,0x3
    25e0:	0be080e7          	jalr	190(ra) # 569a <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    25e4:	57fd                	li	a5,-1
    25e6:	02f50f63          	beq	a0,a5,2624 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25ea:	400007b7          	lui	a5,0x40000
    25ee:	97aa                	add	a5,a5,a0
      *b = 99;
    25f0:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    25f4:	6705                	lui	a4,0x1
      *b = 99;
    25f6:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff14a0>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25fa:	953a                	add	a0,a0,a4
    25fc:	fef51de3          	bne	a0,a5,25f6 <sbrkbasic+0x3e>
    exit(1);
    2600:	4505                	li	a0,1
    2602:	00003097          	auipc	ra,0x3
    2606:	010080e7          	jalr	16(ra) # 5612 <exit>
    printf("fork failed in sbrkbasic\n");
    260a:	00004517          	auipc	a0,0x4
    260e:	64e50513          	addi	a0,a0,1614 # 6c58 <statistics+0x112c>
    2612:	00003097          	auipc	ra,0x3
    2616:	378080e7          	jalr	888(ra) # 598a <printf>
    exit(1);
    261a:	4505                	li	a0,1
    261c:	00003097          	auipc	ra,0x3
    2620:	ff6080e7          	jalr	-10(ra) # 5612 <exit>
      exit(0);
    2624:	4501                	li	a0,0
    2626:	00003097          	auipc	ra,0x3
    262a:	fec080e7          	jalr	-20(ra) # 5612 <exit>
  wait(&xstatus);
    262e:	fcc40513          	addi	a0,s0,-52
    2632:	00003097          	auipc	ra,0x3
    2636:	fe8080e7          	jalr	-24(ra) # 561a <wait>
  if(xstatus == 1){
    263a:	fcc42703          	lw	a4,-52(s0)
    263e:	4785                	li	a5,1
    2640:	00f70d63          	beq	a4,a5,265a <sbrkbasic+0xa2>
  a = sbrk(0);
    2644:	4501                	li	a0,0
    2646:	00003097          	auipc	ra,0x3
    264a:	054080e7          	jalr	84(ra) # 569a <sbrk>
    264e:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2650:	4901                	li	s2,0
    2652:	6985                	lui	s3,0x1
    2654:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1d6>
    2658:	a005                	j	2678 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    265a:	85d2                	mv	a1,s4
    265c:	00004517          	auipc	a0,0x4
    2660:	61c50513          	addi	a0,a0,1564 # 6c78 <statistics+0x114c>
    2664:	00003097          	auipc	ra,0x3
    2668:	326080e7          	jalr	806(ra) # 598a <printf>
    exit(1);
    266c:	4505                	li	a0,1
    266e:	00003097          	auipc	ra,0x3
    2672:	fa4080e7          	jalr	-92(ra) # 5612 <exit>
    a = b + 1;
    2676:	84be                	mv	s1,a5
    b = sbrk(1);
    2678:	4505                	li	a0,1
    267a:	00003097          	auipc	ra,0x3
    267e:	020080e7          	jalr	32(ra) # 569a <sbrk>
    if(b != a){
    2682:	04951c63          	bne	a0,s1,26da <sbrkbasic+0x122>
    *b = 1;
    2686:	4785                	li	a5,1
    2688:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    268c:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2690:	2905                	addiw	s2,s2,1
    2692:	ff3912e3          	bne	s2,s3,2676 <sbrkbasic+0xbe>
  pid = fork();
    2696:	00003097          	auipc	ra,0x3
    269a:	f74080e7          	jalr	-140(ra) # 560a <fork>
    269e:	892a                	mv	s2,a0
  if(pid < 0){
    26a0:	04054d63          	bltz	a0,26fa <sbrkbasic+0x142>
  c = sbrk(1);
    26a4:	4505                	li	a0,1
    26a6:	00003097          	auipc	ra,0x3
    26aa:	ff4080e7          	jalr	-12(ra) # 569a <sbrk>
  c = sbrk(1);
    26ae:	4505                	li	a0,1
    26b0:	00003097          	auipc	ra,0x3
    26b4:	fea080e7          	jalr	-22(ra) # 569a <sbrk>
  if(c != a + 1){
    26b8:	0489                	addi	s1,s1,2
    26ba:	04a48e63          	beq	s1,a0,2716 <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    26be:	85d2                	mv	a1,s4
    26c0:	00004517          	auipc	a0,0x4
    26c4:	61850513          	addi	a0,a0,1560 # 6cd8 <statistics+0x11ac>
    26c8:	00003097          	auipc	ra,0x3
    26cc:	2c2080e7          	jalr	706(ra) # 598a <printf>
    exit(1);
    26d0:	4505                	li	a0,1
    26d2:	00003097          	auipc	ra,0x3
    26d6:	f40080e7          	jalr	-192(ra) # 5612 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    26da:	86aa                	mv	a3,a0
    26dc:	8626                	mv	a2,s1
    26de:	85ca                	mv	a1,s2
    26e0:	00004517          	auipc	a0,0x4
    26e4:	5b850513          	addi	a0,a0,1464 # 6c98 <statistics+0x116c>
    26e8:	00003097          	auipc	ra,0x3
    26ec:	2a2080e7          	jalr	674(ra) # 598a <printf>
      exit(1);
    26f0:	4505                	li	a0,1
    26f2:	00003097          	auipc	ra,0x3
    26f6:	f20080e7          	jalr	-224(ra) # 5612 <exit>
    printf("%s: sbrk test fork failed\n", s);
    26fa:	85d2                	mv	a1,s4
    26fc:	00004517          	auipc	a0,0x4
    2700:	5bc50513          	addi	a0,a0,1468 # 6cb8 <statistics+0x118c>
    2704:	00003097          	auipc	ra,0x3
    2708:	286080e7          	jalr	646(ra) # 598a <printf>
    exit(1);
    270c:	4505                	li	a0,1
    270e:	00003097          	auipc	ra,0x3
    2712:	f04080e7          	jalr	-252(ra) # 5612 <exit>
  if(pid == 0)
    2716:	00091763          	bnez	s2,2724 <sbrkbasic+0x16c>
    exit(0);
    271a:	4501                	li	a0,0
    271c:	00003097          	auipc	ra,0x3
    2720:	ef6080e7          	jalr	-266(ra) # 5612 <exit>
  wait(&xstatus);
    2724:	fcc40513          	addi	a0,s0,-52
    2728:	00003097          	auipc	ra,0x3
    272c:	ef2080e7          	jalr	-270(ra) # 561a <wait>
  exit(xstatus);
    2730:	fcc42503          	lw	a0,-52(s0)
    2734:	00003097          	auipc	ra,0x3
    2738:	ede080e7          	jalr	-290(ra) # 5612 <exit>

000000000000273c <sbrkmuch>:
{
    273c:	7179                	addi	sp,sp,-48
    273e:	f406                	sd	ra,40(sp)
    2740:	f022                	sd	s0,32(sp)
    2742:	ec26                	sd	s1,24(sp)
    2744:	e84a                	sd	s2,16(sp)
    2746:	e44e                	sd	s3,8(sp)
    2748:	e052                	sd	s4,0(sp)
    274a:	1800                	addi	s0,sp,48
    274c:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    274e:	4501                	li	a0,0
    2750:	00003097          	auipc	ra,0x3
    2754:	f4a080e7          	jalr	-182(ra) # 569a <sbrk>
    2758:	892a                	mv	s2,a0
  a = sbrk(0);
    275a:	4501                	li	a0,0
    275c:	00003097          	auipc	ra,0x3
    2760:	f3e080e7          	jalr	-194(ra) # 569a <sbrk>
    2764:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2766:	06400537          	lui	a0,0x6400
    276a:	9d05                	subw	a0,a0,s1
    276c:	00003097          	auipc	ra,0x3
    2770:	f2e080e7          	jalr	-210(ra) # 569a <sbrk>
  if (p != a) {
    2774:	0ca49863          	bne	s1,a0,2844 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2778:	4501                	li	a0,0
    277a:	00003097          	auipc	ra,0x3
    277e:	f20080e7          	jalr	-224(ra) # 569a <sbrk>
    2782:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2784:	00a4f963          	bgeu	s1,a0,2796 <sbrkmuch+0x5a>
    *pp = 1;
    2788:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    278a:	6705                	lui	a4,0x1
    *pp = 1;
    278c:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2790:	94ba                	add	s1,s1,a4
    2792:	fef4ede3          	bltu	s1,a5,278c <sbrkmuch+0x50>
  *lastaddr = 99;
    2796:	064007b7          	lui	a5,0x6400
    279a:	06300713          	li	a4,99
    279e:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f149f>
  a = sbrk(0);
    27a2:	4501                	li	a0,0
    27a4:	00003097          	auipc	ra,0x3
    27a8:	ef6080e7          	jalr	-266(ra) # 569a <sbrk>
    27ac:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    27ae:	757d                	lui	a0,0xfffff
    27b0:	00003097          	auipc	ra,0x3
    27b4:	eea080e7          	jalr	-278(ra) # 569a <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    27b8:	57fd                	li	a5,-1
    27ba:	0af50363          	beq	a0,a5,2860 <sbrkmuch+0x124>
  c = sbrk(0);
    27be:	4501                	li	a0,0
    27c0:	00003097          	auipc	ra,0x3
    27c4:	eda080e7          	jalr	-294(ra) # 569a <sbrk>
  if(c != a - PGSIZE){
    27c8:	77fd                	lui	a5,0xfffff
    27ca:	97a6                	add	a5,a5,s1
    27cc:	0af51863          	bne	a0,a5,287c <sbrkmuch+0x140>
  a = sbrk(0);
    27d0:	4501                	li	a0,0
    27d2:	00003097          	auipc	ra,0x3
    27d6:	ec8080e7          	jalr	-312(ra) # 569a <sbrk>
    27da:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    27dc:	6505                	lui	a0,0x1
    27de:	00003097          	auipc	ra,0x3
    27e2:	ebc080e7          	jalr	-324(ra) # 569a <sbrk>
    27e6:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    27e8:	0aa49a63          	bne	s1,a0,289c <sbrkmuch+0x160>
    27ec:	4501                	li	a0,0
    27ee:	00003097          	auipc	ra,0x3
    27f2:	eac080e7          	jalr	-340(ra) # 569a <sbrk>
    27f6:	6785                	lui	a5,0x1
    27f8:	97a6                	add	a5,a5,s1
    27fa:	0af51163          	bne	a0,a5,289c <sbrkmuch+0x160>
  if(*lastaddr == 99){
    27fe:	064007b7          	lui	a5,0x6400
    2802:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f149f>
    2806:	06300793          	li	a5,99
    280a:	0af70963          	beq	a4,a5,28bc <sbrkmuch+0x180>
  a = sbrk(0);
    280e:	4501                	li	a0,0
    2810:	00003097          	auipc	ra,0x3
    2814:	e8a080e7          	jalr	-374(ra) # 569a <sbrk>
    2818:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    281a:	4501                	li	a0,0
    281c:	00003097          	auipc	ra,0x3
    2820:	e7e080e7          	jalr	-386(ra) # 569a <sbrk>
    2824:	40a9053b          	subw	a0,s2,a0
    2828:	00003097          	auipc	ra,0x3
    282c:	e72080e7          	jalr	-398(ra) # 569a <sbrk>
  if(c != a){
    2830:	0aa49463          	bne	s1,a0,28d8 <sbrkmuch+0x19c>
}
    2834:	70a2                	ld	ra,40(sp)
    2836:	7402                	ld	s0,32(sp)
    2838:	64e2                	ld	s1,24(sp)
    283a:	6942                	ld	s2,16(sp)
    283c:	69a2                	ld	s3,8(sp)
    283e:	6a02                	ld	s4,0(sp)
    2840:	6145                	addi	sp,sp,48
    2842:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2844:	85ce                	mv	a1,s3
    2846:	00004517          	auipc	a0,0x4
    284a:	4b250513          	addi	a0,a0,1202 # 6cf8 <statistics+0x11cc>
    284e:	00003097          	auipc	ra,0x3
    2852:	13c080e7          	jalr	316(ra) # 598a <printf>
    exit(1);
    2856:	4505                	li	a0,1
    2858:	00003097          	auipc	ra,0x3
    285c:	dba080e7          	jalr	-582(ra) # 5612 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2860:	85ce                	mv	a1,s3
    2862:	00004517          	auipc	a0,0x4
    2866:	4de50513          	addi	a0,a0,1246 # 6d40 <statistics+0x1214>
    286a:	00003097          	auipc	ra,0x3
    286e:	120080e7          	jalr	288(ra) # 598a <printf>
    exit(1);
    2872:	4505                	li	a0,1
    2874:	00003097          	auipc	ra,0x3
    2878:	d9e080e7          	jalr	-610(ra) # 5612 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    287c:	86aa                	mv	a3,a0
    287e:	8626                	mv	a2,s1
    2880:	85ce                	mv	a1,s3
    2882:	00004517          	auipc	a0,0x4
    2886:	4de50513          	addi	a0,a0,1246 # 6d60 <statistics+0x1234>
    288a:	00003097          	auipc	ra,0x3
    288e:	100080e7          	jalr	256(ra) # 598a <printf>
    exit(1);
    2892:	4505                	li	a0,1
    2894:	00003097          	auipc	ra,0x3
    2898:	d7e080e7          	jalr	-642(ra) # 5612 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    289c:	86d2                	mv	a3,s4
    289e:	8626                	mv	a2,s1
    28a0:	85ce                	mv	a1,s3
    28a2:	00004517          	auipc	a0,0x4
    28a6:	4fe50513          	addi	a0,a0,1278 # 6da0 <statistics+0x1274>
    28aa:	00003097          	auipc	ra,0x3
    28ae:	0e0080e7          	jalr	224(ra) # 598a <printf>
    exit(1);
    28b2:	4505                	li	a0,1
    28b4:	00003097          	auipc	ra,0x3
    28b8:	d5e080e7          	jalr	-674(ra) # 5612 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    28bc:	85ce                	mv	a1,s3
    28be:	00004517          	auipc	a0,0x4
    28c2:	51250513          	addi	a0,a0,1298 # 6dd0 <statistics+0x12a4>
    28c6:	00003097          	auipc	ra,0x3
    28ca:	0c4080e7          	jalr	196(ra) # 598a <printf>
    exit(1);
    28ce:	4505                	li	a0,1
    28d0:	00003097          	auipc	ra,0x3
    28d4:	d42080e7          	jalr	-702(ra) # 5612 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    28d8:	86aa                	mv	a3,a0
    28da:	8626                	mv	a2,s1
    28dc:	85ce                	mv	a1,s3
    28de:	00004517          	auipc	a0,0x4
    28e2:	52a50513          	addi	a0,a0,1322 # 6e08 <statistics+0x12dc>
    28e6:	00003097          	auipc	ra,0x3
    28ea:	0a4080e7          	jalr	164(ra) # 598a <printf>
    exit(1);
    28ee:	4505                	li	a0,1
    28f0:	00003097          	auipc	ra,0x3
    28f4:	d22080e7          	jalr	-734(ra) # 5612 <exit>

00000000000028f8 <sbrkarg>:
{
    28f8:	7179                	addi	sp,sp,-48
    28fa:	f406                	sd	ra,40(sp)
    28fc:	f022                	sd	s0,32(sp)
    28fe:	ec26                	sd	s1,24(sp)
    2900:	e84a                	sd	s2,16(sp)
    2902:	e44e                	sd	s3,8(sp)
    2904:	1800                	addi	s0,sp,48
    2906:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2908:	6505                	lui	a0,0x1
    290a:	00003097          	auipc	ra,0x3
    290e:	d90080e7          	jalr	-624(ra) # 569a <sbrk>
    2912:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2914:	20100593          	li	a1,513
    2918:	00004517          	auipc	a0,0x4
    291c:	51850513          	addi	a0,a0,1304 # 6e30 <statistics+0x1304>
    2920:	00003097          	auipc	ra,0x3
    2924:	d32080e7          	jalr	-718(ra) # 5652 <open>
    2928:	84aa                	mv	s1,a0
  unlink("sbrk");
    292a:	00004517          	auipc	a0,0x4
    292e:	50650513          	addi	a0,a0,1286 # 6e30 <statistics+0x1304>
    2932:	00003097          	auipc	ra,0x3
    2936:	d30080e7          	jalr	-720(ra) # 5662 <unlink>
  if(fd < 0)  {
    293a:	0404c163          	bltz	s1,297c <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    293e:	6605                	lui	a2,0x1
    2940:	85ca                	mv	a1,s2
    2942:	8526                	mv	a0,s1
    2944:	00003097          	auipc	ra,0x3
    2948:	cee080e7          	jalr	-786(ra) # 5632 <write>
    294c:	04054663          	bltz	a0,2998 <sbrkarg+0xa0>
  close(fd);
    2950:	8526                	mv	a0,s1
    2952:	00003097          	auipc	ra,0x3
    2956:	ce8080e7          	jalr	-792(ra) # 563a <close>
  a = sbrk(PGSIZE);
    295a:	6505                	lui	a0,0x1
    295c:	00003097          	auipc	ra,0x3
    2960:	d3e080e7          	jalr	-706(ra) # 569a <sbrk>
  if(pipe((int *) a) != 0){
    2964:	00003097          	auipc	ra,0x3
    2968:	cbe080e7          	jalr	-834(ra) # 5622 <pipe>
    296c:	e521                	bnez	a0,29b4 <sbrkarg+0xbc>
}
    296e:	70a2                	ld	ra,40(sp)
    2970:	7402                	ld	s0,32(sp)
    2972:	64e2                	ld	s1,24(sp)
    2974:	6942                	ld	s2,16(sp)
    2976:	69a2                	ld	s3,8(sp)
    2978:	6145                	addi	sp,sp,48
    297a:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    297c:	85ce                	mv	a1,s3
    297e:	00004517          	auipc	a0,0x4
    2982:	4ba50513          	addi	a0,a0,1210 # 6e38 <statistics+0x130c>
    2986:	00003097          	auipc	ra,0x3
    298a:	004080e7          	jalr	4(ra) # 598a <printf>
    exit(1);
    298e:	4505                	li	a0,1
    2990:	00003097          	auipc	ra,0x3
    2994:	c82080e7          	jalr	-894(ra) # 5612 <exit>
    printf("%s: write sbrk failed\n", s);
    2998:	85ce                	mv	a1,s3
    299a:	00004517          	auipc	a0,0x4
    299e:	4b650513          	addi	a0,a0,1206 # 6e50 <statistics+0x1324>
    29a2:	00003097          	auipc	ra,0x3
    29a6:	fe8080e7          	jalr	-24(ra) # 598a <printf>
    exit(1);
    29aa:	4505                	li	a0,1
    29ac:	00003097          	auipc	ra,0x3
    29b0:	c66080e7          	jalr	-922(ra) # 5612 <exit>
    printf("%s: pipe() failed\n", s);
    29b4:	85ce                	mv	a1,s3
    29b6:	00004517          	auipc	a0,0x4
    29ba:	e9a50513          	addi	a0,a0,-358 # 6850 <statistics+0xd24>
    29be:	00003097          	auipc	ra,0x3
    29c2:	fcc080e7          	jalr	-52(ra) # 598a <printf>
    exit(1);
    29c6:	4505                	li	a0,1
    29c8:	00003097          	auipc	ra,0x3
    29cc:	c4a080e7          	jalr	-950(ra) # 5612 <exit>

00000000000029d0 <argptest>:
{
    29d0:	1101                	addi	sp,sp,-32
    29d2:	ec06                	sd	ra,24(sp)
    29d4:	e822                	sd	s0,16(sp)
    29d6:	e426                	sd	s1,8(sp)
    29d8:	e04a                	sd	s2,0(sp)
    29da:	1000                	addi	s0,sp,32
    29dc:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    29de:	4581                	li	a1,0
    29e0:	00004517          	auipc	a0,0x4
    29e4:	48850513          	addi	a0,a0,1160 # 6e68 <statistics+0x133c>
    29e8:	00003097          	auipc	ra,0x3
    29ec:	c6a080e7          	jalr	-918(ra) # 5652 <open>
  if (fd < 0) {
    29f0:	02054b63          	bltz	a0,2a26 <argptest+0x56>
    29f4:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    29f6:	4501                	li	a0,0
    29f8:	00003097          	auipc	ra,0x3
    29fc:	ca2080e7          	jalr	-862(ra) # 569a <sbrk>
    2a00:	567d                	li	a2,-1
    2a02:	fff50593          	addi	a1,a0,-1
    2a06:	8526                	mv	a0,s1
    2a08:	00003097          	auipc	ra,0x3
    2a0c:	c22080e7          	jalr	-990(ra) # 562a <read>
  close(fd);
    2a10:	8526                	mv	a0,s1
    2a12:	00003097          	auipc	ra,0x3
    2a16:	c28080e7          	jalr	-984(ra) # 563a <close>
}
    2a1a:	60e2                	ld	ra,24(sp)
    2a1c:	6442                	ld	s0,16(sp)
    2a1e:	64a2                	ld	s1,8(sp)
    2a20:	6902                	ld	s2,0(sp)
    2a22:	6105                	addi	sp,sp,32
    2a24:	8082                	ret
    printf("%s: open failed\n", s);
    2a26:	85ca                	mv	a1,s2
    2a28:	00004517          	auipc	a0,0x4
    2a2c:	d3850513          	addi	a0,a0,-712 # 6760 <statistics+0xc34>
    2a30:	00003097          	auipc	ra,0x3
    2a34:	f5a080e7          	jalr	-166(ra) # 598a <printf>
    exit(1);
    2a38:	4505                	li	a0,1
    2a3a:	00003097          	auipc	ra,0x3
    2a3e:	bd8080e7          	jalr	-1064(ra) # 5612 <exit>

0000000000002a42 <sbrkbugs>:
{
    2a42:	1141                	addi	sp,sp,-16
    2a44:	e406                	sd	ra,8(sp)
    2a46:	e022                	sd	s0,0(sp)
    2a48:	0800                	addi	s0,sp,16
  int pid = fork();
    2a4a:	00003097          	auipc	ra,0x3
    2a4e:	bc0080e7          	jalr	-1088(ra) # 560a <fork>
  if(pid < 0){
    2a52:	02054263          	bltz	a0,2a76 <sbrkbugs+0x34>
  if(pid == 0){
    2a56:	ed0d                	bnez	a0,2a90 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2a58:	00003097          	auipc	ra,0x3
    2a5c:	c42080e7          	jalr	-958(ra) # 569a <sbrk>
    sbrk(-sz);
    2a60:	40a0053b          	negw	a0,a0
    2a64:	00003097          	auipc	ra,0x3
    2a68:	c36080e7          	jalr	-970(ra) # 569a <sbrk>
    exit(0);
    2a6c:	4501                	li	a0,0
    2a6e:	00003097          	auipc	ra,0x3
    2a72:	ba4080e7          	jalr	-1116(ra) # 5612 <exit>
    printf("fork failed\n");
    2a76:	00004517          	auipc	a0,0x4
    2a7a:	0da50513          	addi	a0,a0,218 # 6b50 <statistics+0x1024>
    2a7e:	00003097          	auipc	ra,0x3
    2a82:	f0c080e7          	jalr	-244(ra) # 598a <printf>
    exit(1);
    2a86:	4505                	li	a0,1
    2a88:	00003097          	auipc	ra,0x3
    2a8c:	b8a080e7          	jalr	-1142(ra) # 5612 <exit>
  wait(0);
    2a90:	4501                	li	a0,0
    2a92:	00003097          	auipc	ra,0x3
    2a96:	b88080e7          	jalr	-1144(ra) # 561a <wait>
  pid = fork();
    2a9a:	00003097          	auipc	ra,0x3
    2a9e:	b70080e7          	jalr	-1168(ra) # 560a <fork>
  if(pid < 0){
    2aa2:	02054563          	bltz	a0,2acc <sbrkbugs+0x8a>
  if(pid == 0){
    2aa6:	e121                	bnez	a0,2ae6 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2aa8:	00003097          	auipc	ra,0x3
    2aac:	bf2080e7          	jalr	-1038(ra) # 569a <sbrk>
    sbrk(-(sz - 3500));
    2ab0:	6785                	lui	a5,0x1
    2ab2:	dac7879b          	addiw	a5,a5,-596
    2ab6:	40a7853b          	subw	a0,a5,a0
    2aba:	00003097          	auipc	ra,0x3
    2abe:	be0080e7          	jalr	-1056(ra) # 569a <sbrk>
    exit(0);
    2ac2:	4501                	li	a0,0
    2ac4:	00003097          	auipc	ra,0x3
    2ac8:	b4e080e7          	jalr	-1202(ra) # 5612 <exit>
    printf("fork failed\n");
    2acc:	00004517          	auipc	a0,0x4
    2ad0:	08450513          	addi	a0,a0,132 # 6b50 <statistics+0x1024>
    2ad4:	00003097          	auipc	ra,0x3
    2ad8:	eb6080e7          	jalr	-330(ra) # 598a <printf>
    exit(1);
    2adc:	4505                	li	a0,1
    2ade:	00003097          	auipc	ra,0x3
    2ae2:	b34080e7          	jalr	-1228(ra) # 5612 <exit>
  wait(0);
    2ae6:	4501                	li	a0,0
    2ae8:	00003097          	auipc	ra,0x3
    2aec:	b32080e7          	jalr	-1230(ra) # 561a <wait>
  pid = fork();
    2af0:	00003097          	auipc	ra,0x3
    2af4:	b1a080e7          	jalr	-1254(ra) # 560a <fork>
  if(pid < 0){
    2af8:	02054a63          	bltz	a0,2b2c <sbrkbugs+0xea>
  if(pid == 0){
    2afc:	e529                	bnez	a0,2b46 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2afe:	00003097          	auipc	ra,0x3
    2b02:	b9c080e7          	jalr	-1124(ra) # 569a <sbrk>
    2b06:	67ad                	lui	a5,0xb
    2b08:	8007879b          	addiw	a5,a5,-2048
    2b0c:	40a7853b          	subw	a0,a5,a0
    2b10:	00003097          	auipc	ra,0x3
    2b14:	b8a080e7          	jalr	-1142(ra) # 569a <sbrk>
    sbrk(-10);
    2b18:	5559                	li	a0,-10
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	b80080e7          	jalr	-1152(ra) # 569a <sbrk>
    exit(0);
    2b22:	4501                	li	a0,0
    2b24:	00003097          	auipc	ra,0x3
    2b28:	aee080e7          	jalr	-1298(ra) # 5612 <exit>
    printf("fork failed\n");
    2b2c:	00004517          	auipc	a0,0x4
    2b30:	02450513          	addi	a0,a0,36 # 6b50 <statistics+0x1024>
    2b34:	00003097          	auipc	ra,0x3
    2b38:	e56080e7          	jalr	-426(ra) # 598a <printf>
    exit(1);
    2b3c:	4505                	li	a0,1
    2b3e:	00003097          	auipc	ra,0x3
    2b42:	ad4080e7          	jalr	-1324(ra) # 5612 <exit>
  wait(0);
    2b46:	4501                	li	a0,0
    2b48:	00003097          	auipc	ra,0x3
    2b4c:	ad2080e7          	jalr	-1326(ra) # 561a <wait>
  exit(0);
    2b50:	4501                	li	a0,0
    2b52:	00003097          	auipc	ra,0x3
    2b56:	ac0080e7          	jalr	-1344(ra) # 5612 <exit>

0000000000002b5a <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2b5a:	715d                	addi	sp,sp,-80
    2b5c:	e486                	sd	ra,72(sp)
    2b5e:	e0a2                	sd	s0,64(sp)
    2b60:	fc26                	sd	s1,56(sp)
    2b62:	f84a                	sd	s2,48(sp)
    2b64:	f44e                	sd	s3,40(sp)
    2b66:	f052                	sd	s4,32(sp)
    2b68:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2b6a:	4901                	li	s2,0
    2b6c:	49bd                	li	s3,15
    int pid = fork();
    2b6e:	00003097          	auipc	ra,0x3
    2b72:	a9c080e7          	jalr	-1380(ra) # 560a <fork>
    2b76:	84aa                	mv	s1,a0
    if(pid < 0){
    2b78:	02054063          	bltz	a0,2b98 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2b7c:	c91d                	beqz	a0,2bb2 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2b7e:	4501                	li	a0,0
    2b80:	00003097          	auipc	ra,0x3
    2b84:	a9a080e7          	jalr	-1382(ra) # 561a <wait>
  for(int avail = 0; avail < 15; avail++){
    2b88:	2905                	addiw	s2,s2,1
    2b8a:	ff3912e3          	bne	s2,s3,2b6e <execout+0x14>
    }
  }

  exit(0);
    2b8e:	4501                	li	a0,0
    2b90:	00003097          	auipc	ra,0x3
    2b94:	a82080e7          	jalr	-1406(ra) # 5612 <exit>
      printf("fork failed\n");
    2b98:	00004517          	auipc	a0,0x4
    2b9c:	fb850513          	addi	a0,a0,-72 # 6b50 <statistics+0x1024>
    2ba0:	00003097          	auipc	ra,0x3
    2ba4:	dea080e7          	jalr	-534(ra) # 598a <printf>
      exit(1);
    2ba8:	4505                	li	a0,1
    2baa:	00003097          	auipc	ra,0x3
    2bae:	a68080e7          	jalr	-1432(ra) # 5612 <exit>
        if(a == 0xffffffffffffffffLL)
    2bb2:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2bb4:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2bb6:	6505                	lui	a0,0x1
    2bb8:	00003097          	auipc	ra,0x3
    2bbc:	ae2080e7          	jalr	-1310(ra) # 569a <sbrk>
        if(a == 0xffffffffffffffffLL)
    2bc0:	01350763          	beq	a0,s3,2bce <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2bc4:	6785                	lui	a5,0x1
    2bc6:	953e                	add	a0,a0,a5
    2bc8:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x9d>
      while(1){
    2bcc:	b7ed                	j	2bb6 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2bce:	01205a63          	blez	s2,2be2 <execout+0x88>
        sbrk(-4096);
    2bd2:	757d                	lui	a0,0xfffff
    2bd4:	00003097          	auipc	ra,0x3
    2bd8:	ac6080e7          	jalr	-1338(ra) # 569a <sbrk>
      for(int i = 0; i < avail; i++)
    2bdc:	2485                	addiw	s1,s1,1
    2bde:	ff249ae3          	bne	s1,s2,2bd2 <execout+0x78>
      close(1);
    2be2:	4505                	li	a0,1
    2be4:	00003097          	auipc	ra,0x3
    2be8:	a56080e7          	jalr	-1450(ra) # 563a <close>
      char *args[] = { "echo", "x", 0 };
    2bec:	00003517          	auipc	a0,0x3
    2bf0:	32450513          	addi	a0,a0,804 # 5f10 <statistics+0x3e4>
    2bf4:	faa43c23          	sd	a0,-72(s0)
    2bf8:	00003797          	auipc	a5,0x3
    2bfc:	38878793          	addi	a5,a5,904 # 5f80 <statistics+0x454>
    2c00:	fcf43023          	sd	a5,-64(s0)
    2c04:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2c08:	fb840593          	addi	a1,s0,-72
    2c0c:	00003097          	auipc	ra,0x3
    2c10:	a3e080e7          	jalr	-1474(ra) # 564a <exec>
      exit(0);
    2c14:	4501                	li	a0,0
    2c16:	00003097          	auipc	ra,0x3
    2c1a:	9fc080e7          	jalr	-1540(ra) # 5612 <exit>

0000000000002c1e <fourteen>:
{
    2c1e:	1101                	addi	sp,sp,-32
    2c20:	ec06                	sd	ra,24(sp)
    2c22:	e822                	sd	s0,16(sp)
    2c24:	e426                	sd	s1,8(sp)
    2c26:	1000                	addi	s0,sp,32
    2c28:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2c2a:	00004517          	auipc	a0,0x4
    2c2e:	41650513          	addi	a0,a0,1046 # 7040 <statistics+0x1514>
    2c32:	00003097          	auipc	ra,0x3
    2c36:	a48080e7          	jalr	-1464(ra) # 567a <mkdir>
    2c3a:	e165                	bnez	a0,2d1a <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2c3c:	00004517          	auipc	a0,0x4
    2c40:	25c50513          	addi	a0,a0,604 # 6e98 <statistics+0x136c>
    2c44:	00003097          	auipc	ra,0x3
    2c48:	a36080e7          	jalr	-1482(ra) # 567a <mkdir>
    2c4c:	e56d                	bnez	a0,2d36 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2c4e:	20000593          	li	a1,512
    2c52:	00004517          	auipc	a0,0x4
    2c56:	29e50513          	addi	a0,a0,670 # 6ef0 <statistics+0x13c4>
    2c5a:	00003097          	auipc	ra,0x3
    2c5e:	9f8080e7          	jalr	-1544(ra) # 5652 <open>
  if(fd < 0){
    2c62:	0e054863          	bltz	a0,2d52 <fourteen+0x134>
  close(fd);
    2c66:	00003097          	auipc	ra,0x3
    2c6a:	9d4080e7          	jalr	-1580(ra) # 563a <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2c6e:	4581                	li	a1,0
    2c70:	00004517          	auipc	a0,0x4
    2c74:	2f850513          	addi	a0,a0,760 # 6f68 <statistics+0x143c>
    2c78:	00003097          	auipc	ra,0x3
    2c7c:	9da080e7          	jalr	-1574(ra) # 5652 <open>
  if(fd < 0){
    2c80:	0e054763          	bltz	a0,2d6e <fourteen+0x150>
  close(fd);
    2c84:	00003097          	auipc	ra,0x3
    2c88:	9b6080e7          	jalr	-1610(ra) # 563a <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2c8c:	00004517          	auipc	a0,0x4
    2c90:	34c50513          	addi	a0,a0,844 # 6fd8 <statistics+0x14ac>
    2c94:	00003097          	auipc	ra,0x3
    2c98:	9e6080e7          	jalr	-1562(ra) # 567a <mkdir>
    2c9c:	c57d                	beqz	a0,2d8a <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2c9e:	00004517          	auipc	a0,0x4
    2ca2:	39250513          	addi	a0,a0,914 # 7030 <statistics+0x1504>
    2ca6:	00003097          	auipc	ra,0x3
    2caa:	9d4080e7          	jalr	-1580(ra) # 567a <mkdir>
    2cae:	cd65                	beqz	a0,2da6 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2cb0:	00004517          	auipc	a0,0x4
    2cb4:	38050513          	addi	a0,a0,896 # 7030 <statistics+0x1504>
    2cb8:	00003097          	auipc	ra,0x3
    2cbc:	9aa080e7          	jalr	-1622(ra) # 5662 <unlink>
  unlink("12345678901234/12345678901234");
    2cc0:	00004517          	auipc	a0,0x4
    2cc4:	31850513          	addi	a0,a0,792 # 6fd8 <statistics+0x14ac>
    2cc8:	00003097          	auipc	ra,0x3
    2ccc:	99a080e7          	jalr	-1638(ra) # 5662 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2cd0:	00004517          	auipc	a0,0x4
    2cd4:	29850513          	addi	a0,a0,664 # 6f68 <statistics+0x143c>
    2cd8:	00003097          	auipc	ra,0x3
    2cdc:	98a080e7          	jalr	-1654(ra) # 5662 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2ce0:	00004517          	auipc	a0,0x4
    2ce4:	21050513          	addi	a0,a0,528 # 6ef0 <statistics+0x13c4>
    2ce8:	00003097          	auipc	ra,0x3
    2cec:	97a080e7          	jalr	-1670(ra) # 5662 <unlink>
  unlink("12345678901234/123456789012345");
    2cf0:	00004517          	auipc	a0,0x4
    2cf4:	1a850513          	addi	a0,a0,424 # 6e98 <statistics+0x136c>
    2cf8:	00003097          	auipc	ra,0x3
    2cfc:	96a080e7          	jalr	-1686(ra) # 5662 <unlink>
  unlink("12345678901234");
    2d00:	00004517          	auipc	a0,0x4
    2d04:	34050513          	addi	a0,a0,832 # 7040 <statistics+0x1514>
    2d08:	00003097          	auipc	ra,0x3
    2d0c:	95a080e7          	jalr	-1702(ra) # 5662 <unlink>
}
    2d10:	60e2                	ld	ra,24(sp)
    2d12:	6442                	ld	s0,16(sp)
    2d14:	64a2                	ld	s1,8(sp)
    2d16:	6105                	addi	sp,sp,32
    2d18:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2d1a:	85a6                	mv	a1,s1
    2d1c:	00004517          	auipc	a0,0x4
    2d20:	15450513          	addi	a0,a0,340 # 6e70 <statistics+0x1344>
    2d24:	00003097          	auipc	ra,0x3
    2d28:	c66080e7          	jalr	-922(ra) # 598a <printf>
    exit(1);
    2d2c:	4505                	li	a0,1
    2d2e:	00003097          	auipc	ra,0x3
    2d32:	8e4080e7          	jalr	-1820(ra) # 5612 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2d36:	85a6                	mv	a1,s1
    2d38:	00004517          	auipc	a0,0x4
    2d3c:	18050513          	addi	a0,a0,384 # 6eb8 <statistics+0x138c>
    2d40:	00003097          	auipc	ra,0x3
    2d44:	c4a080e7          	jalr	-950(ra) # 598a <printf>
    exit(1);
    2d48:	4505                	li	a0,1
    2d4a:	00003097          	auipc	ra,0x3
    2d4e:	8c8080e7          	jalr	-1848(ra) # 5612 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2d52:	85a6                	mv	a1,s1
    2d54:	00004517          	auipc	a0,0x4
    2d58:	1cc50513          	addi	a0,a0,460 # 6f20 <statistics+0x13f4>
    2d5c:	00003097          	auipc	ra,0x3
    2d60:	c2e080e7          	jalr	-978(ra) # 598a <printf>
    exit(1);
    2d64:	4505                	li	a0,1
    2d66:	00003097          	auipc	ra,0x3
    2d6a:	8ac080e7          	jalr	-1876(ra) # 5612 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2d6e:	85a6                	mv	a1,s1
    2d70:	00004517          	auipc	a0,0x4
    2d74:	22850513          	addi	a0,a0,552 # 6f98 <statistics+0x146c>
    2d78:	00003097          	auipc	ra,0x3
    2d7c:	c12080e7          	jalr	-1006(ra) # 598a <printf>
    exit(1);
    2d80:	4505                	li	a0,1
    2d82:	00003097          	auipc	ra,0x3
    2d86:	890080e7          	jalr	-1904(ra) # 5612 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2d8a:	85a6                	mv	a1,s1
    2d8c:	00004517          	auipc	a0,0x4
    2d90:	26c50513          	addi	a0,a0,620 # 6ff8 <statistics+0x14cc>
    2d94:	00003097          	auipc	ra,0x3
    2d98:	bf6080e7          	jalr	-1034(ra) # 598a <printf>
    exit(1);
    2d9c:	4505                	li	a0,1
    2d9e:	00003097          	auipc	ra,0x3
    2da2:	874080e7          	jalr	-1932(ra) # 5612 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2da6:	85a6                	mv	a1,s1
    2da8:	00004517          	auipc	a0,0x4
    2dac:	2a850513          	addi	a0,a0,680 # 7050 <statistics+0x1524>
    2db0:	00003097          	auipc	ra,0x3
    2db4:	bda080e7          	jalr	-1062(ra) # 598a <printf>
    exit(1);
    2db8:	4505                	li	a0,1
    2dba:	00003097          	auipc	ra,0x3
    2dbe:	858080e7          	jalr	-1960(ra) # 5612 <exit>

0000000000002dc2 <iputtest>:
{
    2dc2:	1101                	addi	sp,sp,-32
    2dc4:	ec06                	sd	ra,24(sp)
    2dc6:	e822                	sd	s0,16(sp)
    2dc8:	e426                	sd	s1,8(sp)
    2dca:	1000                	addi	s0,sp,32
    2dcc:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2dce:	00004517          	auipc	a0,0x4
    2dd2:	2ba50513          	addi	a0,a0,698 # 7088 <statistics+0x155c>
    2dd6:	00003097          	auipc	ra,0x3
    2dda:	8a4080e7          	jalr	-1884(ra) # 567a <mkdir>
    2dde:	04054563          	bltz	a0,2e28 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2de2:	00004517          	auipc	a0,0x4
    2de6:	2a650513          	addi	a0,a0,678 # 7088 <statistics+0x155c>
    2dea:	00003097          	auipc	ra,0x3
    2dee:	898080e7          	jalr	-1896(ra) # 5682 <chdir>
    2df2:	04054963          	bltz	a0,2e44 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2df6:	00004517          	auipc	a0,0x4
    2dfa:	2d250513          	addi	a0,a0,722 # 70c8 <statistics+0x159c>
    2dfe:	00003097          	auipc	ra,0x3
    2e02:	864080e7          	jalr	-1948(ra) # 5662 <unlink>
    2e06:	04054d63          	bltz	a0,2e60 <iputtest+0x9e>
  if(chdir("/") < 0){
    2e0a:	00004517          	auipc	a0,0x4
    2e0e:	2ee50513          	addi	a0,a0,750 # 70f8 <statistics+0x15cc>
    2e12:	00003097          	auipc	ra,0x3
    2e16:	870080e7          	jalr	-1936(ra) # 5682 <chdir>
    2e1a:	06054163          	bltz	a0,2e7c <iputtest+0xba>
}
    2e1e:	60e2                	ld	ra,24(sp)
    2e20:	6442                	ld	s0,16(sp)
    2e22:	64a2                	ld	s1,8(sp)
    2e24:	6105                	addi	sp,sp,32
    2e26:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2e28:	85a6                	mv	a1,s1
    2e2a:	00004517          	auipc	a0,0x4
    2e2e:	26650513          	addi	a0,a0,614 # 7090 <statistics+0x1564>
    2e32:	00003097          	auipc	ra,0x3
    2e36:	b58080e7          	jalr	-1192(ra) # 598a <printf>
    exit(1);
    2e3a:	4505                	li	a0,1
    2e3c:	00002097          	auipc	ra,0x2
    2e40:	7d6080e7          	jalr	2006(ra) # 5612 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2e44:	85a6                	mv	a1,s1
    2e46:	00004517          	auipc	a0,0x4
    2e4a:	26250513          	addi	a0,a0,610 # 70a8 <statistics+0x157c>
    2e4e:	00003097          	auipc	ra,0x3
    2e52:	b3c080e7          	jalr	-1220(ra) # 598a <printf>
    exit(1);
    2e56:	4505                	li	a0,1
    2e58:	00002097          	auipc	ra,0x2
    2e5c:	7ba080e7          	jalr	1978(ra) # 5612 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2e60:	85a6                	mv	a1,s1
    2e62:	00004517          	auipc	a0,0x4
    2e66:	27650513          	addi	a0,a0,630 # 70d8 <statistics+0x15ac>
    2e6a:	00003097          	auipc	ra,0x3
    2e6e:	b20080e7          	jalr	-1248(ra) # 598a <printf>
    exit(1);
    2e72:	4505                	li	a0,1
    2e74:	00002097          	auipc	ra,0x2
    2e78:	79e080e7          	jalr	1950(ra) # 5612 <exit>
    printf("%s: chdir / failed\n", s);
    2e7c:	85a6                	mv	a1,s1
    2e7e:	00004517          	auipc	a0,0x4
    2e82:	28250513          	addi	a0,a0,642 # 7100 <statistics+0x15d4>
    2e86:	00003097          	auipc	ra,0x3
    2e8a:	b04080e7          	jalr	-1276(ra) # 598a <printf>
    exit(1);
    2e8e:	4505                	li	a0,1
    2e90:	00002097          	auipc	ra,0x2
    2e94:	782080e7          	jalr	1922(ra) # 5612 <exit>

0000000000002e98 <exitiputtest>:
{
    2e98:	7179                	addi	sp,sp,-48
    2e9a:	f406                	sd	ra,40(sp)
    2e9c:	f022                	sd	s0,32(sp)
    2e9e:	ec26                	sd	s1,24(sp)
    2ea0:	1800                	addi	s0,sp,48
    2ea2:	84aa                	mv	s1,a0
  pid = fork();
    2ea4:	00002097          	auipc	ra,0x2
    2ea8:	766080e7          	jalr	1894(ra) # 560a <fork>
  if(pid < 0){
    2eac:	04054663          	bltz	a0,2ef8 <exitiputtest+0x60>
  if(pid == 0){
    2eb0:	ed45                	bnez	a0,2f68 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2eb2:	00004517          	auipc	a0,0x4
    2eb6:	1d650513          	addi	a0,a0,470 # 7088 <statistics+0x155c>
    2eba:	00002097          	auipc	ra,0x2
    2ebe:	7c0080e7          	jalr	1984(ra) # 567a <mkdir>
    2ec2:	04054963          	bltz	a0,2f14 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2ec6:	00004517          	auipc	a0,0x4
    2eca:	1c250513          	addi	a0,a0,450 # 7088 <statistics+0x155c>
    2ece:	00002097          	auipc	ra,0x2
    2ed2:	7b4080e7          	jalr	1972(ra) # 5682 <chdir>
    2ed6:	04054d63          	bltz	a0,2f30 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2eda:	00004517          	auipc	a0,0x4
    2ede:	1ee50513          	addi	a0,a0,494 # 70c8 <statistics+0x159c>
    2ee2:	00002097          	auipc	ra,0x2
    2ee6:	780080e7          	jalr	1920(ra) # 5662 <unlink>
    2eea:	06054163          	bltz	a0,2f4c <exitiputtest+0xb4>
    exit(0);
    2eee:	4501                	li	a0,0
    2ef0:	00002097          	auipc	ra,0x2
    2ef4:	722080e7          	jalr	1826(ra) # 5612 <exit>
    printf("%s: fork failed\n", s);
    2ef8:	85a6                	mv	a1,s1
    2efa:	00004517          	auipc	a0,0x4
    2efe:	84e50513          	addi	a0,a0,-1970 # 6748 <statistics+0xc1c>
    2f02:	00003097          	auipc	ra,0x3
    2f06:	a88080e7          	jalr	-1400(ra) # 598a <printf>
    exit(1);
    2f0a:	4505                	li	a0,1
    2f0c:	00002097          	auipc	ra,0x2
    2f10:	706080e7          	jalr	1798(ra) # 5612 <exit>
      printf("%s: mkdir failed\n", s);
    2f14:	85a6                	mv	a1,s1
    2f16:	00004517          	auipc	a0,0x4
    2f1a:	17a50513          	addi	a0,a0,378 # 7090 <statistics+0x1564>
    2f1e:	00003097          	auipc	ra,0x3
    2f22:	a6c080e7          	jalr	-1428(ra) # 598a <printf>
      exit(1);
    2f26:	4505                	li	a0,1
    2f28:	00002097          	auipc	ra,0x2
    2f2c:	6ea080e7          	jalr	1770(ra) # 5612 <exit>
      printf("%s: child chdir failed\n", s);
    2f30:	85a6                	mv	a1,s1
    2f32:	00004517          	auipc	a0,0x4
    2f36:	1e650513          	addi	a0,a0,486 # 7118 <statistics+0x15ec>
    2f3a:	00003097          	auipc	ra,0x3
    2f3e:	a50080e7          	jalr	-1456(ra) # 598a <printf>
      exit(1);
    2f42:	4505                	li	a0,1
    2f44:	00002097          	auipc	ra,0x2
    2f48:	6ce080e7          	jalr	1742(ra) # 5612 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2f4c:	85a6                	mv	a1,s1
    2f4e:	00004517          	auipc	a0,0x4
    2f52:	18a50513          	addi	a0,a0,394 # 70d8 <statistics+0x15ac>
    2f56:	00003097          	auipc	ra,0x3
    2f5a:	a34080e7          	jalr	-1484(ra) # 598a <printf>
      exit(1);
    2f5e:	4505                	li	a0,1
    2f60:	00002097          	auipc	ra,0x2
    2f64:	6b2080e7          	jalr	1714(ra) # 5612 <exit>
  wait(&xstatus);
    2f68:	fdc40513          	addi	a0,s0,-36
    2f6c:	00002097          	auipc	ra,0x2
    2f70:	6ae080e7          	jalr	1710(ra) # 561a <wait>
  exit(xstatus);
    2f74:	fdc42503          	lw	a0,-36(s0)
    2f78:	00002097          	auipc	ra,0x2
    2f7c:	69a080e7          	jalr	1690(ra) # 5612 <exit>

0000000000002f80 <dirtest>:
{
    2f80:	1101                	addi	sp,sp,-32
    2f82:	ec06                	sd	ra,24(sp)
    2f84:	e822                	sd	s0,16(sp)
    2f86:	e426                	sd	s1,8(sp)
    2f88:	1000                	addi	s0,sp,32
    2f8a:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2f8c:	00004517          	auipc	a0,0x4
    2f90:	1a450513          	addi	a0,a0,420 # 7130 <statistics+0x1604>
    2f94:	00002097          	auipc	ra,0x2
    2f98:	6e6080e7          	jalr	1766(ra) # 567a <mkdir>
    2f9c:	04054563          	bltz	a0,2fe6 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2fa0:	00004517          	auipc	a0,0x4
    2fa4:	19050513          	addi	a0,a0,400 # 7130 <statistics+0x1604>
    2fa8:	00002097          	auipc	ra,0x2
    2fac:	6da080e7          	jalr	1754(ra) # 5682 <chdir>
    2fb0:	04054963          	bltz	a0,3002 <dirtest+0x82>
  if(chdir("..") < 0){
    2fb4:	00004517          	auipc	a0,0x4
    2fb8:	19c50513          	addi	a0,a0,412 # 7150 <statistics+0x1624>
    2fbc:	00002097          	auipc	ra,0x2
    2fc0:	6c6080e7          	jalr	1734(ra) # 5682 <chdir>
    2fc4:	04054d63          	bltz	a0,301e <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2fc8:	00004517          	auipc	a0,0x4
    2fcc:	16850513          	addi	a0,a0,360 # 7130 <statistics+0x1604>
    2fd0:	00002097          	auipc	ra,0x2
    2fd4:	692080e7          	jalr	1682(ra) # 5662 <unlink>
    2fd8:	06054163          	bltz	a0,303a <dirtest+0xba>
}
    2fdc:	60e2                	ld	ra,24(sp)
    2fde:	6442                	ld	s0,16(sp)
    2fe0:	64a2                	ld	s1,8(sp)
    2fe2:	6105                	addi	sp,sp,32
    2fe4:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2fe6:	85a6                	mv	a1,s1
    2fe8:	00004517          	auipc	a0,0x4
    2fec:	0a850513          	addi	a0,a0,168 # 7090 <statistics+0x1564>
    2ff0:	00003097          	auipc	ra,0x3
    2ff4:	99a080e7          	jalr	-1638(ra) # 598a <printf>
    exit(1);
    2ff8:	4505                	li	a0,1
    2ffa:	00002097          	auipc	ra,0x2
    2ffe:	618080e7          	jalr	1560(ra) # 5612 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3002:	85a6                	mv	a1,s1
    3004:	00004517          	auipc	a0,0x4
    3008:	13450513          	addi	a0,a0,308 # 7138 <statistics+0x160c>
    300c:	00003097          	auipc	ra,0x3
    3010:	97e080e7          	jalr	-1666(ra) # 598a <printf>
    exit(1);
    3014:	4505                	li	a0,1
    3016:	00002097          	auipc	ra,0x2
    301a:	5fc080e7          	jalr	1532(ra) # 5612 <exit>
    printf("%s: chdir .. failed\n", s);
    301e:	85a6                	mv	a1,s1
    3020:	00004517          	auipc	a0,0x4
    3024:	13850513          	addi	a0,a0,312 # 7158 <statistics+0x162c>
    3028:	00003097          	auipc	ra,0x3
    302c:	962080e7          	jalr	-1694(ra) # 598a <printf>
    exit(1);
    3030:	4505                	li	a0,1
    3032:	00002097          	auipc	ra,0x2
    3036:	5e0080e7          	jalr	1504(ra) # 5612 <exit>
    printf("%s: unlink dir0 failed\n", s);
    303a:	85a6                	mv	a1,s1
    303c:	00004517          	auipc	a0,0x4
    3040:	13450513          	addi	a0,a0,308 # 7170 <statistics+0x1644>
    3044:	00003097          	auipc	ra,0x3
    3048:	946080e7          	jalr	-1722(ra) # 598a <printf>
    exit(1);
    304c:	4505                	li	a0,1
    304e:	00002097          	auipc	ra,0x2
    3052:	5c4080e7          	jalr	1476(ra) # 5612 <exit>

0000000000003056 <subdir>:
{
    3056:	1101                	addi	sp,sp,-32
    3058:	ec06                	sd	ra,24(sp)
    305a:	e822                	sd	s0,16(sp)
    305c:	e426                	sd	s1,8(sp)
    305e:	e04a                	sd	s2,0(sp)
    3060:	1000                	addi	s0,sp,32
    3062:	892a                	mv	s2,a0
  unlink("ff");
    3064:	00004517          	auipc	a0,0x4
    3068:	25450513          	addi	a0,a0,596 # 72b8 <statistics+0x178c>
    306c:	00002097          	auipc	ra,0x2
    3070:	5f6080e7          	jalr	1526(ra) # 5662 <unlink>
  if(mkdir("dd") != 0){
    3074:	00004517          	auipc	a0,0x4
    3078:	11450513          	addi	a0,a0,276 # 7188 <statistics+0x165c>
    307c:	00002097          	auipc	ra,0x2
    3080:	5fe080e7          	jalr	1534(ra) # 567a <mkdir>
    3084:	38051663          	bnez	a0,3410 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    3088:	20200593          	li	a1,514
    308c:	00004517          	auipc	a0,0x4
    3090:	11c50513          	addi	a0,a0,284 # 71a8 <statistics+0x167c>
    3094:	00002097          	auipc	ra,0x2
    3098:	5be080e7          	jalr	1470(ra) # 5652 <open>
    309c:	84aa                	mv	s1,a0
  if(fd < 0){
    309e:	38054763          	bltz	a0,342c <subdir+0x3d6>
  write(fd, "ff", 2);
    30a2:	4609                	li	a2,2
    30a4:	00004597          	auipc	a1,0x4
    30a8:	21458593          	addi	a1,a1,532 # 72b8 <statistics+0x178c>
    30ac:	00002097          	auipc	ra,0x2
    30b0:	586080e7          	jalr	1414(ra) # 5632 <write>
  close(fd);
    30b4:	8526                	mv	a0,s1
    30b6:	00002097          	auipc	ra,0x2
    30ba:	584080e7          	jalr	1412(ra) # 563a <close>
  if(unlink("dd") >= 0){
    30be:	00004517          	auipc	a0,0x4
    30c2:	0ca50513          	addi	a0,a0,202 # 7188 <statistics+0x165c>
    30c6:	00002097          	auipc	ra,0x2
    30ca:	59c080e7          	jalr	1436(ra) # 5662 <unlink>
    30ce:	36055d63          	bgez	a0,3448 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    30d2:	00004517          	auipc	a0,0x4
    30d6:	12e50513          	addi	a0,a0,302 # 7200 <statistics+0x16d4>
    30da:	00002097          	auipc	ra,0x2
    30de:	5a0080e7          	jalr	1440(ra) # 567a <mkdir>
    30e2:	38051163          	bnez	a0,3464 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    30e6:	20200593          	li	a1,514
    30ea:	00004517          	auipc	a0,0x4
    30ee:	13e50513          	addi	a0,a0,318 # 7228 <statistics+0x16fc>
    30f2:	00002097          	auipc	ra,0x2
    30f6:	560080e7          	jalr	1376(ra) # 5652 <open>
    30fa:	84aa                	mv	s1,a0
  if(fd < 0){
    30fc:	38054263          	bltz	a0,3480 <subdir+0x42a>
  write(fd, "FF", 2);
    3100:	4609                	li	a2,2
    3102:	00004597          	auipc	a1,0x4
    3106:	15658593          	addi	a1,a1,342 # 7258 <statistics+0x172c>
    310a:	00002097          	auipc	ra,0x2
    310e:	528080e7          	jalr	1320(ra) # 5632 <write>
  close(fd);
    3112:	8526                	mv	a0,s1
    3114:	00002097          	auipc	ra,0x2
    3118:	526080e7          	jalr	1318(ra) # 563a <close>
  fd = open("dd/dd/../ff", 0);
    311c:	4581                	li	a1,0
    311e:	00004517          	auipc	a0,0x4
    3122:	14250513          	addi	a0,a0,322 # 7260 <statistics+0x1734>
    3126:	00002097          	auipc	ra,0x2
    312a:	52c080e7          	jalr	1324(ra) # 5652 <open>
    312e:	84aa                	mv	s1,a0
  if(fd < 0){
    3130:	36054663          	bltz	a0,349c <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3134:	660d                	lui	a2,0x3
    3136:	00009597          	auipc	a1,0x9
    313a:	a1a58593          	addi	a1,a1,-1510 # bb50 <buf>
    313e:	00002097          	auipc	ra,0x2
    3142:	4ec080e7          	jalr	1260(ra) # 562a <read>
  if(cc != 2 || buf[0] != 'f'){
    3146:	4789                	li	a5,2
    3148:	36f51863          	bne	a0,a5,34b8 <subdir+0x462>
    314c:	00009717          	auipc	a4,0x9
    3150:	a0474703          	lbu	a4,-1532(a4) # bb50 <buf>
    3154:	06600793          	li	a5,102
    3158:	36f71063          	bne	a4,a5,34b8 <subdir+0x462>
  close(fd);
    315c:	8526                	mv	a0,s1
    315e:	00002097          	auipc	ra,0x2
    3162:	4dc080e7          	jalr	1244(ra) # 563a <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3166:	00004597          	auipc	a1,0x4
    316a:	14a58593          	addi	a1,a1,330 # 72b0 <statistics+0x1784>
    316e:	00004517          	auipc	a0,0x4
    3172:	0ba50513          	addi	a0,a0,186 # 7228 <statistics+0x16fc>
    3176:	00002097          	auipc	ra,0x2
    317a:	4fc080e7          	jalr	1276(ra) # 5672 <link>
    317e:	34051b63          	bnez	a0,34d4 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3182:	00004517          	auipc	a0,0x4
    3186:	0a650513          	addi	a0,a0,166 # 7228 <statistics+0x16fc>
    318a:	00002097          	auipc	ra,0x2
    318e:	4d8080e7          	jalr	1240(ra) # 5662 <unlink>
    3192:	34051f63          	bnez	a0,34f0 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3196:	4581                	li	a1,0
    3198:	00004517          	auipc	a0,0x4
    319c:	09050513          	addi	a0,a0,144 # 7228 <statistics+0x16fc>
    31a0:	00002097          	auipc	ra,0x2
    31a4:	4b2080e7          	jalr	1202(ra) # 5652 <open>
    31a8:	36055263          	bgez	a0,350c <subdir+0x4b6>
  if(chdir("dd") != 0){
    31ac:	00004517          	auipc	a0,0x4
    31b0:	fdc50513          	addi	a0,a0,-36 # 7188 <statistics+0x165c>
    31b4:	00002097          	auipc	ra,0x2
    31b8:	4ce080e7          	jalr	1230(ra) # 5682 <chdir>
    31bc:	36051663          	bnez	a0,3528 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    31c0:	00004517          	auipc	a0,0x4
    31c4:	18850513          	addi	a0,a0,392 # 7348 <statistics+0x181c>
    31c8:	00002097          	auipc	ra,0x2
    31cc:	4ba080e7          	jalr	1210(ra) # 5682 <chdir>
    31d0:	36051a63          	bnez	a0,3544 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    31d4:	00004517          	auipc	a0,0x4
    31d8:	1a450513          	addi	a0,a0,420 # 7378 <statistics+0x184c>
    31dc:	00002097          	auipc	ra,0x2
    31e0:	4a6080e7          	jalr	1190(ra) # 5682 <chdir>
    31e4:	36051e63          	bnez	a0,3560 <subdir+0x50a>
  if(chdir("./..") != 0){
    31e8:	00004517          	auipc	a0,0x4
    31ec:	1c050513          	addi	a0,a0,448 # 73a8 <statistics+0x187c>
    31f0:	00002097          	auipc	ra,0x2
    31f4:	492080e7          	jalr	1170(ra) # 5682 <chdir>
    31f8:	38051263          	bnez	a0,357c <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    31fc:	4581                	li	a1,0
    31fe:	00004517          	auipc	a0,0x4
    3202:	0b250513          	addi	a0,a0,178 # 72b0 <statistics+0x1784>
    3206:	00002097          	auipc	ra,0x2
    320a:	44c080e7          	jalr	1100(ra) # 5652 <open>
    320e:	84aa                	mv	s1,a0
  if(fd < 0){
    3210:	38054463          	bltz	a0,3598 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3214:	660d                	lui	a2,0x3
    3216:	00009597          	auipc	a1,0x9
    321a:	93a58593          	addi	a1,a1,-1734 # bb50 <buf>
    321e:	00002097          	auipc	ra,0x2
    3222:	40c080e7          	jalr	1036(ra) # 562a <read>
    3226:	4789                	li	a5,2
    3228:	38f51663          	bne	a0,a5,35b4 <subdir+0x55e>
  close(fd);
    322c:	8526                	mv	a0,s1
    322e:	00002097          	auipc	ra,0x2
    3232:	40c080e7          	jalr	1036(ra) # 563a <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3236:	4581                	li	a1,0
    3238:	00004517          	auipc	a0,0x4
    323c:	ff050513          	addi	a0,a0,-16 # 7228 <statistics+0x16fc>
    3240:	00002097          	auipc	ra,0x2
    3244:	412080e7          	jalr	1042(ra) # 5652 <open>
    3248:	38055463          	bgez	a0,35d0 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    324c:	20200593          	li	a1,514
    3250:	00004517          	auipc	a0,0x4
    3254:	1e850513          	addi	a0,a0,488 # 7438 <statistics+0x190c>
    3258:	00002097          	auipc	ra,0x2
    325c:	3fa080e7          	jalr	1018(ra) # 5652 <open>
    3260:	38055663          	bgez	a0,35ec <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3264:	20200593          	li	a1,514
    3268:	00004517          	auipc	a0,0x4
    326c:	20050513          	addi	a0,a0,512 # 7468 <statistics+0x193c>
    3270:	00002097          	auipc	ra,0x2
    3274:	3e2080e7          	jalr	994(ra) # 5652 <open>
    3278:	38055863          	bgez	a0,3608 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    327c:	20000593          	li	a1,512
    3280:	00004517          	auipc	a0,0x4
    3284:	f0850513          	addi	a0,a0,-248 # 7188 <statistics+0x165c>
    3288:	00002097          	auipc	ra,0x2
    328c:	3ca080e7          	jalr	970(ra) # 5652 <open>
    3290:	38055a63          	bgez	a0,3624 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3294:	4589                	li	a1,2
    3296:	00004517          	auipc	a0,0x4
    329a:	ef250513          	addi	a0,a0,-270 # 7188 <statistics+0x165c>
    329e:	00002097          	auipc	ra,0x2
    32a2:	3b4080e7          	jalr	948(ra) # 5652 <open>
    32a6:	38055d63          	bgez	a0,3640 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    32aa:	4585                	li	a1,1
    32ac:	00004517          	auipc	a0,0x4
    32b0:	edc50513          	addi	a0,a0,-292 # 7188 <statistics+0x165c>
    32b4:	00002097          	auipc	ra,0x2
    32b8:	39e080e7          	jalr	926(ra) # 5652 <open>
    32bc:	3a055063          	bgez	a0,365c <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    32c0:	00004597          	auipc	a1,0x4
    32c4:	23858593          	addi	a1,a1,568 # 74f8 <statistics+0x19cc>
    32c8:	00004517          	auipc	a0,0x4
    32cc:	17050513          	addi	a0,a0,368 # 7438 <statistics+0x190c>
    32d0:	00002097          	auipc	ra,0x2
    32d4:	3a2080e7          	jalr	930(ra) # 5672 <link>
    32d8:	3a050063          	beqz	a0,3678 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    32dc:	00004597          	auipc	a1,0x4
    32e0:	21c58593          	addi	a1,a1,540 # 74f8 <statistics+0x19cc>
    32e4:	00004517          	auipc	a0,0x4
    32e8:	18450513          	addi	a0,a0,388 # 7468 <statistics+0x193c>
    32ec:	00002097          	auipc	ra,0x2
    32f0:	386080e7          	jalr	902(ra) # 5672 <link>
    32f4:	3a050063          	beqz	a0,3694 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    32f8:	00004597          	auipc	a1,0x4
    32fc:	fb858593          	addi	a1,a1,-72 # 72b0 <statistics+0x1784>
    3300:	00004517          	auipc	a0,0x4
    3304:	ea850513          	addi	a0,a0,-344 # 71a8 <statistics+0x167c>
    3308:	00002097          	auipc	ra,0x2
    330c:	36a080e7          	jalr	874(ra) # 5672 <link>
    3310:	3a050063          	beqz	a0,36b0 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3314:	00004517          	auipc	a0,0x4
    3318:	12450513          	addi	a0,a0,292 # 7438 <statistics+0x190c>
    331c:	00002097          	auipc	ra,0x2
    3320:	35e080e7          	jalr	862(ra) # 567a <mkdir>
    3324:	3a050463          	beqz	a0,36cc <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3328:	00004517          	auipc	a0,0x4
    332c:	14050513          	addi	a0,a0,320 # 7468 <statistics+0x193c>
    3330:	00002097          	auipc	ra,0x2
    3334:	34a080e7          	jalr	842(ra) # 567a <mkdir>
    3338:	3a050863          	beqz	a0,36e8 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    333c:	00004517          	auipc	a0,0x4
    3340:	f7450513          	addi	a0,a0,-140 # 72b0 <statistics+0x1784>
    3344:	00002097          	auipc	ra,0x2
    3348:	336080e7          	jalr	822(ra) # 567a <mkdir>
    334c:	3a050c63          	beqz	a0,3704 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3350:	00004517          	auipc	a0,0x4
    3354:	11850513          	addi	a0,a0,280 # 7468 <statistics+0x193c>
    3358:	00002097          	auipc	ra,0x2
    335c:	30a080e7          	jalr	778(ra) # 5662 <unlink>
    3360:	3c050063          	beqz	a0,3720 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3364:	00004517          	auipc	a0,0x4
    3368:	0d450513          	addi	a0,a0,212 # 7438 <statistics+0x190c>
    336c:	00002097          	auipc	ra,0x2
    3370:	2f6080e7          	jalr	758(ra) # 5662 <unlink>
    3374:	3c050463          	beqz	a0,373c <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3378:	00004517          	auipc	a0,0x4
    337c:	e3050513          	addi	a0,a0,-464 # 71a8 <statistics+0x167c>
    3380:	00002097          	auipc	ra,0x2
    3384:	302080e7          	jalr	770(ra) # 5682 <chdir>
    3388:	3c050863          	beqz	a0,3758 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    338c:	00004517          	auipc	a0,0x4
    3390:	2bc50513          	addi	a0,a0,700 # 7648 <statistics+0x1b1c>
    3394:	00002097          	auipc	ra,0x2
    3398:	2ee080e7          	jalr	750(ra) # 5682 <chdir>
    339c:	3c050c63          	beqz	a0,3774 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    33a0:	00004517          	auipc	a0,0x4
    33a4:	f1050513          	addi	a0,a0,-240 # 72b0 <statistics+0x1784>
    33a8:	00002097          	auipc	ra,0x2
    33ac:	2ba080e7          	jalr	698(ra) # 5662 <unlink>
    33b0:	3e051063          	bnez	a0,3790 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    33b4:	00004517          	auipc	a0,0x4
    33b8:	df450513          	addi	a0,a0,-524 # 71a8 <statistics+0x167c>
    33bc:	00002097          	auipc	ra,0x2
    33c0:	2a6080e7          	jalr	678(ra) # 5662 <unlink>
    33c4:	3e051463          	bnez	a0,37ac <subdir+0x756>
  if(unlink("dd") == 0){
    33c8:	00004517          	auipc	a0,0x4
    33cc:	dc050513          	addi	a0,a0,-576 # 7188 <statistics+0x165c>
    33d0:	00002097          	auipc	ra,0x2
    33d4:	292080e7          	jalr	658(ra) # 5662 <unlink>
    33d8:	3e050863          	beqz	a0,37c8 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    33dc:	00004517          	auipc	a0,0x4
    33e0:	2dc50513          	addi	a0,a0,732 # 76b8 <statistics+0x1b8c>
    33e4:	00002097          	auipc	ra,0x2
    33e8:	27e080e7          	jalr	638(ra) # 5662 <unlink>
    33ec:	3e054c63          	bltz	a0,37e4 <subdir+0x78e>
  if(unlink("dd") < 0){
    33f0:	00004517          	auipc	a0,0x4
    33f4:	d9850513          	addi	a0,a0,-616 # 7188 <statistics+0x165c>
    33f8:	00002097          	auipc	ra,0x2
    33fc:	26a080e7          	jalr	618(ra) # 5662 <unlink>
    3400:	40054063          	bltz	a0,3800 <subdir+0x7aa>
}
    3404:	60e2                	ld	ra,24(sp)
    3406:	6442                	ld	s0,16(sp)
    3408:	64a2                	ld	s1,8(sp)
    340a:	6902                	ld	s2,0(sp)
    340c:	6105                	addi	sp,sp,32
    340e:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3410:	85ca                	mv	a1,s2
    3412:	00004517          	auipc	a0,0x4
    3416:	d7e50513          	addi	a0,a0,-642 # 7190 <statistics+0x1664>
    341a:	00002097          	auipc	ra,0x2
    341e:	570080e7          	jalr	1392(ra) # 598a <printf>
    exit(1);
    3422:	4505                	li	a0,1
    3424:	00002097          	auipc	ra,0x2
    3428:	1ee080e7          	jalr	494(ra) # 5612 <exit>
    printf("%s: create dd/ff failed\n", s);
    342c:	85ca                	mv	a1,s2
    342e:	00004517          	auipc	a0,0x4
    3432:	d8250513          	addi	a0,a0,-638 # 71b0 <statistics+0x1684>
    3436:	00002097          	auipc	ra,0x2
    343a:	554080e7          	jalr	1364(ra) # 598a <printf>
    exit(1);
    343e:	4505                	li	a0,1
    3440:	00002097          	auipc	ra,0x2
    3444:	1d2080e7          	jalr	466(ra) # 5612 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3448:	85ca                	mv	a1,s2
    344a:	00004517          	auipc	a0,0x4
    344e:	d8650513          	addi	a0,a0,-634 # 71d0 <statistics+0x16a4>
    3452:	00002097          	auipc	ra,0x2
    3456:	538080e7          	jalr	1336(ra) # 598a <printf>
    exit(1);
    345a:	4505                	li	a0,1
    345c:	00002097          	auipc	ra,0x2
    3460:	1b6080e7          	jalr	438(ra) # 5612 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3464:	85ca                	mv	a1,s2
    3466:	00004517          	auipc	a0,0x4
    346a:	da250513          	addi	a0,a0,-606 # 7208 <statistics+0x16dc>
    346e:	00002097          	auipc	ra,0x2
    3472:	51c080e7          	jalr	1308(ra) # 598a <printf>
    exit(1);
    3476:	4505                	li	a0,1
    3478:	00002097          	auipc	ra,0x2
    347c:	19a080e7          	jalr	410(ra) # 5612 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3480:	85ca                	mv	a1,s2
    3482:	00004517          	auipc	a0,0x4
    3486:	db650513          	addi	a0,a0,-586 # 7238 <statistics+0x170c>
    348a:	00002097          	auipc	ra,0x2
    348e:	500080e7          	jalr	1280(ra) # 598a <printf>
    exit(1);
    3492:	4505                	li	a0,1
    3494:	00002097          	auipc	ra,0x2
    3498:	17e080e7          	jalr	382(ra) # 5612 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    349c:	85ca                	mv	a1,s2
    349e:	00004517          	auipc	a0,0x4
    34a2:	dd250513          	addi	a0,a0,-558 # 7270 <statistics+0x1744>
    34a6:	00002097          	auipc	ra,0x2
    34aa:	4e4080e7          	jalr	1252(ra) # 598a <printf>
    exit(1);
    34ae:	4505                	li	a0,1
    34b0:	00002097          	auipc	ra,0x2
    34b4:	162080e7          	jalr	354(ra) # 5612 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    34b8:	85ca                	mv	a1,s2
    34ba:	00004517          	auipc	a0,0x4
    34be:	dd650513          	addi	a0,a0,-554 # 7290 <statistics+0x1764>
    34c2:	00002097          	auipc	ra,0x2
    34c6:	4c8080e7          	jalr	1224(ra) # 598a <printf>
    exit(1);
    34ca:	4505                	li	a0,1
    34cc:	00002097          	auipc	ra,0x2
    34d0:	146080e7          	jalr	326(ra) # 5612 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    34d4:	85ca                	mv	a1,s2
    34d6:	00004517          	auipc	a0,0x4
    34da:	dea50513          	addi	a0,a0,-534 # 72c0 <statistics+0x1794>
    34de:	00002097          	auipc	ra,0x2
    34e2:	4ac080e7          	jalr	1196(ra) # 598a <printf>
    exit(1);
    34e6:	4505                	li	a0,1
    34e8:	00002097          	auipc	ra,0x2
    34ec:	12a080e7          	jalr	298(ra) # 5612 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    34f0:	85ca                	mv	a1,s2
    34f2:	00004517          	auipc	a0,0x4
    34f6:	df650513          	addi	a0,a0,-522 # 72e8 <statistics+0x17bc>
    34fa:	00002097          	auipc	ra,0x2
    34fe:	490080e7          	jalr	1168(ra) # 598a <printf>
    exit(1);
    3502:	4505                	li	a0,1
    3504:	00002097          	auipc	ra,0x2
    3508:	10e080e7          	jalr	270(ra) # 5612 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    350c:	85ca                	mv	a1,s2
    350e:	00004517          	auipc	a0,0x4
    3512:	dfa50513          	addi	a0,a0,-518 # 7308 <statistics+0x17dc>
    3516:	00002097          	auipc	ra,0x2
    351a:	474080e7          	jalr	1140(ra) # 598a <printf>
    exit(1);
    351e:	4505                	li	a0,1
    3520:	00002097          	auipc	ra,0x2
    3524:	0f2080e7          	jalr	242(ra) # 5612 <exit>
    printf("%s: chdir dd failed\n", s);
    3528:	85ca                	mv	a1,s2
    352a:	00004517          	auipc	a0,0x4
    352e:	e0650513          	addi	a0,a0,-506 # 7330 <statistics+0x1804>
    3532:	00002097          	auipc	ra,0x2
    3536:	458080e7          	jalr	1112(ra) # 598a <printf>
    exit(1);
    353a:	4505                	li	a0,1
    353c:	00002097          	auipc	ra,0x2
    3540:	0d6080e7          	jalr	214(ra) # 5612 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3544:	85ca                	mv	a1,s2
    3546:	00004517          	auipc	a0,0x4
    354a:	e1250513          	addi	a0,a0,-494 # 7358 <statistics+0x182c>
    354e:	00002097          	auipc	ra,0x2
    3552:	43c080e7          	jalr	1084(ra) # 598a <printf>
    exit(1);
    3556:	4505                	li	a0,1
    3558:	00002097          	auipc	ra,0x2
    355c:	0ba080e7          	jalr	186(ra) # 5612 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3560:	85ca                	mv	a1,s2
    3562:	00004517          	auipc	a0,0x4
    3566:	e2650513          	addi	a0,a0,-474 # 7388 <statistics+0x185c>
    356a:	00002097          	auipc	ra,0x2
    356e:	420080e7          	jalr	1056(ra) # 598a <printf>
    exit(1);
    3572:	4505                	li	a0,1
    3574:	00002097          	auipc	ra,0x2
    3578:	09e080e7          	jalr	158(ra) # 5612 <exit>
    printf("%s: chdir ./.. failed\n", s);
    357c:	85ca                	mv	a1,s2
    357e:	00004517          	auipc	a0,0x4
    3582:	e3250513          	addi	a0,a0,-462 # 73b0 <statistics+0x1884>
    3586:	00002097          	auipc	ra,0x2
    358a:	404080e7          	jalr	1028(ra) # 598a <printf>
    exit(1);
    358e:	4505                	li	a0,1
    3590:	00002097          	auipc	ra,0x2
    3594:	082080e7          	jalr	130(ra) # 5612 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3598:	85ca                	mv	a1,s2
    359a:	00004517          	auipc	a0,0x4
    359e:	e2e50513          	addi	a0,a0,-466 # 73c8 <statistics+0x189c>
    35a2:	00002097          	auipc	ra,0x2
    35a6:	3e8080e7          	jalr	1000(ra) # 598a <printf>
    exit(1);
    35aa:	4505                	li	a0,1
    35ac:	00002097          	auipc	ra,0x2
    35b0:	066080e7          	jalr	102(ra) # 5612 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    35b4:	85ca                	mv	a1,s2
    35b6:	00004517          	auipc	a0,0x4
    35ba:	e3250513          	addi	a0,a0,-462 # 73e8 <statistics+0x18bc>
    35be:	00002097          	auipc	ra,0x2
    35c2:	3cc080e7          	jalr	972(ra) # 598a <printf>
    exit(1);
    35c6:	4505                	li	a0,1
    35c8:	00002097          	auipc	ra,0x2
    35cc:	04a080e7          	jalr	74(ra) # 5612 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    35d0:	85ca                	mv	a1,s2
    35d2:	00004517          	auipc	a0,0x4
    35d6:	e3650513          	addi	a0,a0,-458 # 7408 <statistics+0x18dc>
    35da:	00002097          	auipc	ra,0x2
    35de:	3b0080e7          	jalr	944(ra) # 598a <printf>
    exit(1);
    35e2:	4505                	li	a0,1
    35e4:	00002097          	auipc	ra,0x2
    35e8:	02e080e7          	jalr	46(ra) # 5612 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    35ec:	85ca                	mv	a1,s2
    35ee:	00004517          	auipc	a0,0x4
    35f2:	e5a50513          	addi	a0,a0,-422 # 7448 <statistics+0x191c>
    35f6:	00002097          	auipc	ra,0x2
    35fa:	394080e7          	jalr	916(ra) # 598a <printf>
    exit(1);
    35fe:	4505                	li	a0,1
    3600:	00002097          	auipc	ra,0x2
    3604:	012080e7          	jalr	18(ra) # 5612 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3608:	85ca                	mv	a1,s2
    360a:	00004517          	auipc	a0,0x4
    360e:	e6e50513          	addi	a0,a0,-402 # 7478 <statistics+0x194c>
    3612:	00002097          	auipc	ra,0x2
    3616:	378080e7          	jalr	888(ra) # 598a <printf>
    exit(1);
    361a:	4505                	li	a0,1
    361c:	00002097          	auipc	ra,0x2
    3620:	ff6080e7          	jalr	-10(ra) # 5612 <exit>
    printf("%s: create dd succeeded!\n", s);
    3624:	85ca                	mv	a1,s2
    3626:	00004517          	auipc	a0,0x4
    362a:	e7250513          	addi	a0,a0,-398 # 7498 <statistics+0x196c>
    362e:	00002097          	auipc	ra,0x2
    3632:	35c080e7          	jalr	860(ra) # 598a <printf>
    exit(1);
    3636:	4505                	li	a0,1
    3638:	00002097          	auipc	ra,0x2
    363c:	fda080e7          	jalr	-38(ra) # 5612 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3640:	85ca                	mv	a1,s2
    3642:	00004517          	auipc	a0,0x4
    3646:	e7650513          	addi	a0,a0,-394 # 74b8 <statistics+0x198c>
    364a:	00002097          	auipc	ra,0x2
    364e:	340080e7          	jalr	832(ra) # 598a <printf>
    exit(1);
    3652:	4505                	li	a0,1
    3654:	00002097          	auipc	ra,0x2
    3658:	fbe080e7          	jalr	-66(ra) # 5612 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    365c:	85ca                	mv	a1,s2
    365e:	00004517          	auipc	a0,0x4
    3662:	e7a50513          	addi	a0,a0,-390 # 74d8 <statistics+0x19ac>
    3666:	00002097          	auipc	ra,0x2
    366a:	324080e7          	jalr	804(ra) # 598a <printf>
    exit(1);
    366e:	4505                	li	a0,1
    3670:	00002097          	auipc	ra,0x2
    3674:	fa2080e7          	jalr	-94(ra) # 5612 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3678:	85ca                	mv	a1,s2
    367a:	00004517          	auipc	a0,0x4
    367e:	e8e50513          	addi	a0,a0,-370 # 7508 <statistics+0x19dc>
    3682:	00002097          	auipc	ra,0x2
    3686:	308080e7          	jalr	776(ra) # 598a <printf>
    exit(1);
    368a:	4505                	li	a0,1
    368c:	00002097          	auipc	ra,0x2
    3690:	f86080e7          	jalr	-122(ra) # 5612 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3694:	85ca                	mv	a1,s2
    3696:	00004517          	auipc	a0,0x4
    369a:	e9a50513          	addi	a0,a0,-358 # 7530 <statistics+0x1a04>
    369e:	00002097          	auipc	ra,0x2
    36a2:	2ec080e7          	jalr	748(ra) # 598a <printf>
    exit(1);
    36a6:	4505                	li	a0,1
    36a8:	00002097          	auipc	ra,0x2
    36ac:	f6a080e7          	jalr	-150(ra) # 5612 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    36b0:	85ca                	mv	a1,s2
    36b2:	00004517          	auipc	a0,0x4
    36b6:	ea650513          	addi	a0,a0,-346 # 7558 <statistics+0x1a2c>
    36ba:	00002097          	auipc	ra,0x2
    36be:	2d0080e7          	jalr	720(ra) # 598a <printf>
    exit(1);
    36c2:	4505                	li	a0,1
    36c4:	00002097          	auipc	ra,0x2
    36c8:	f4e080e7          	jalr	-178(ra) # 5612 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    36cc:	85ca                	mv	a1,s2
    36ce:	00004517          	auipc	a0,0x4
    36d2:	eb250513          	addi	a0,a0,-334 # 7580 <statistics+0x1a54>
    36d6:	00002097          	auipc	ra,0x2
    36da:	2b4080e7          	jalr	692(ra) # 598a <printf>
    exit(1);
    36de:	4505                	li	a0,1
    36e0:	00002097          	auipc	ra,0x2
    36e4:	f32080e7          	jalr	-206(ra) # 5612 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    36e8:	85ca                	mv	a1,s2
    36ea:	00004517          	auipc	a0,0x4
    36ee:	eb650513          	addi	a0,a0,-330 # 75a0 <statistics+0x1a74>
    36f2:	00002097          	auipc	ra,0x2
    36f6:	298080e7          	jalr	664(ra) # 598a <printf>
    exit(1);
    36fa:	4505                	li	a0,1
    36fc:	00002097          	auipc	ra,0x2
    3700:	f16080e7          	jalr	-234(ra) # 5612 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3704:	85ca                	mv	a1,s2
    3706:	00004517          	auipc	a0,0x4
    370a:	eba50513          	addi	a0,a0,-326 # 75c0 <statistics+0x1a94>
    370e:	00002097          	auipc	ra,0x2
    3712:	27c080e7          	jalr	636(ra) # 598a <printf>
    exit(1);
    3716:	4505                	li	a0,1
    3718:	00002097          	auipc	ra,0x2
    371c:	efa080e7          	jalr	-262(ra) # 5612 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3720:	85ca                	mv	a1,s2
    3722:	00004517          	auipc	a0,0x4
    3726:	ec650513          	addi	a0,a0,-314 # 75e8 <statistics+0x1abc>
    372a:	00002097          	auipc	ra,0x2
    372e:	260080e7          	jalr	608(ra) # 598a <printf>
    exit(1);
    3732:	4505                	li	a0,1
    3734:	00002097          	auipc	ra,0x2
    3738:	ede080e7          	jalr	-290(ra) # 5612 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    373c:	85ca                	mv	a1,s2
    373e:	00004517          	auipc	a0,0x4
    3742:	eca50513          	addi	a0,a0,-310 # 7608 <statistics+0x1adc>
    3746:	00002097          	auipc	ra,0x2
    374a:	244080e7          	jalr	580(ra) # 598a <printf>
    exit(1);
    374e:	4505                	li	a0,1
    3750:	00002097          	auipc	ra,0x2
    3754:	ec2080e7          	jalr	-318(ra) # 5612 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3758:	85ca                	mv	a1,s2
    375a:	00004517          	auipc	a0,0x4
    375e:	ece50513          	addi	a0,a0,-306 # 7628 <statistics+0x1afc>
    3762:	00002097          	auipc	ra,0x2
    3766:	228080e7          	jalr	552(ra) # 598a <printf>
    exit(1);
    376a:	4505                	li	a0,1
    376c:	00002097          	auipc	ra,0x2
    3770:	ea6080e7          	jalr	-346(ra) # 5612 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3774:	85ca                	mv	a1,s2
    3776:	00004517          	auipc	a0,0x4
    377a:	eda50513          	addi	a0,a0,-294 # 7650 <statistics+0x1b24>
    377e:	00002097          	auipc	ra,0x2
    3782:	20c080e7          	jalr	524(ra) # 598a <printf>
    exit(1);
    3786:	4505                	li	a0,1
    3788:	00002097          	auipc	ra,0x2
    378c:	e8a080e7          	jalr	-374(ra) # 5612 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3790:	85ca                	mv	a1,s2
    3792:	00004517          	auipc	a0,0x4
    3796:	b5650513          	addi	a0,a0,-1194 # 72e8 <statistics+0x17bc>
    379a:	00002097          	auipc	ra,0x2
    379e:	1f0080e7          	jalr	496(ra) # 598a <printf>
    exit(1);
    37a2:	4505                	li	a0,1
    37a4:	00002097          	auipc	ra,0x2
    37a8:	e6e080e7          	jalr	-402(ra) # 5612 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    37ac:	85ca                	mv	a1,s2
    37ae:	00004517          	auipc	a0,0x4
    37b2:	ec250513          	addi	a0,a0,-318 # 7670 <statistics+0x1b44>
    37b6:	00002097          	auipc	ra,0x2
    37ba:	1d4080e7          	jalr	468(ra) # 598a <printf>
    exit(1);
    37be:	4505                	li	a0,1
    37c0:	00002097          	auipc	ra,0x2
    37c4:	e52080e7          	jalr	-430(ra) # 5612 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    37c8:	85ca                	mv	a1,s2
    37ca:	00004517          	auipc	a0,0x4
    37ce:	ec650513          	addi	a0,a0,-314 # 7690 <statistics+0x1b64>
    37d2:	00002097          	auipc	ra,0x2
    37d6:	1b8080e7          	jalr	440(ra) # 598a <printf>
    exit(1);
    37da:	4505                	li	a0,1
    37dc:	00002097          	auipc	ra,0x2
    37e0:	e36080e7          	jalr	-458(ra) # 5612 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    37e4:	85ca                	mv	a1,s2
    37e6:	00004517          	auipc	a0,0x4
    37ea:	eda50513          	addi	a0,a0,-294 # 76c0 <statistics+0x1b94>
    37ee:	00002097          	auipc	ra,0x2
    37f2:	19c080e7          	jalr	412(ra) # 598a <printf>
    exit(1);
    37f6:	4505                	li	a0,1
    37f8:	00002097          	auipc	ra,0x2
    37fc:	e1a080e7          	jalr	-486(ra) # 5612 <exit>
    printf("%s: unlink dd failed\n", s);
    3800:	85ca                	mv	a1,s2
    3802:	00004517          	auipc	a0,0x4
    3806:	ede50513          	addi	a0,a0,-290 # 76e0 <statistics+0x1bb4>
    380a:	00002097          	auipc	ra,0x2
    380e:	180080e7          	jalr	384(ra) # 598a <printf>
    exit(1);
    3812:	4505                	li	a0,1
    3814:	00002097          	auipc	ra,0x2
    3818:	dfe080e7          	jalr	-514(ra) # 5612 <exit>

000000000000381c <rmdot>:
{
    381c:	1101                	addi	sp,sp,-32
    381e:	ec06                	sd	ra,24(sp)
    3820:	e822                	sd	s0,16(sp)
    3822:	e426                	sd	s1,8(sp)
    3824:	1000                	addi	s0,sp,32
    3826:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3828:	00004517          	auipc	a0,0x4
    382c:	ed050513          	addi	a0,a0,-304 # 76f8 <statistics+0x1bcc>
    3830:	00002097          	auipc	ra,0x2
    3834:	e4a080e7          	jalr	-438(ra) # 567a <mkdir>
    3838:	e549                	bnez	a0,38c2 <rmdot+0xa6>
  if(chdir("dots") != 0){
    383a:	00004517          	auipc	a0,0x4
    383e:	ebe50513          	addi	a0,a0,-322 # 76f8 <statistics+0x1bcc>
    3842:	00002097          	auipc	ra,0x2
    3846:	e40080e7          	jalr	-448(ra) # 5682 <chdir>
    384a:	e951                	bnez	a0,38de <rmdot+0xc2>
  if(unlink(".") == 0){
    384c:	00003517          	auipc	a0,0x3
    3850:	d5c50513          	addi	a0,a0,-676 # 65a8 <statistics+0xa7c>
    3854:	00002097          	auipc	ra,0x2
    3858:	e0e080e7          	jalr	-498(ra) # 5662 <unlink>
    385c:	cd59                	beqz	a0,38fa <rmdot+0xde>
  if(unlink("..") == 0){
    385e:	00004517          	auipc	a0,0x4
    3862:	8f250513          	addi	a0,a0,-1806 # 7150 <statistics+0x1624>
    3866:	00002097          	auipc	ra,0x2
    386a:	dfc080e7          	jalr	-516(ra) # 5662 <unlink>
    386e:	c545                	beqz	a0,3916 <rmdot+0xfa>
  if(chdir("/") != 0){
    3870:	00004517          	auipc	a0,0x4
    3874:	88850513          	addi	a0,a0,-1912 # 70f8 <statistics+0x15cc>
    3878:	00002097          	auipc	ra,0x2
    387c:	e0a080e7          	jalr	-502(ra) # 5682 <chdir>
    3880:	e94d                	bnez	a0,3932 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3882:	00004517          	auipc	a0,0x4
    3886:	ede50513          	addi	a0,a0,-290 # 7760 <statistics+0x1c34>
    388a:	00002097          	auipc	ra,0x2
    388e:	dd8080e7          	jalr	-552(ra) # 5662 <unlink>
    3892:	cd55                	beqz	a0,394e <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3894:	00004517          	auipc	a0,0x4
    3898:	ef450513          	addi	a0,a0,-268 # 7788 <statistics+0x1c5c>
    389c:	00002097          	auipc	ra,0x2
    38a0:	dc6080e7          	jalr	-570(ra) # 5662 <unlink>
    38a4:	c179                	beqz	a0,396a <rmdot+0x14e>
  if(unlink("dots") != 0){
    38a6:	00004517          	auipc	a0,0x4
    38aa:	e5250513          	addi	a0,a0,-430 # 76f8 <statistics+0x1bcc>
    38ae:	00002097          	auipc	ra,0x2
    38b2:	db4080e7          	jalr	-588(ra) # 5662 <unlink>
    38b6:	e961                	bnez	a0,3986 <rmdot+0x16a>
}
    38b8:	60e2                	ld	ra,24(sp)
    38ba:	6442                	ld	s0,16(sp)
    38bc:	64a2                	ld	s1,8(sp)
    38be:	6105                	addi	sp,sp,32
    38c0:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    38c2:	85a6                	mv	a1,s1
    38c4:	00004517          	auipc	a0,0x4
    38c8:	e3c50513          	addi	a0,a0,-452 # 7700 <statistics+0x1bd4>
    38cc:	00002097          	auipc	ra,0x2
    38d0:	0be080e7          	jalr	190(ra) # 598a <printf>
    exit(1);
    38d4:	4505                	li	a0,1
    38d6:	00002097          	auipc	ra,0x2
    38da:	d3c080e7          	jalr	-708(ra) # 5612 <exit>
    printf("%s: chdir dots failed\n", s);
    38de:	85a6                	mv	a1,s1
    38e0:	00004517          	auipc	a0,0x4
    38e4:	e3850513          	addi	a0,a0,-456 # 7718 <statistics+0x1bec>
    38e8:	00002097          	auipc	ra,0x2
    38ec:	0a2080e7          	jalr	162(ra) # 598a <printf>
    exit(1);
    38f0:	4505                	li	a0,1
    38f2:	00002097          	auipc	ra,0x2
    38f6:	d20080e7          	jalr	-736(ra) # 5612 <exit>
    printf("%s: rm . worked!\n", s);
    38fa:	85a6                	mv	a1,s1
    38fc:	00004517          	auipc	a0,0x4
    3900:	e3450513          	addi	a0,a0,-460 # 7730 <statistics+0x1c04>
    3904:	00002097          	auipc	ra,0x2
    3908:	086080e7          	jalr	134(ra) # 598a <printf>
    exit(1);
    390c:	4505                	li	a0,1
    390e:	00002097          	auipc	ra,0x2
    3912:	d04080e7          	jalr	-764(ra) # 5612 <exit>
    printf("%s: rm .. worked!\n", s);
    3916:	85a6                	mv	a1,s1
    3918:	00004517          	auipc	a0,0x4
    391c:	e3050513          	addi	a0,a0,-464 # 7748 <statistics+0x1c1c>
    3920:	00002097          	auipc	ra,0x2
    3924:	06a080e7          	jalr	106(ra) # 598a <printf>
    exit(1);
    3928:	4505                	li	a0,1
    392a:	00002097          	auipc	ra,0x2
    392e:	ce8080e7          	jalr	-792(ra) # 5612 <exit>
    printf("%s: chdir / failed\n", s);
    3932:	85a6                	mv	a1,s1
    3934:	00003517          	auipc	a0,0x3
    3938:	7cc50513          	addi	a0,a0,1996 # 7100 <statistics+0x15d4>
    393c:	00002097          	auipc	ra,0x2
    3940:	04e080e7          	jalr	78(ra) # 598a <printf>
    exit(1);
    3944:	4505                	li	a0,1
    3946:	00002097          	auipc	ra,0x2
    394a:	ccc080e7          	jalr	-820(ra) # 5612 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    394e:	85a6                	mv	a1,s1
    3950:	00004517          	auipc	a0,0x4
    3954:	e1850513          	addi	a0,a0,-488 # 7768 <statistics+0x1c3c>
    3958:	00002097          	auipc	ra,0x2
    395c:	032080e7          	jalr	50(ra) # 598a <printf>
    exit(1);
    3960:	4505                	li	a0,1
    3962:	00002097          	auipc	ra,0x2
    3966:	cb0080e7          	jalr	-848(ra) # 5612 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    396a:	85a6                	mv	a1,s1
    396c:	00004517          	auipc	a0,0x4
    3970:	e2450513          	addi	a0,a0,-476 # 7790 <statistics+0x1c64>
    3974:	00002097          	auipc	ra,0x2
    3978:	016080e7          	jalr	22(ra) # 598a <printf>
    exit(1);
    397c:	4505                	li	a0,1
    397e:	00002097          	auipc	ra,0x2
    3982:	c94080e7          	jalr	-876(ra) # 5612 <exit>
    printf("%s: unlink dots failed!\n", s);
    3986:	85a6                	mv	a1,s1
    3988:	00004517          	auipc	a0,0x4
    398c:	e2850513          	addi	a0,a0,-472 # 77b0 <statistics+0x1c84>
    3990:	00002097          	auipc	ra,0x2
    3994:	ffa080e7          	jalr	-6(ra) # 598a <printf>
    exit(1);
    3998:	4505                	li	a0,1
    399a:	00002097          	auipc	ra,0x2
    399e:	c78080e7          	jalr	-904(ra) # 5612 <exit>

00000000000039a2 <dirfile>:
{
    39a2:	1101                	addi	sp,sp,-32
    39a4:	ec06                	sd	ra,24(sp)
    39a6:	e822                	sd	s0,16(sp)
    39a8:	e426                	sd	s1,8(sp)
    39aa:	e04a                	sd	s2,0(sp)
    39ac:	1000                	addi	s0,sp,32
    39ae:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    39b0:	20000593          	li	a1,512
    39b4:	00002517          	auipc	a0,0x2
    39b8:	4fc50513          	addi	a0,a0,1276 # 5eb0 <statistics+0x384>
    39bc:	00002097          	auipc	ra,0x2
    39c0:	c96080e7          	jalr	-874(ra) # 5652 <open>
  if(fd < 0){
    39c4:	0e054d63          	bltz	a0,3abe <dirfile+0x11c>
  close(fd);
    39c8:	00002097          	auipc	ra,0x2
    39cc:	c72080e7          	jalr	-910(ra) # 563a <close>
  if(chdir("dirfile") == 0){
    39d0:	00002517          	auipc	a0,0x2
    39d4:	4e050513          	addi	a0,a0,1248 # 5eb0 <statistics+0x384>
    39d8:	00002097          	auipc	ra,0x2
    39dc:	caa080e7          	jalr	-854(ra) # 5682 <chdir>
    39e0:	cd6d                	beqz	a0,3ada <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    39e2:	4581                	li	a1,0
    39e4:	00004517          	auipc	a0,0x4
    39e8:	e2c50513          	addi	a0,a0,-468 # 7810 <statistics+0x1ce4>
    39ec:	00002097          	auipc	ra,0x2
    39f0:	c66080e7          	jalr	-922(ra) # 5652 <open>
  if(fd >= 0){
    39f4:	10055163          	bgez	a0,3af6 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    39f8:	20000593          	li	a1,512
    39fc:	00004517          	auipc	a0,0x4
    3a00:	e1450513          	addi	a0,a0,-492 # 7810 <statistics+0x1ce4>
    3a04:	00002097          	auipc	ra,0x2
    3a08:	c4e080e7          	jalr	-946(ra) # 5652 <open>
  if(fd >= 0){
    3a0c:	10055363          	bgez	a0,3b12 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3a10:	00004517          	auipc	a0,0x4
    3a14:	e0050513          	addi	a0,a0,-512 # 7810 <statistics+0x1ce4>
    3a18:	00002097          	auipc	ra,0x2
    3a1c:	c62080e7          	jalr	-926(ra) # 567a <mkdir>
    3a20:	10050763          	beqz	a0,3b2e <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3a24:	00004517          	auipc	a0,0x4
    3a28:	dec50513          	addi	a0,a0,-532 # 7810 <statistics+0x1ce4>
    3a2c:	00002097          	auipc	ra,0x2
    3a30:	c36080e7          	jalr	-970(ra) # 5662 <unlink>
    3a34:	10050b63          	beqz	a0,3b4a <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3a38:	00004597          	auipc	a1,0x4
    3a3c:	dd858593          	addi	a1,a1,-552 # 7810 <statistics+0x1ce4>
    3a40:	00002517          	auipc	a0,0x2
    3a44:	66850513          	addi	a0,a0,1640 # 60a8 <statistics+0x57c>
    3a48:	00002097          	auipc	ra,0x2
    3a4c:	c2a080e7          	jalr	-982(ra) # 5672 <link>
    3a50:	10050b63          	beqz	a0,3b66 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3a54:	00002517          	auipc	a0,0x2
    3a58:	45c50513          	addi	a0,a0,1116 # 5eb0 <statistics+0x384>
    3a5c:	00002097          	auipc	ra,0x2
    3a60:	c06080e7          	jalr	-1018(ra) # 5662 <unlink>
    3a64:	10051f63          	bnez	a0,3b82 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3a68:	4589                	li	a1,2
    3a6a:	00003517          	auipc	a0,0x3
    3a6e:	b3e50513          	addi	a0,a0,-1218 # 65a8 <statistics+0xa7c>
    3a72:	00002097          	auipc	ra,0x2
    3a76:	be0080e7          	jalr	-1056(ra) # 5652 <open>
  if(fd >= 0){
    3a7a:	12055263          	bgez	a0,3b9e <dirfile+0x1fc>
  fd = open(".", 0);
    3a7e:	4581                	li	a1,0
    3a80:	00003517          	auipc	a0,0x3
    3a84:	b2850513          	addi	a0,a0,-1240 # 65a8 <statistics+0xa7c>
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	bca080e7          	jalr	-1078(ra) # 5652 <open>
    3a90:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3a92:	4605                	li	a2,1
    3a94:	00002597          	auipc	a1,0x2
    3a98:	4ec58593          	addi	a1,a1,1260 # 5f80 <statistics+0x454>
    3a9c:	00002097          	auipc	ra,0x2
    3aa0:	b96080e7          	jalr	-1130(ra) # 5632 <write>
    3aa4:	10a04b63          	bgtz	a0,3bba <dirfile+0x218>
  close(fd);
    3aa8:	8526                	mv	a0,s1
    3aaa:	00002097          	auipc	ra,0x2
    3aae:	b90080e7          	jalr	-1136(ra) # 563a <close>
}
    3ab2:	60e2                	ld	ra,24(sp)
    3ab4:	6442                	ld	s0,16(sp)
    3ab6:	64a2                	ld	s1,8(sp)
    3ab8:	6902                	ld	s2,0(sp)
    3aba:	6105                	addi	sp,sp,32
    3abc:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3abe:	85ca                	mv	a1,s2
    3ac0:	00004517          	auipc	a0,0x4
    3ac4:	d1050513          	addi	a0,a0,-752 # 77d0 <statistics+0x1ca4>
    3ac8:	00002097          	auipc	ra,0x2
    3acc:	ec2080e7          	jalr	-318(ra) # 598a <printf>
    exit(1);
    3ad0:	4505                	li	a0,1
    3ad2:	00002097          	auipc	ra,0x2
    3ad6:	b40080e7          	jalr	-1216(ra) # 5612 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3ada:	85ca                	mv	a1,s2
    3adc:	00004517          	auipc	a0,0x4
    3ae0:	d1450513          	addi	a0,a0,-748 # 77f0 <statistics+0x1cc4>
    3ae4:	00002097          	auipc	ra,0x2
    3ae8:	ea6080e7          	jalr	-346(ra) # 598a <printf>
    exit(1);
    3aec:	4505                	li	a0,1
    3aee:	00002097          	auipc	ra,0x2
    3af2:	b24080e7          	jalr	-1244(ra) # 5612 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3af6:	85ca                	mv	a1,s2
    3af8:	00004517          	auipc	a0,0x4
    3afc:	d2850513          	addi	a0,a0,-728 # 7820 <statistics+0x1cf4>
    3b00:	00002097          	auipc	ra,0x2
    3b04:	e8a080e7          	jalr	-374(ra) # 598a <printf>
    exit(1);
    3b08:	4505                	li	a0,1
    3b0a:	00002097          	auipc	ra,0x2
    3b0e:	b08080e7          	jalr	-1272(ra) # 5612 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b12:	85ca                	mv	a1,s2
    3b14:	00004517          	auipc	a0,0x4
    3b18:	d0c50513          	addi	a0,a0,-756 # 7820 <statistics+0x1cf4>
    3b1c:	00002097          	auipc	ra,0x2
    3b20:	e6e080e7          	jalr	-402(ra) # 598a <printf>
    exit(1);
    3b24:	4505                	li	a0,1
    3b26:	00002097          	auipc	ra,0x2
    3b2a:	aec080e7          	jalr	-1300(ra) # 5612 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3b2e:	85ca                	mv	a1,s2
    3b30:	00004517          	auipc	a0,0x4
    3b34:	d1850513          	addi	a0,a0,-744 # 7848 <statistics+0x1d1c>
    3b38:	00002097          	auipc	ra,0x2
    3b3c:	e52080e7          	jalr	-430(ra) # 598a <printf>
    exit(1);
    3b40:	4505                	li	a0,1
    3b42:	00002097          	auipc	ra,0x2
    3b46:	ad0080e7          	jalr	-1328(ra) # 5612 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3b4a:	85ca                	mv	a1,s2
    3b4c:	00004517          	auipc	a0,0x4
    3b50:	d2450513          	addi	a0,a0,-732 # 7870 <statistics+0x1d44>
    3b54:	00002097          	auipc	ra,0x2
    3b58:	e36080e7          	jalr	-458(ra) # 598a <printf>
    exit(1);
    3b5c:	4505                	li	a0,1
    3b5e:	00002097          	auipc	ra,0x2
    3b62:	ab4080e7          	jalr	-1356(ra) # 5612 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3b66:	85ca                	mv	a1,s2
    3b68:	00004517          	auipc	a0,0x4
    3b6c:	d3050513          	addi	a0,a0,-720 # 7898 <statistics+0x1d6c>
    3b70:	00002097          	auipc	ra,0x2
    3b74:	e1a080e7          	jalr	-486(ra) # 598a <printf>
    exit(1);
    3b78:	4505                	li	a0,1
    3b7a:	00002097          	auipc	ra,0x2
    3b7e:	a98080e7          	jalr	-1384(ra) # 5612 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3b82:	85ca                	mv	a1,s2
    3b84:	00004517          	auipc	a0,0x4
    3b88:	d3c50513          	addi	a0,a0,-708 # 78c0 <statistics+0x1d94>
    3b8c:	00002097          	auipc	ra,0x2
    3b90:	dfe080e7          	jalr	-514(ra) # 598a <printf>
    exit(1);
    3b94:	4505                	li	a0,1
    3b96:	00002097          	auipc	ra,0x2
    3b9a:	a7c080e7          	jalr	-1412(ra) # 5612 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3b9e:	85ca                	mv	a1,s2
    3ba0:	00004517          	auipc	a0,0x4
    3ba4:	d4050513          	addi	a0,a0,-704 # 78e0 <statistics+0x1db4>
    3ba8:	00002097          	auipc	ra,0x2
    3bac:	de2080e7          	jalr	-542(ra) # 598a <printf>
    exit(1);
    3bb0:	4505                	li	a0,1
    3bb2:	00002097          	auipc	ra,0x2
    3bb6:	a60080e7          	jalr	-1440(ra) # 5612 <exit>
    printf("%s: write . succeeded!\n", s);
    3bba:	85ca                	mv	a1,s2
    3bbc:	00004517          	auipc	a0,0x4
    3bc0:	d4c50513          	addi	a0,a0,-692 # 7908 <statistics+0x1ddc>
    3bc4:	00002097          	auipc	ra,0x2
    3bc8:	dc6080e7          	jalr	-570(ra) # 598a <printf>
    exit(1);
    3bcc:	4505                	li	a0,1
    3bce:	00002097          	auipc	ra,0x2
    3bd2:	a44080e7          	jalr	-1468(ra) # 5612 <exit>

0000000000003bd6 <iref>:
{
    3bd6:	7139                	addi	sp,sp,-64
    3bd8:	fc06                	sd	ra,56(sp)
    3bda:	f822                	sd	s0,48(sp)
    3bdc:	f426                	sd	s1,40(sp)
    3bde:	f04a                	sd	s2,32(sp)
    3be0:	ec4e                	sd	s3,24(sp)
    3be2:	e852                	sd	s4,16(sp)
    3be4:	e456                	sd	s5,8(sp)
    3be6:	e05a                	sd	s6,0(sp)
    3be8:	0080                	addi	s0,sp,64
    3bea:	8b2a                	mv	s6,a0
    3bec:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3bf0:	00004a17          	auipc	s4,0x4
    3bf4:	d30a0a13          	addi	s4,s4,-720 # 7920 <statistics+0x1df4>
    mkdir("");
    3bf8:	00004497          	auipc	s1,0x4
    3bfc:	83848493          	addi	s1,s1,-1992 # 7430 <statistics+0x1904>
    link("README", "");
    3c00:	00002a97          	auipc	s5,0x2
    3c04:	4a8a8a93          	addi	s5,s5,1192 # 60a8 <statistics+0x57c>
    fd = open("xx", O_CREATE);
    3c08:	00004997          	auipc	s3,0x4
    3c0c:	c1098993          	addi	s3,s3,-1008 # 7818 <statistics+0x1cec>
    3c10:	a891                	j	3c64 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3c12:	85da                	mv	a1,s6
    3c14:	00004517          	auipc	a0,0x4
    3c18:	d1450513          	addi	a0,a0,-748 # 7928 <statistics+0x1dfc>
    3c1c:	00002097          	auipc	ra,0x2
    3c20:	d6e080e7          	jalr	-658(ra) # 598a <printf>
      exit(1);
    3c24:	4505                	li	a0,1
    3c26:	00002097          	auipc	ra,0x2
    3c2a:	9ec080e7          	jalr	-1556(ra) # 5612 <exit>
      printf("%s: chdir irefd failed\n", s);
    3c2e:	85da                	mv	a1,s6
    3c30:	00004517          	auipc	a0,0x4
    3c34:	d1050513          	addi	a0,a0,-752 # 7940 <statistics+0x1e14>
    3c38:	00002097          	auipc	ra,0x2
    3c3c:	d52080e7          	jalr	-686(ra) # 598a <printf>
      exit(1);
    3c40:	4505                	li	a0,1
    3c42:	00002097          	auipc	ra,0x2
    3c46:	9d0080e7          	jalr	-1584(ra) # 5612 <exit>
      close(fd);
    3c4a:	00002097          	auipc	ra,0x2
    3c4e:	9f0080e7          	jalr	-1552(ra) # 563a <close>
    3c52:	a889                	j	3ca4 <iref+0xce>
    unlink("xx");
    3c54:	854e                	mv	a0,s3
    3c56:	00002097          	auipc	ra,0x2
    3c5a:	a0c080e7          	jalr	-1524(ra) # 5662 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3c5e:	397d                	addiw	s2,s2,-1
    3c60:	06090063          	beqz	s2,3cc0 <iref+0xea>
    if(mkdir("irefd") != 0){
    3c64:	8552                	mv	a0,s4
    3c66:	00002097          	auipc	ra,0x2
    3c6a:	a14080e7          	jalr	-1516(ra) # 567a <mkdir>
    3c6e:	f155                	bnez	a0,3c12 <iref+0x3c>
    if(chdir("irefd") != 0){
    3c70:	8552                	mv	a0,s4
    3c72:	00002097          	auipc	ra,0x2
    3c76:	a10080e7          	jalr	-1520(ra) # 5682 <chdir>
    3c7a:	f955                	bnez	a0,3c2e <iref+0x58>
    mkdir("");
    3c7c:	8526                	mv	a0,s1
    3c7e:	00002097          	auipc	ra,0x2
    3c82:	9fc080e7          	jalr	-1540(ra) # 567a <mkdir>
    link("README", "");
    3c86:	85a6                	mv	a1,s1
    3c88:	8556                	mv	a0,s5
    3c8a:	00002097          	auipc	ra,0x2
    3c8e:	9e8080e7          	jalr	-1560(ra) # 5672 <link>
    fd = open("", O_CREATE);
    3c92:	20000593          	li	a1,512
    3c96:	8526                	mv	a0,s1
    3c98:	00002097          	auipc	ra,0x2
    3c9c:	9ba080e7          	jalr	-1606(ra) # 5652 <open>
    if(fd >= 0)
    3ca0:	fa0555e3          	bgez	a0,3c4a <iref+0x74>
    fd = open("xx", O_CREATE);
    3ca4:	20000593          	li	a1,512
    3ca8:	854e                	mv	a0,s3
    3caa:	00002097          	auipc	ra,0x2
    3cae:	9a8080e7          	jalr	-1624(ra) # 5652 <open>
    if(fd >= 0)
    3cb2:	fa0541e3          	bltz	a0,3c54 <iref+0x7e>
      close(fd);
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	984080e7          	jalr	-1660(ra) # 563a <close>
    3cbe:	bf59                	j	3c54 <iref+0x7e>
    3cc0:	03300493          	li	s1,51
    chdir("..");
    3cc4:	00003997          	auipc	s3,0x3
    3cc8:	48c98993          	addi	s3,s3,1164 # 7150 <statistics+0x1624>
    unlink("irefd");
    3ccc:	00004917          	auipc	s2,0x4
    3cd0:	c5490913          	addi	s2,s2,-940 # 7920 <statistics+0x1df4>
    chdir("..");
    3cd4:	854e                	mv	a0,s3
    3cd6:	00002097          	auipc	ra,0x2
    3cda:	9ac080e7          	jalr	-1620(ra) # 5682 <chdir>
    unlink("irefd");
    3cde:	854a                	mv	a0,s2
    3ce0:	00002097          	auipc	ra,0x2
    3ce4:	982080e7          	jalr	-1662(ra) # 5662 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3ce8:	34fd                	addiw	s1,s1,-1
    3cea:	f4ed                	bnez	s1,3cd4 <iref+0xfe>
  chdir("/");
    3cec:	00003517          	auipc	a0,0x3
    3cf0:	40c50513          	addi	a0,a0,1036 # 70f8 <statistics+0x15cc>
    3cf4:	00002097          	auipc	ra,0x2
    3cf8:	98e080e7          	jalr	-1650(ra) # 5682 <chdir>
}
    3cfc:	70e2                	ld	ra,56(sp)
    3cfe:	7442                	ld	s0,48(sp)
    3d00:	74a2                	ld	s1,40(sp)
    3d02:	7902                	ld	s2,32(sp)
    3d04:	69e2                	ld	s3,24(sp)
    3d06:	6a42                	ld	s4,16(sp)
    3d08:	6aa2                	ld	s5,8(sp)
    3d0a:	6b02                	ld	s6,0(sp)
    3d0c:	6121                	addi	sp,sp,64
    3d0e:	8082                	ret

0000000000003d10 <openiputtest>:
{
    3d10:	7179                	addi	sp,sp,-48
    3d12:	f406                	sd	ra,40(sp)
    3d14:	f022                	sd	s0,32(sp)
    3d16:	ec26                	sd	s1,24(sp)
    3d18:	1800                	addi	s0,sp,48
    3d1a:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3d1c:	00004517          	auipc	a0,0x4
    3d20:	c3c50513          	addi	a0,a0,-964 # 7958 <statistics+0x1e2c>
    3d24:	00002097          	auipc	ra,0x2
    3d28:	956080e7          	jalr	-1706(ra) # 567a <mkdir>
    3d2c:	04054263          	bltz	a0,3d70 <openiputtest+0x60>
  pid = fork();
    3d30:	00002097          	auipc	ra,0x2
    3d34:	8da080e7          	jalr	-1830(ra) # 560a <fork>
  if(pid < 0){
    3d38:	04054a63          	bltz	a0,3d8c <openiputtest+0x7c>
  if(pid == 0){
    3d3c:	e93d                	bnez	a0,3db2 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3d3e:	4589                	li	a1,2
    3d40:	00004517          	auipc	a0,0x4
    3d44:	c1850513          	addi	a0,a0,-1000 # 7958 <statistics+0x1e2c>
    3d48:	00002097          	auipc	ra,0x2
    3d4c:	90a080e7          	jalr	-1782(ra) # 5652 <open>
    if(fd >= 0){
    3d50:	04054c63          	bltz	a0,3da8 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3d54:	85a6                	mv	a1,s1
    3d56:	00004517          	auipc	a0,0x4
    3d5a:	c2250513          	addi	a0,a0,-990 # 7978 <statistics+0x1e4c>
    3d5e:	00002097          	auipc	ra,0x2
    3d62:	c2c080e7          	jalr	-980(ra) # 598a <printf>
      exit(1);
    3d66:	4505                	li	a0,1
    3d68:	00002097          	auipc	ra,0x2
    3d6c:	8aa080e7          	jalr	-1878(ra) # 5612 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3d70:	85a6                	mv	a1,s1
    3d72:	00004517          	auipc	a0,0x4
    3d76:	bee50513          	addi	a0,a0,-1042 # 7960 <statistics+0x1e34>
    3d7a:	00002097          	auipc	ra,0x2
    3d7e:	c10080e7          	jalr	-1008(ra) # 598a <printf>
    exit(1);
    3d82:	4505                	li	a0,1
    3d84:	00002097          	auipc	ra,0x2
    3d88:	88e080e7          	jalr	-1906(ra) # 5612 <exit>
    printf("%s: fork failed\n", s);
    3d8c:	85a6                	mv	a1,s1
    3d8e:	00003517          	auipc	a0,0x3
    3d92:	9ba50513          	addi	a0,a0,-1606 # 6748 <statistics+0xc1c>
    3d96:	00002097          	auipc	ra,0x2
    3d9a:	bf4080e7          	jalr	-1036(ra) # 598a <printf>
    exit(1);
    3d9e:	4505                	li	a0,1
    3da0:	00002097          	auipc	ra,0x2
    3da4:	872080e7          	jalr	-1934(ra) # 5612 <exit>
    exit(0);
    3da8:	4501                	li	a0,0
    3daa:	00002097          	auipc	ra,0x2
    3dae:	868080e7          	jalr	-1944(ra) # 5612 <exit>
  sleep(1);
    3db2:	4505                	li	a0,1
    3db4:	00002097          	auipc	ra,0x2
    3db8:	8ee080e7          	jalr	-1810(ra) # 56a2 <sleep>
  if(unlink("oidir") != 0){
    3dbc:	00004517          	auipc	a0,0x4
    3dc0:	b9c50513          	addi	a0,a0,-1124 # 7958 <statistics+0x1e2c>
    3dc4:	00002097          	auipc	ra,0x2
    3dc8:	89e080e7          	jalr	-1890(ra) # 5662 <unlink>
    3dcc:	cd19                	beqz	a0,3dea <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3dce:	85a6                	mv	a1,s1
    3dd0:	00003517          	auipc	a0,0x3
    3dd4:	b6850513          	addi	a0,a0,-1176 # 6938 <statistics+0xe0c>
    3dd8:	00002097          	auipc	ra,0x2
    3ddc:	bb2080e7          	jalr	-1102(ra) # 598a <printf>
    exit(1);
    3de0:	4505                	li	a0,1
    3de2:	00002097          	auipc	ra,0x2
    3de6:	830080e7          	jalr	-2000(ra) # 5612 <exit>
  wait(&xstatus);
    3dea:	fdc40513          	addi	a0,s0,-36
    3dee:	00002097          	auipc	ra,0x2
    3df2:	82c080e7          	jalr	-2004(ra) # 561a <wait>
  exit(xstatus);
    3df6:	fdc42503          	lw	a0,-36(s0)
    3dfa:	00002097          	auipc	ra,0x2
    3dfe:	818080e7          	jalr	-2024(ra) # 5612 <exit>

0000000000003e02 <forkforkfork>:
{
    3e02:	1101                	addi	sp,sp,-32
    3e04:	ec06                	sd	ra,24(sp)
    3e06:	e822                	sd	s0,16(sp)
    3e08:	e426                	sd	s1,8(sp)
    3e0a:	1000                	addi	s0,sp,32
    3e0c:	84aa                	mv	s1,a0
  unlink("stopforking");
    3e0e:	00004517          	auipc	a0,0x4
    3e12:	b9250513          	addi	a0,a0,-1134 # 79a0 <statistics+0x1e74>
    3e16:	00002097          	auipc	ra,0x2
    3e1a:	84c080e7          	jalr	-1972(ra) # 5662 <unlink>
  int pid = fork();
    3e1e:	00001097          	auipc	ra,0x1
    3e22:	7ec080e7          	jalr	2028(ra) # 560a <fork>
  if(pid < 0){
    3e26:	04054563          	bltz	a0,3e70 <forkforkfork+0x6e>
  if(pid == 0){
    3e2a:	c12d                	beqz	a0,3e8c <forkforkfork+0x8a>
  sleep(20); // two seconds
    3e2c:	4551                	li	a0,20
    3e2e:	00002097          	auipc	ra,0x2
    3e32:	874080e7          	jalr	-1932(ra) # 56a2 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3e36:	20200593          	li	a1,514
    3e3a:	00004517          	auipc	a0,0x4
    3e3e:	b6650513          	addi	a0,a0,-1178 # 79a0 <statistics+0x1e74>
    3e42:	00002097          	auipc	ra,0x2
    3e46:	810080e7          	jalr	-2032(ra) # 5652 <open>
    3e4a:	00001097          	auipc	ra,0x1
    3e4e:	7f0080e7          	jalr	2032(ra) # 563a <close>
  wait(0);
    3e52:	4501                	li	a0,0
    3e54:	00001097          	auipc	ra,0x1
    3e58:	7c6080e7          	jalr	1990(ra) # 561a <wait>
  sleep(10); // one second
    3e5c:	4529                	li	a0,10
    3e5e:	00002097          	auipc	ra,0x2
    3e62:	844080e7          	jalr	-1980(ra) # 56a2 <sleep>
}
    3e66:	60e2                	ld	ra,24(sp)
    3e68:	6442                	ld	s0,16(sp)
    3e6a:	64a2                	ld	s1,8(sp)
    3e6c:	6105                	addi	sp,sp,32
    3e6e:	8082                	ret
    printf("%s: fork failed", s);
    3e70:	85a6                	mv	a1,s1
    3e72:	00003517          	auipc	a0,0x3
    3e76:	a9650513          	addi	a0,a0,-1386 # 6908 <statistics+0xddc>
    3e7a:	00002097          	auipc	ra,0x2
    3e7e:	b10080e7          	jalr	-1264(ra) # 598a <printf>
    exit(1);
    3e82:	4505                	li	a0,1
    3e84:	00001097          	auipc	ra,0x1
    3e88:	78e080e7          	jalr	1934(ra) # 5612 <exit>
      int fd = open("stopforking", 0);
    3e8c:	00004497          	auipc	s1,0x4
    3e90:	b1448493          	addi	s1,s1,-1260 # 79a0 <statistics+0x1e74>
    3e94:	4581                	li	a1,0
    3e96:	8526                	mv	a0,s1
    3e98:	00001097          	auipc	ra,0x1
    3e9c:	7ba080e7          	jalr	1978(ra) # 5652 <open>
      if(fd >= 0){
    3ea0:	02055463          	bgez	a0,3ec8 <forkforkfork+0xc6>
      if(fork() < 0){
    3ea4:	00001097          	auipc	ra,0x1
    3ea8:	766080e7          	jalr	1894(ra) # 560a <fork>
    3eac:	fe0554e3          	bgez	a0,3e94 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3eb0:	20200593          	li	a1,514
    3eb4:	8526                	mv	a0,s1
    3eb6:	00001097          	auipc	ra,0x1
    3eba:	79c080e7          	jalr	1948(ra) # 5652 <open>
    3ebe:	00001097          	auipc	ra,0x1
    3ec2:	77c080e7          	jalr	1916(ra) # 563a <close>
    3ec6:	b7f9                	j	3e94 <forkforkfork+0x92>
        exit(0);
    3ec8:	4501                	li	a0,0
    3eca:	00001097          	auipc	ra,0x1
    3ece:	748080e7          	jalr	1864(ra) # 5612 <exit>

0000000000003ed2 <preempt>:
{
    3ed2:	7139                	addi	sp,sp,-64
    3ed4:	fc06                	sd	ra,56(sp)
    3ed6:	f822                	sd	s0,48(sp)
    3ed8:	f426                	sd	s1,40(sp)
    3eda:	f04a                	sd	s2,32(sp)
    3edc:	ec4e                	sd	s3,24(sp)
    3ede:	e852                	sd	s4,16(sp)
    3ee0:	0080                	addi	s0,sp,64
    3ee2:	84aa                	mv	s1,a0
  pid1 = fork();
    3ee4:	00001097          	auipc	ra,0x1
    3ee8:	726080e7          	jalr	1830(ra) # 560a <fork>
  if(pid1 < 0) {
    3eec:	00054563          	bltz	a0,3ef6 <preempt+0x24>
    3ef0:	8a2a                	mv	s4,a0
  if(pid1 == 0)
    3ef2:	e105                	bnez	a0,3f12 <preempt+0x40>
    for(;;)
    3ef4:	a001                	j	3ef4 <preempt+0x22>
    printf("%s: fork failed", s);
    3ef6:	85a6                	mv	a1,s1
    3ef8:	00003517          	auipc	a0,0x3
    3efc:	a1050513          	addi	a0,a0,-1520 # 6908 <statistics+0xddc>
    3f00:	00002097          	auipc	ra,0x2
    3f04:	a8a080e7          	jalr	-1398(ra) # 598a <printf>
    exit(1);
    3f08:	4505                	li	a0,1
    3f0a:	00001097          	auipc	ra,0x1
    3f0e:	708080e7          	jalr	1800(ra) # 5612 <exit>
  pid2 = fork();
    3f12:	00001097          	auipc	ra,0x1
    3f16:	6f8080e7          	jalr	1784(ra) # 560a <fork>
    3f1a:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3f1c:	00054463          	bltz	a0,3f24 <preempt+0x52>
  if(pid2 == 0)
    3f20:	e105                	bnez	a0,3f40 <preempt+0x6e>
    for(;;)
    3f22:	a001                	j	3f22 <preempt+0x50>
    printf("%s: fork failed\n", s);
    3f24:	85a6                	mv	a1,s1
    3f26:	00003517          	auipc	a0,0x3
    3f2a:	82250513          	addi	a0,a0,-2014 # 6748 <statistics+0xc1c>
    3f2e:	00002097          	auipc	ra,0x2
    3f32:	a5c080e7          	jalr	-1444(ra) # 598a <printf>
    exit(1);
    3f36:	4505                	li	a0,1
    3f38:	00001097          	auipc	ra,0x1
    3f3c:	6da080e7          	jalr	1754(ra) # 5612 <exit>
  pipe(pfds);
    3f40:	fc840513          	addi	a0,s0,-56
    3f44:	00001097          	auipc	ra,0x1
    3f48:	6de080e7          	jalr	1758(ra) # 5622 <pipe>
  pid3 = fork();
    3f4c:	00001097          	auipc	ra,0x1
    3f50:	6be080e7          	jalr	1726(ra) # 560a <fork>
    3f54:	892a                	mv	s2,a0
  if(pid3 < 0) {
    3f56:	02054e63          	bltz	a0,3f92 <preempt+0xc0>
  if(pid3 == 0){
    3f5a:	e525                	bnez	a0,3fc2 <preempt+0xf0>
    close(pfds[0]);
    3f5c:	fc842503          	lw	a0,-56(s0)
    3f60:	00001097          	auipc	ra,0x1
    3f64:	6da080e7          	jalr	1754(ra) # 563a <close>
    if(write(pfds[1], "x", 1) != 1)
    3f68:	4605                	li	a2,1
    3f6a:	00002597          	auipc	a1,0x2
    3f6e:	01658593          	addi	a1,a1,22 # 5f80 <statistics+0x454>
    3f72:	fcc42503          	lw	a0,-52(s0)
    3f76:	00001097          	auipc	ra,0x1
    3f7a:	6bc080e7          	jalr	1724(ra) # 5632 <write>
    3f7e:	4785                	li	a5,1
    3f80:	02f51763          	bne	a0,a5,3fae <preempt+0xdc>
    close(pfds[1]);
    3f84:	fcc42503          	lw	a0,-52(s0)
    3f88:	00001097          	auipc	ra,0x1
    3f8c:	6b2080e7          	jalr	1714(ra) # 563a <close>
    for(;;)
    3f90:	a001                	j	3f90 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3f92:	85a6                	mv	a1,s1
    3f94:	00002517          	auipc	a0,0x2
    3f98:	7b450513          	addi	a0,a0,1972 # 6748 <statistics+0xc1c>
    3f9c:	00002097          	auipc	ra,0x2
    3fa0:	9ee080e7          	jalr	-1554(ra) # 598a <printf>
     exit(1);
    3fa4:	4505                	li	a0,1
    3fa6:	00001097          	auipc	ra,0x1
    3faa:	66c080e7          	jalr	1644(ra) # 5612 <exit>
      printf("%s: preempt write error", s);
    3fae:	85a6                	mv	a1,s1
    3fb0:	00004517          	auipc	a0,0x4
    3fb4:	a0050513          	addi	a0,a0,-1536 # 79b0 <statistics+0x1e84>
    3fb8:	00002097          	auipc	ra,0x2
    3fbc:	9d2080e7          	jalr	-1582(ra) # 598a <printf>
    3fc0:	b7d1                	j	3f84 <preempt+0xb2>
  close(pfds[1]);
    3fc2:	fcc42503          	lw	a0,-52(s0)
    3fc6:	00001097          	auipc	ra,0x1
    3fca:	674080e7          	jalr	1652(ra) # 563a <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3fce:	660d                	lui	a2,0x3
    3fd0:	00008597          	auipc	a1,0x8
    3fd4:	b8058593          	addi	a1,a1,-1152 # bb50 <buf>
    3fd8:	fc842503          	lw	a0,-56(s0)
    3fdc:	00001097          	auipc	ra,0x1
    3fe0:	64e080e7          	jalr	1614(ra) # 562a <read>
    3fe4:	4785                	li	a5,1
    3fe6:	02f50363          	beq	a0,a5,400c <preempt+0x13a>
    printf("%s: preempt read error", s);
    3fea:	85a6                	mv	a1,s1
    3fec:	00004517          	auipc	a0,0x4
    3ff0:	9dc50513          	addi	a0,a0,-1572 # 79c8 <statistics+0x1e9c>
    3ff4:	00002097          	auipc	ra,0x2
    3ff8:	996080e7          	jalr	-1642(ra) # 598a <printf>
}
    3ffc:	70e2                	ld	ra,56(sp)
    3ffe:	7442                	ld	s0,48(sp)
    4000:	74a2                	ld	s1,40(sp)
    4002:	7902                	ld	s2,32(sp)
    4004:	69e2                	ld	s3,24(sp)
    4006:	6a42                	ld	s4,16(sp)
    4008:	6121                	addi	sp,sp,64
    400a:	8082                	ret
  close(pfds[0]);
    400c:	fc842503          	lw	a0,-56(s0)
    4010:	00001097          	auipc	ra,0x1
    4014:	62a080e7          	jalr	1578(ra) # 563a <close>
  printf("kill... ");
    4018:	00004517          	auipc	a0,0x4
    401c:	9c850513          	addi	a0,a0,-1592 # 79e0 <statistics+0x1eb4>
    4020:	00002097          	auipc	ra,0x2
    4024:	96a080e7          	jalr	-1686(ra) # 598a <printf>
  kill(pid1);
    4028:	8552                	mv	a0,s4
    402a:	00001097          	auipc	ra,0x1
    402e:	618080e7          	jalr	1560(ra) # 5642 <kill>
  kill(pid2);
    4032:	854e                	mv	a0,s3
    4034:	00001097          	auipc	ra,0x1
    4038:	60e080e7          	jalr	1550(ra) # 5642 <kill>
  kill(pid3);
    403c:	854a                	mv	a0,s2
    403e:	00001097          	auipc	ra,0x1
    4042:	604080e7          	jalr	1540(ra) # 5642 <kill>
  printf("wait... ");
    4046:	00004517          	auipc	a0,0x4
    404a:	9aa50513          	addi	a0,a0,-1622 # 79f0 <statistics+0x1ec4>
    404e:	00002097          	auipc	ra,0x2
    4052:	93c080e7          	jalr	-1732(ra) # 598a <printf>
  wait(0);
    4056:	4501                	li	a0,0
    4058:	00001097          	auipc	ra,0x1
    405c:	5c2080e7          	jalr	1474(ra) # 561a <wait>
  wait(0);
    4060:	4501                	li	a0,0
    4062:	00001097          	auipc	ra,0x1
    4066:	5b8080e7          	jalr	1464(ra) # 561a <wait>
  wait(0);
    406a:	4501                	li	a0,0
    406c:	00001097          	auipc	ra,0x1
    4070:	5ae080e7          	jalr	1454(ra) # 561a <wait>
    4074:	b761                	j	3ffc <preempt+0x12a>

0000000000004076 <sbrkfail>:
{
    4076:	7119                	addi	sp,sp,-128
    4078:	fc86                	sd	ra,120(sp)
    407a:	f8a2                	sd	s0,112(sp)
    407c:	f4a6                	sd	s1,104(sp)
    407e:	f0ca                	sd	s2,96(sp)
    4080:	ecce                	sd	s3,88(sp)
    4082:	e8d2                	sd	s4,80(sp)
    4084:	e4d6                	sd	s5,72(sp)
    4086:	0100                	addi	s0,sp,128
    4088:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    408a:	fb040513          	addi	a0,s0,-80
    408e:	00001097          	auipc	ra,0x1
    4092:	594080e7          	jalr	1428(ra) # 5622 <pipe>
    4096:	e901                	bnez	a0,40a6 <sbrkfail+0x30>
    4098:	f8040493          	addi	s1,s0,-128
    409c:	fa840a13          	addi	s4,s0,-88
    40a0:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    40a2:	5afd                	li	s5,-1
    40a4:	a08d                	j	4106 <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    40a6:	85ca                	mv	a1,s2
    40a8:	00002517          	auipc	a0,0x2
    40ac:	7a850513          	addi	a0,a0,1960 # 6850 <statistics+0xd24>
    40b0:	00002097          	auipc	ra,0x2
    40b4:	8da080e7          	jalr	-1830(ra) # 598a <printf>
    exit(1);
    40b8:	4505                	li	a0,1
    40ba:	00001097          	auipc	ra,0x1
    40be:	558080e7          	jalr	1368(ra) # 5612 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    40c2:	4501                	li	a0,0
    40c4:	00001097          	auipc	ra,0x1
    40c8:	5d6080e7          	jalr	1494(ra) # 569a <sbrk>
    40cc:	064007b7          	lui	a5,0x6400
    40d0:	40a7853b          	subw	a0,a5,a0
    40d4:	00001097          	auipc	ra,0x1
    40d8:	5c6080e7          	jalr	1478(ra) # 569a <sbrk>
      write(fds[1], "x", 1);
    40dc:	4605                	li	a2,1
    40de:	00002597          	auipc	a1,0x2
    40e2:	ea258593          	addi	a1,a1,-350 # 5f80 <statistics+0x454>
    40e6:	fb442503          	lw	a0,-76(s0)
    40ea:	00001097          	auipc	ra,0x1
    40ee:	548080e7          	jalr	1352(ra) # 5632 <write>
      for(;;) sleep(1000);
    40f2:	3e800513          	li	a0,1000
    40f6:	00001097          	auipc	ra,0x1
    40fa:	5ac080e7          	jalr	1452(ra) # 56a2 <sleep>
    40fe:	bfd5                	j	40f2 <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4100:	0991                	addi	s3,s3,4
    4102:	03498563          	beq	s3,s4,412c <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    4106:	00001097          	auipc	ra,0x1
    410a:	504080e7          	jalr	1284(ra) # 560a <fork>
    410e:	00a9a023          	sw	a0,0(s3)
    4112:	d945                	beqz	a0,40c2 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4114:	ff5506e3          	beq	a0,s5,4100 <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    4118:	4605                	li	a2,1
    411a:	faf40593          	addi	a1,s0,-81
    411e:	fb042503          	lw	a0,-80(s0)
    4122:	00001097          	auipc	ra,0x1
    4126:	508080e7          	jalr	1288(ra) # 562a <read>
    412a:	bfd9                	j	4100 <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    412c:	6505                	lui	a0,0x1
    412e:	00001097          	auipc	ra,0x1
    4132:	56c080e7          	jalr	1388(ra) # 569a <sbrk>
    4136:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    4138:	5afd                	li	s5,-1
    413a:	a021                	j	4142 <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    413c:	0491                	addi	s1,s1,4
    413e:	01448f63          	beq	s1,s4,415c <sbrkfail+0xe6>
    if(pids[i] == -1)
    4142:	4088                	lw	a0,0(s1)
    4144:	ff550ce3          	beq	a0,s5,413c <sbrkfail+0xc6>
    kill(pids[i]);
    4148:	00001097          	auipc	ra,0x1
    414c:	4fa080e7          	jalr	1274(ra) # 5642 <kill>
    wait(0);
    4150:	4501                	li	a0,0
    4152:	00001097          	auipc	ra,0x1
    4156:	4c8080e7          	jalr	1224(ra) # 561a <wait>
    415a:	b7cd                	j	413c <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    415c:	57fd                	li	a5,-1
    415e:	04f98163          	beq	s3,a5,41a0 <sbrkfail+0x12a>
  pid = fork();
    4162:	00001097          	auipc	ra,0x1
    4166:	4a8080e7          	jalr	1192(ra) # 560a <fork>
    416a:	84aa                	mv	s1,a0
  if(pid < 0){
    416c:	04054863          	bltz	a0,41bc <sbrkfail+0x146>
  if(pid == 0){
    4170:	c525                	beqz	a0,41d8 <sbrkfail+0x162>
  wait(&xstatus);
    4172:	fbc40513          	addi	a0,s0,-68
    4176:	00001097          	auipc	ra,0x1
    417a:	4a4080e7          	jalr	1188(ra) # 561a <wait>
  if(xstatus != -1 && xstatus != 2)
    417e:	fbc42783          	lw	a5,-68(s0)
    4182:	577d                	li	a4,-1
    4184:	00e78563          	beq	a5,a4,418e <sbrkfail+0x118>
    4188:	4709                	li	a4,2
    418a:	08e79d63          	bne	a5,a4,4224 <sbrkfail+0x1ae>
}
    418e:	70e6                	ld	ra,120(sp)
    4190:	7446                	ld	s0,112(sp)
    4192:	74a6                	ld	s1,104(sp)
    4194:	7906                	ld	s2,96(sp)
    4196:	69e6                	ld	s3,88(sp)
    4198:	6a46                	ld	s4,80(sp)
    419a:	6aa6                	ld	s5,72(sp)
    419c:	6109                	addi	sp,sp,128
    419e:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    41a0:	85ca                	mv	a1,s2
    41a2:	00004517          	auipc	a0,0x4
    41a6:	85e50513          	addi	a0,a0,-1954 # 7a00 <statistics+0x1ed4>
    41aa:	00001097          	auipc	ra,0x1
    41ae:	7e0080e7          	jalr	2016(ra) # 598a <printf>
    exit(1);
    41b2:	4505                	li	a0,1
    41b4:	00001097          	auipc	ra,0x1
    41b8:	45e080e7          	jalr	1118(ra) # 5612 <exit>
    printf("%s: fork failed\n", s);
    41bc:	85ca                	mv	a1,s2
    41be:	00002517          	auipc	a0,0x2
    41c2:	58a50513          	addi	a0,a0,1418 # 6748 <statistics+0xc1c>
    41c6:	00001097          	auipc	ra,0x1
    41ca:	7c4080e7          	jalr	1988(ra) # 598a <printf>
    exit(1);
    41ce:	4505                	li	a0,1
    41d0:	00001097          	auipc	ra,0x1
    41d4:	442080e7          	jalr	1090(ra) # 5612 <exit>
    a = sbrk(0);
    41d8:	4501                	li	a0,0
    41da:	00001097          	auipc	ra,0x1
    41de:	4c0080e7          	jalr	1216(ra) # 569a <sbrk>
    41e2:	89aa                	mv	s3,a0
    sbrk(10*BIG);
    41e4:	3e800537          	lui	a0,0x3e800
    41e8:	00001097          	auipc	ra,0x1
    41ec:	4b2080e7          	jalr	1202(ra) # 569a <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    41f0:	874e                	mv	a4,s3
    41f2:	3e8007b7          	lui	a5,0x3e800
    41f6:	97ce                	add	a5,a5,s3
    41f8:	6685                	lui	a3,0x1
      n += *(a+i);
    41fa:	00074603          	lbu	a2,0(a4)
    41fe:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4200:	9736                	add	a4,a4,a3
    4202:	fef71ce3          	bne	a4,a5,41fa <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4206:	8626                	mv	a2,s1
    4208:	85ca                	mv	a1,s2
    420a:	00004517          	auipc	a0,0x4
    420e:	81650513          	addi	a0,a0,-2026 # 7a20 <statistics+0x1ef4>
    4212:	00001097          	auipc	ra,0x1
    4216:	778080e7          	jalr	1912(ra) # 598a <printf>
    exit(1);
    421a:	4505                	li	a0,1
    421c:	00001097          	auipc	ra,0x1
    4220:	3f6080e7          	jalr	1014(ra) # 5612 <exit>
    exit(1);
    4224:	4505                	li	a0,1
    4226:	00001097          	auipc	ra,0x1
    422a:	3ec080e7          	jalr	1004(ra) # 5612 <exit>

000000000000422e <reparent>:
{
    422e:	7179                	addi	sp,sp,-48
    4230:	f406                	sd	ra,40(sp)
    4232:	f022                	sd	s0,32(sp)
    4234:	ec26                	sd	s1,24(sp)
    4236:	e84a                	sd	s2,16(sp)
    4238:	e44e                	sd	s3,8(sp)
    423a:	e052                	sd	s4,0(sp)
    423c:	1800                	addi	s0,sp,48
    423e:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4240:	00001097          	auipc	ra,0x1
    4244:	452080e7          	jalr	1106(ra) # 5692 <getpid>
    4248:	8a2a                	mv	s4,a0
    424a:	0c800913          	li	s2,200
    int pid = fork();
    424e:	00001097          	auipc	ra,0x1
    4252:	3bc080e7          	jalr	956(ra) # 560a <fork>
    4256:	84aa                	mv	s1,a0
    if(pid < 0){
    4258:	02054263          	bltz	a0,427c <reparent+0x4e>
    if(pid){
    425c:	cd21                	beqz	a0,42b4 <reparent+0x86>
      if(wait(0) != pid){
    425e:	4501                	li	a0,0
    4260:	00001097          	auipc	ra,0x1
    4264:	3ba080e7          	jalr	954(ra) # 561a <wait>
    4268:	02951863          	bne	a0,s1,4298 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    426c:	397d                	addiw	s2,s2,-1
    426e:	fe0910e3          	bnez	s2,424e <reparent+0x20>
  exit(0);
    4272:	4501                	li	a0,0
    4274:	00001097          	auipc	ra,0x1
    4278:	39e080e7          	jalr	926(ra) # 5612 <exit>
      printf("%s: fork failed\n", s);
    427c:	85ce                	mv	a1,s3
    427e:	00002517          	auipc	a0,0x2
    4282:	4ca50513          	addi	a0,a0,1226 # 6748 <statistics+0xc1c>
    4286:	00001097          	auipc	ra,0x1
    428a:	704080e7          	jalr	1796(ra) # 598a <printf>
      exit(1);
    428e:	4505                	li	a0,1
    4290:	00001097          	auipc	ra,0x1
    4294:	382080e7          	jalr	898(ra) # 5612 <exit>
        printf("%s: wait wrong pid\n", s);
    4298:	85ce                	mv	a1,s3
    429a:	00002517          	auipc	a0,0x2
    429e:	63650513          	addi	a0,a0,1590 # 68d0 <statistics+0xda4>
    42a2:	00001097          	auipc	ra,0x1
    42a6:	6e8080e7          	jalr	1768(ra) # 598a <printf>
        exit(1);
    42aa:	4505                	li	a0,1
    42ac:	00001097          	auipc	ra,0x1
    42b0:	366080e7          	jalr	870(ra) # 5612 <exit>
      int pid2 = fork();
    42b4:	00001097          	auipc	ra,0x1
    42b8:	356080e7          	jalr	854(ra) # 560a <fork>
      if(pid2 < 0){
    42bc:	00054763          	bltz	a0,42ca <reparent+0x9c>
      exit(0);
    42c0:	4501                	li	a0,0
    42c2:	00001097          	auipc	ra,0x1
    42c6:	350080e7          	jalr	848(ra) # 5612 <exit>
        kill(master_pid);
    42ca:	8552                	mv	a0,s4
    42cc:	00001097          	auipc	ra,0x1
    42d0:	376080e7          	jalr	886(ra) # 5642 <kill>
        exit(1);
    42d4:	4505                	li	a0,1
    42d6:	00001097          	auipc	ra,0x1
    42da:	33c080e7          	jalr	828(ra) # 5612 <exit>

00000000000042de <mem>:
{
    42de:	7139                	addi	sp,sp,-64
    42e0:	fc06                	sd	ra,56(sp)
    42e2:	f822                	sd	s0,48(sp)
    42e4:	f426                	sd	s1,40(sp)
    42e6:	f04a                	sd	s2,32(sp)
    42e8:	ec4e                	sd	s3,24(sp)
    42ea:	0080                	addi	s0,sp,64
    42ec:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    42ee:	00001097          	auipc	ra,0x1
    42f2:	31c080e7          	jalr	796(ra) # 560a <fork>
    m1 = 0;
    42f6:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    42f8:	6909                	lui	s2,0x2
    42fa:	71190913          	addi	s2,s2,1809 # 2711 <sbrkbasic+0x159>
  if((pid = fork()) == 0){
    42fe:	ed39                	bnez	a0,435c <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    4300:	854a                	mv	a0,s2
    4302:	00001097          	auipc	ra,0x1
    4306:	746080e7          	jalr	1862(ra) # 5a48 <malloc>
    430a:	c501                	beqz	a0,4312 <mem+0x34>
      *(char**)m2 = m1;
    430c:	e104                	sd	s1,0(a0)
      m1 = m2;
    430e:	84aa                	mv	s1,a0
    4310:	bfc5                	j	4300 <mem+0x22>
    while(m1){
    4312:	c881                	beqz	s1,4322 <mem+0x44>
      m2 = *(char**)m1;
    4314:	8526                	mv	a0,s1
    4316:	6084                	ld	s1,0(s1)
      free(m1);
    4318:	00001097          	auipc	ra,0x1
    431c:	6a8080e7          	jalr	1704(ra) # 59c0 <free>
    while(m1){
    4320:	f8f5                	bnez	s1,4314 <mem+0x36>
    m1 = malloc(1024*20);
    4322:	6515                	lui	a0,0x5
    4324:	00001097          	auipc	ra,0x1
    4328:	724080e7          	jalr	1828(ra) # 5a48 <malloc>
    if(m1 == 0){
    432c:	c911                	beqz	a0,4340 <mem+0x62>
    free(m1);
    432e:	00001097          	auipc	ra,0x1
    4332:	692080e7          	jalr	1682(ra) # 59c0 <free>
    exit(0);
    4336:	4501                	li	a0,0
    4338:	00001097          	auipc	ra,0x1
    433c:	2da080e7          	jalr	730(ra) # 5612 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4340:	85ce                	mv	a1,s3
    4342:	00003517          	auipc	a0,0x3
    4346:	70e50513          	addi	a0,a0,1806 # 7a50 <statistics+0x1f24>
    434a:	00001097          	auipc	ra,0x1
    434e:	640080e7          	jalr	1600(ra) # 598a <printf>
      exit(1);
    4352:	4505                	li	a0,1
    4354:	00001097          	auipc	ra,0x1
    4358:	2be080e7          	jalr	702(ra) # 5612 <exit>
    wait(&xstatus);
    435c:	fcc40513          	addi	a0,s0,-52
    4360:	00001097          	auipc	ra,0x1
    4364:	2ba080e7          	jalr	698(ra) # 561a <wait>
    if(xstatus == -1){
    4368:	fcc42503          	lw	a0,-52(s0)
    436c:	57fd                	li	a5,-1
    436e:	00f50663          	beq	a0,a5,437a <mem+0x9c>
    exit(xstatus);
    4372:	00001097          	auipc	ra,0x1
    4376:	2a0080e7          	jalr	672(ra) # 5612 <exit>
      exit(0);
    437a:	4501                	li	a0,0
    437c:	00001097          	auipc	ra,0x1
    4380:	296080e7          	jalr	662(ra) # 5612 <exit>

0000000000004384 <sharedfd>:
{
    4384:	7159                	addi	sp,sp,-112
    4386:	f486                	sd	ra,104(sp)
    4388:	f0a2                	sd	s0,96(sp)
    438a:	eca6                	sd	s1,88(sp)
    438c:	e8ca                	sd	s2,80(sp)
    438e:	e4ce                	sd	s3,72(sp)
    4390:	e0d2                	sd	s4,64(sp)
    4392:	fc56                	sd	s5,56(sp)
    4394:	f85a                	sd	s6,48(sp)
    4396:	f45e                	sd	s7,40(sp)
    4398:	1880                	addi	s0,sp,112
    439a:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    439c:	00002517          	auipc	a0,0x2
    43a0:	9b450513          	addi	a0,a0,-1612 # 5d50 <statistics+0x224>
    43a4:	00001097          	auipc	ra,0x1
    43a8:	2be080e7          	jalr	702(ra) # 5662 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    43ac:	20200593          	li	a1,514
    43b0:	00002517          	auipc	a0,0x2
    43b4:	9a050513          	addi	a0,a0,-1632 # 5d50 <statistics+0x224>
    43b8:	00001097          	auipc	ra,0x1
    43bc:	29a080e7          	jalr	666(ra) # 5652 <open>
  if(fd < 0){
    43c0:	04054a63          	bltz	a0,4414 <sharedfd+0x90>
    43c4:	892a                	mv	s2,a0
  pid = fork();
    43c6:	00001097          	auipc	ra,0x1
    43ca:	244080e7          	jalr	580(ra) # 560a <fork>
    43ce:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    43d0:	06300593          	li	a1,99
    43d4:	c119                	beqz	a0,43da <sharedfd+0x56>
    43d6:	07000593          	li	a1,112
    43da:	4629                	li	a2,10
    43dc:	fa040513          	addi	a0,s0,-96
    43e0:	00001097          	auipc	ra,0x1
    43e4:	02e080e7          	jalr	46(ra) # 540e <memset>
    43e8:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    43ec:	4629                	li	a2,10
    43ee:	fa040593          	addi	a1,s0,-96
    43f2:	854a                	mv	a0,s2
    43f4:	00001097          	auipc	ra,0x1
    43f8:	23e080e7          	jalr	574(ra) # 5632 <write>
    43fc:	47a9                	li	a5,10
    43fe:	02f51963          	bne	a0,a5,4430 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4402:	34fd                	addiw	s1,s1,-1
    4404:	f4e5                	bnez	s1,43ec <sharedfd+0x68>
  if(pid == 0) {
    4406:	04099363          	bnez	s3,444c <sharedfd+0xc8>
    exit(0);
    440a:	4501                	li	a0,0
    440c:	00001097          	auipc	ra,0x1
    4410:	206080e7          	jalr	518(ra) # 5612 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4414:	85d2                	mv	a1,s4
    4416:	00003517          	auipc	a0,0x3
    441a:	65a50513          	addi	a0,a0,1626 # 7a70 <statistics+0x1f44>
    441e:	00001097          	auipc	ra,0x1
    4422:	56c080e7          	jalr	1388(ra) # 598a <printf>
    exit(1);
    4426:	4505                	li	a0,1
    4428:	00001097          	auipc	ra,0x1
    442c:	1ea080e7          	jalr	490(ra) # 5612 <exit>
      printf("%s: write sharedfd failed\n", s);
    4430:	85d2                	mv	a1,s4
    4432:	00003517          	auipc	a0,0x3
    4436:	66650513          	addi	a0,a0,1638 # 7a98 <statistics+0x1f6c>
    443a:	00001097          	auipc	ra,0x1
    443e:	550080e7          	jalr	1360(ra) # 598a <printf>
      exit(1);
    4442:	4505                	li	a0,1
    4444:	00001097          	auipc	ra,0x1
    4448:	1ce080e7          	jalr	462(ra) # 5612 <exit>
    wait(&xstatus);
    444c:	f9c40513          	addi	a0,s0,-100
    4450:	00001097          	auipc	ra,0x1
    4454:	1ca080e7          	jalr	458(ra) # 561a <wait>
    if(xstatus != 0)
    4458:	f9c42983          	lw	s3,-100(s0)
    445c:	00098763          	beqz	s3,446a <sharedfd+0xe6>
      exit(xstatus);
    4460:	854e                	mv	a0,s3
    4462:	00001097          	auipc	ra,0x1
    4466:	1b0080e7          	jalr	432(ra) # 5612 <exit>
  close(fd);
    446a:	854a                	mv	a0,s2
    446c:	00001097          	auipc	ra,0x1
    4470:	1ce080e7          	jalr	462(ra) # 563a <close>
  fd = open("sharedfd", 0);
    4474:	4581                	li	a1,0
    4476:	00002517          	auipc	a0,0x2
    447a:	8da50513          	addi	a0,a0,-1830 # 5d50 <statistics+0x224>
    447e:	00001097          	auipc	ra,0x1
    4482:	1d4080e7          	jalr	468(ra) # 5652 <open>
    4486:	8baa                	mv	s7,a0
  nc = np = 0;
    4488:	8ace                	mv	s5,s3
  if(fd < 0){
    448a:	02054563          	bltz	a0,44b4 <sharedfd+0x130>
    448e:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4492:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4496:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    449a:	4629                	li	a2,10
    449c:	fa040593          	addi	a1,s0,-96
    44a0:	855e                	mv	a0,s7
    44a2:	00001097          	auipc	ra,0x1
    44a6:	188080e7          	jalr	392(ra) # 562a <read>
    44aa:	02a05f63          	blez	a0,44e8 <sharedfd+0x164>
    44ae:	fa040793          	addi	a5,s0,-96
    44b2:	a01d                	j	44d8 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    44b4:	85d2                	mv	a1,s4
    44b6:	00003517          	auipc	a0,0x3
    44ba:	60250513          	addi	a0,a0,1538 # 7ab8 <statistics+0x1f8c>
    44be:	00001097          	auipc	ra,0x1
    44c2:	4cc080e7          	jalr	1228(ra) # 598a <printf>
    exit(1);
    44c6:	4505                	li	a0,1
    44c8:	00001097          	auipc	ra,0x1
    44cc:	14a080e7          	jalr	330(ra) # 5612 <exit>
        nc++;
    44d0:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    44d2:	0785                	addi	a5,a5,1
    44d4:	fd2783e3          	beq	a5,s2,449a <sharedfd+0x116>
      if(buf[i] == 'c')
    44d8:	0007c703          	lbu	a4,0(a5) # 3e800000 <__BSS_END__+0x3e7f14a0>
    44dc:	fe970ae3          	beq	a4,s1,44d0 <sharedfd+0x14c>
      if(buf[i] == 'p')
    44e0:	ff6719e3          	bne	a4,s6,44d2 <sharedfd+0x14e>
        np++;
    44e4:	2a85                	addiw	s5,s5,1
    44e6:	b7f5                	j	44d2 <sharedfd+0x14e>
  close(fd);
    44e8:	855e                	mv	a0,s7
    44ea:	00001097          	auipc	ra,0x1
    44ee:	150080e7          	jalr	336(ra) # 563a <close>
  unlink("sharedfd");
    44f2:	00002517          	auipc	a0,0x2
    44f6:	85e50513          	addi	a0,a0,-1954 # 5d50 <statistics+0x224>
    44fa:	00001097          	auipc	ra,0x1
    44fe:	168080e7          	jalr	360(ra) # 5662 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4502:	6789                	lui	a5,0x2
    4504:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x158>
    4508:	00f99763          	bne	s3,a5,4516 <sharedfd+0x192>
    450c:	6789                	lui	a5,0x2
    450e:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x158>
    4512:	02fa8063          	beq	s5,a5,4532 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4516:	85d2                	mv	a1,s4
    4518:	00003517          	auipc	a0,0x3
    451c:	5c850513          	addi	a0,a0,1480 # 7ae0 <statistics+0x1fb4>
    4520:	00001097          	auipc	ra,0x1
    4524:	46a080e7          	jalr	1130(ra) # 598a <printf>
    exit(1);
    4528:	4505                	li	a0,1
    452a:	00001097          	auipc	ra,0x1
    452e:	0e8080e7          	jalr	232(ra) # 5612 <exit>
    exit(0);
    4532:	4501                	li	a0,0
    4534:	00001097          	auipc	ra,0x1
    4538:	0de080e7          	jalr	222(ra) # 5612 <exit>

000000000000453c <fourfiles>:
{
    453c:	7171                	addi	sp,sp,-176
    453e:	f506                	sd	ra,168(sp)
    4540:	f122                	sd	s0,160(sp)
    4542:	ed26                	sd	s1,152(sp)
    4544:	e94a                	sd	s2,144(sp)
    4546:	e54e                	sd	s3,136(sp)
    4548:	e152                	sd	s4,128(sp)
    454a:	fcd6                	sd	s5,120(sp)
    454c:	f8da                	sd	s6,112(sp)
    454e:	f4de                	sd	s7,104(sp)
    4550:	f0e2                	sd	s8,96(sp)
    4552:	ece6                	sd	s9,88(sp)
    4554:	e8ea                	sd	s10,80(sp)
    4556:	e4ee                	sd	s11,72(sp)
    4558:	1900                	addi	s0,sp,176
    455a:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    455c:	00001797          	auipc	a5,0x1
    4560:	65c78793          	addi	a5,a5,1628 # 5bb8 <statistics+0x8c>
    4564:	f6f43823          	sd	a5,-144(s0)
    4568:	00001797          	auipc	a5,0x1
    456c:	65878793          	addi	a5,a5,1624 # 5bc0 <statistics+0x94>
    4570:	f6f43c23          	sd	a5,-136(s0)
    4574:	00001797          	auipc	a5,0x1
    4578:	65478793          	addi	a5,a5,1620 # 5bc8 <statistics+0x9c>
    457c:	f8f43023          	sd	a5,-128(s0)
    4580:	00001797          	auipc	a5,0x1
    4584:	65078793          	addi	a5,a5,1616 # 5bd0 <statistics+0xa4>
    4588:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    458c:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4590:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4592:	4481                	li	s1,0
    4594:	4a11                	li	s4,4
    fname = names[pi];
    4596:	00093983          	ld	s3,0(s2)
    unlink(fname);
    459a:	854e                	mv	a0,s3
    459c:	00001097          	auipc	ra,0x1
    45a0:	0c6080e7          	jalr	198(ra) # 5662 <unlink>
    pid = fork();
    45a4:	00001097          	auipc	ra,0x1
    45a8:	066080e7          	jalr	102(ra) # 560a <fork>
    if(pid < 0){
    45ac:	04054563          	bltz	a0,45f6 <fourfiles+0xba>
    if(pid == 0){
    45b0:	c12d                	beqz	a0,4612 <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    45b2:	2485                	addiw	s1,s1,1
    45b4:	0921                	addi	s2,s2,8
    45b6:	ff4490e3          	bne	s1,s4,4596 <fourfiles+0x5a>
    45ba:	4491                	li	s1,4
    wait(&xstatus);
    45bc:	f6c40513          	addi	a0,s0,-148
    45c0:	00001097          	auipc	ra,0x1
    45c4:	05a080e7          	jalr	90(ra) # 561a <wait>
    if(xstatus != 0)
    45c8:	f6c42503          	lw	a0,-148(s0)
    45cc:	ed69                	bnez	a0,46a6 <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    45ce:	34fd                	addiw	s1,s1,-1
    45d0:	f4f5                	bnez	s1,45bc <fourfiles+0x80>
    45d2:	03000b13          	li	s6,48
    total = 0;
    45d6:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    45da:	00007a17          	auipc	s4,0x7
    45de:	576a0a13          	addi	s4,s4,1398 # bb50 <buf>
    45e2:	00007a97          	auipc	s5,0x7
    45e6:	56fa8a93          	addi	s5,s5,1391 # bb51 <buf+0x1>
    if(total != N*SZ){
    45ea:	6d05                	lui	s10,0x1
    45ec:	770d0d13          	addi	s10,s10,1904 # 1770 <pipe1+0x32>
  for(i = 0; i < NCHILD; i++){
    45f0:	03400d93          	li	s11,52
    45f4:	a23d                	j	4722 <fourfiles+0x1e6>
      printf("fork failed\n", s);
    45f6:	85e6                	mv	a1,s9
    45f8:	00002517          	auipc	a0,0x2
    45fc:	55850513          	addi	a0,a0,1368 # 6b50 <statistics+0x1024>
    4600:	00001097          	auipc	ra,0x1
    4604:	38a080e7          	jalr	906(ra) # 598a <printf>
      exit(1);
    4608:	4505                	li	a0,1
    460a:	00001097          	auipc	ra,0x1
    460e:	008080e7          	jalr	8(ra) # 5612 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4612:	20200593          	li	a1,514
    4616:	854e                	mv	a0,s3
    4618:	00001097          	auipc	ra,0x1
    461c:	03a080e7          	jalr	58(ra) # 5652 <open>
    4620:	892a                	mv	s2,a0
      if(fd < 0){
    4622:	04054763          	bltz	a0,4670 <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    4626:	1f400613          	li	a2,500
    462a:	0304859b          	addiw	a1,s1,48
    462e:	00007517          	auipc	a0,0x7
    4632:	52250513          	addi	a0,a0,1314 # bb50 <buf>
    4636:	00001097          	auipc	ra,0x1
    463a:	dd8080e7          	jalr	-552(ra) # 540e <memset>
    463e:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4640:	00007997          	auipc	s3,0x7
    4644:	51098993          	addi	s3,s3,1296 # bb50 <buf>
    4648:	1f400613          	li	a2,500
    464c:	85ce                	mv	a1,s3
    464e:	854a                	mv	a0,s2
    4650:	00001097          	auipc	ra,0x1
    4654:	fe2080e7          	jalr	-30(ra) # 5632 <write>
    4658:	85aa                	mv	a1,a0
    465a:	1f400793          	li	a5,500
    465e:	02f51763          	bne	a0,a5,468c <fourfiles+0x150>
      for(i = 0; i < N; i++){
    4662:	34fd                	addiw	s1,s1,-1
    4664:	f0f5                	bnez	s1,4648 <fourfiles+0x10c>
      exit(0);
    4666:	4501                	li	a0,0
    4668:	00001097          	auipc	ra,0x1
    466c:	faa080e7          	jalr	-86(ra) # 5612 <exit>
        printf("create failed\n", s);
    4670:	85e6                	mv	a1,s9
    4672:	00003517          	auipc	a0,0x3
    4676:	48650513          	addi	a0,a0,1158 # 7af8 <statistics+0x1fcc>
    467a:	00001097          	auipc	ra,0x1
    467e:	310080e7          	jalr	784(ra) # 598a <printf>
        exit(1);
    4682:	4505                	li	a0,1
    4684:	00001097          	auipc	ra,0x1
    4688:	f8e080e7          	jalr	-114(ra) # 5612 <exit>
          printf("write failed %d\n", n);
    468c:	00003517          	auipc	a0,0x3
    4690:	47c50513          	addi	a0,a0,1148 # 7b08 <statistics+0x1fdc>
    4694:	00001097          	auipc	ra,0x1
    4698:	2f6080e7          	jalr	758(ra) # 598a <printf>
          exit(1);
    469c:	4505                	li	a0,1
    469e:	00001097          	auipc	ra,0x1
    46a2:	f74080e7          	jalr	-140(ra) # 5612 <exit>
      exit(xstatus);
    46a6:	00001097          	auipc	ra,0x1
    46aa:	f6c080e7          	jalr	-148(ra) # 5612 <exit>
          printf("wrong char\n", s);
    46ae:	85e6                	mv	a1,s9
    46b0:	00003517          	auipc	a0,0x3
    46b4:	47050513          	addi	a0,a0,1136 # 7b20 <statistics+0x1ff4>
    46b8:	00001097          	auipc	ra,0x1
    46bc:	2d2080e7          	jalr	722(ra) # 598a <printf>
          exit(1);
    46c0:	4505                	li	a0,1
    46c2:	00001097          	auipc	ra,0x1
    46c6:	f50080e7          	jalr	-176(ra) # 5612 <exit>
      total += n;
    46ca:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    46ce:	660d                	lui	a2,0x3
    46d0:	85d2                	mv	a1,s4
    46d2:	854e                	mv	a0,s3
    46d4:	00001097          	auipc	ra,0x1
    46d8:	f56080e7          	jalr	-170(ra) # 562a <read>
    46dc:	02a05363          	blez	a0,4702 <fourfiles+0x1c6>
    46e0:	00007797          	auipc	a5,0x7
    46e4:	47078793          	addi	a5,a5,1136 # bb50 <buf>
    46e8:	fff5069b          	addiw	a3,a0,-1
    46ec:	1682                	slli	a3,a3,0x20
    46ee:	9281                	srli	a3,a3,0x20
    46f0:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    46f2:	0007c703          	lbu	a4,0(a5)
    46f6:	fa971ce3          	bne	a4,s1,46ae <fourfiles+0x172>
      for(j = 0; j < n; j++){
    46fa:	0785                	addi	a5,a5,1
    46fc:	fed79be3          	bne	a5,a3,46f2 <fourfiles+0x1b6>
    4700:	b7e9                	j	46ca <fourfiles+0x18e>
    close(fd);
    4702:	854e                	mv	a0,s3
    4704:	00001097          	auipc	ra,0x1
    4708:	f36080e7          	jalr	-202(ra) # 563a <close>
    if(total != N*SZ){
    470c:	03a91963          	bne	s2,s10,473e <fourfiles+0x202>
    unlink(fname);
    4710:	8562                	mv	a0,s8
    4712:	00001097          	auipc	ra,0x1
    4716:	f50080e7          	jalr	-176(ra) # 5662 <unlink>
  for(i = 0; i < NCHILD; i++){
    471a:	0ba1                	addi	s7,s7,8
    471c:	2b05                	addiw	s6,s6,1
    471e:	03bb0e63          	beq	s6,s11,475a <fourfiles+0x21e>
    fname = names[i];
    4722:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    4726:	4581                	li	a1,0
    4728:	8562                	mv	a0,s8
    472a:	00001097          	auipc	ra,0x1
    472e:	f28080e7          	jalr	-216(ra) # 5652 <open>
    4732:	89aa                	mv	s3,a0
    total = 0;
    4734:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    4738:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    473c:	bf49                	j	46ce <fourfiles+0x192>
      printf("wrong length %d\n", total);
    473e:	85ca                	mv	a1,s2
    4740:	00003517          	auipc	a0,0x3
    4744:	3f050513          	addi	a0,a0,1008 # 7b30 <statistics+0x2004>
    4748:	00001097          	auipc	ra,0x1
    474c:	242080e7          	jalr	578(ra) # 598a <printf>
      exit(1);
    4750:	4505                	li	a0,1
    4752:	00001097          	auipc	ra,0x1
    4756:	ec0080e7          	jalr	-320(ra) # 5612 <exit>
}
    475a:	70aa                	ld	ra,168(sp)
    475c:	740a                	ld	s0,160(sp)
    475e:	64ea                	ld	s1,152(sp)
    4760:	694a                	ld	s2,144(sp)
    4762:	69aa                	ld	s3,136(sp)
    4764:	6a0a                	ld	s4,128(sp)
    4766:	7ae6                	ld	s5,120(sp)
    4768:	7b46                	ld	s6,112(sp)
    476a:	7ba6                	ld	s7,104(sp)
    476c:	7c06                	ld	s8,96(sp)
    476e:	6ce6                	ld	s9,88(sp)
    4770:	6d46                	ld	s10,80(sp)
    4772:	6da6                	ld	s11,72(sp)
    4774:	614d                	addi	sp,sp,176
    4776:	8082                	ret

0000000000004778 <concreate>:
{
    4778:	7135                	addi	sp,sp,-160
    477a:	ed06                	sd	ra,152(sp)
    477c:	e922                	sd	s0,144(sp)
    477e:	e526                	sd	s1,136(sp)
    4780:	e14a                	sd	s2,128(sp)
    4782:	fcce                	sd	s3,120(sp)
    4784:	f8d2                	sd	s4,112(sp)
    4786:	f4d6                	sd	s5,104(sp)
    4788:	f0da                	sd	s6,96(sp)
    478a:	ecde                	sd	s7,88(sp)
    478c:	1100                	addi	s0,sp,160
    478e:	89aa                	mv	s3,a0
  file[0] = 'C';
    4790:	04300793          	li	a5,67
    4794:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4798:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    479c:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    479e:	4b0d                	li	s6,3
    47a0:	4a85                	li	s5,1
      link("C0", file);
    47a2:	00003b97          	auipc	s7,0x3
    47a6:	3a6b8b93          	addi	s7,s7,934 # 7b48 <statistics+0x201c>
  for(i = 0; i < N; i++){
    47aa:	02800a13          	li	s4,40
    47ae:	acc1                	j	4a7e <concreate+0x306>
      link("C0", file);
    47b0:	fa840593          	addi	a1,s0,-88
    47b4:	855e                	mv	a0,s7
    47b6:	00001097          	auipc	ra,0x1
    47ba:	ebc080e7          	jalr	-324(ra) # 5672 <link>
    if(pid == 0) {
    47be:	a45d                	j	4a64 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    47c0:	4795                	li	a5,5
    47c2:	02f9693b          	remw	s2,s2,a5
    47c6:	4785                	li	a5,1
    47c8:	02f90b63          	beq	s2,a5,47fe <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    47cc:	20200593          	li	a1,514
    47d0:	fa840513          	addi	a0,s0,-88
    47d4:	00001097          	auipc	ra,0x1
    47d8:	e7e080e7          	jalr	-386(ra) # 5652 <open>
      if(fd < 0){
    47dc:	26055b63          	bgez	a0,4a52 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    47e0:	fa840593          	addi	a1,s0,-88
    47e4:	00003517          	auipc	a0,0x3
    47e8:	36c50513          	addi	a0,a0,876 # 7b50 <statistics+0x2024>
    47ec:	00001097          	auipc	ra,0x1
    47f0:	19e080e7          	jalr	414(ra) # 598a <printf>
        exit(1);
    47f4:	4505                	li	a0,1
    47f6:	00001097          	auipc	ra,0x1
    47fa:	e1c080e7          	jalr	-484(ra) # 5612 <exit>
      link("C0", file);
    47fe:	fa840593          	addi	a1,s0,-88
    4802:	00003517          	auipc	a0,0x3
    4806:	34650513          	addi	a0,a0,838 # 7b48 <statistics+0x201c>
    480a:	00001097          	auipc	ra,0x1
    480e:	e68080e7          	jalr	-408(ra) # 5672 <link>
      exit(0);
    4812:	4501                	li	a0,0
    4814:	00001097          	auipc	ra,0x1
    4818:	dfe080e7          	jalr	-514(ra) # 5612 <exit>
        exit(1);
    481c:	4505                	li	a0,1
    481e:	00001097          	auipc	ra,0x1
    4822:	df4080e7          	jalr	-524(ra) # 5612 <exit>
  memset(fa, 0, sizeof(fa));
    4826:	02800613          	li	a2,40
    482a:	4581                	li	a1,0
    482c:	f8040513          	addi	a0,s0,-128
    4830:	00001097          	auipc	ra,0x1
    4834:	bde080e7          	jalr	-1058(ra) # 540e <memset>
  fd = open(".", 0);
    4838:	4581                	li	a1,0
    483a:	00002517          	auipc	a0,0x2
    483e:	d6e50513          	addi	a0,a0,-658 # 65a8 <statistics+0xa7c>
    4842:	00001097          	auipc	ra,0x1
    4846:	e10080e7          	jalr	-496(ra) # 5652 <open>
    484a:	892a                	mv	s2,a0
  n = 0;
    484c:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    484e:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4852:	02700b13          	li	s6,39
      fa[i] = 1;
    4856:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4858:	a03d                	j	4886 <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    485a:	f7240613          	addi	a2,s0,-142
    485e:	85ce                	mv	a1,s3
    4860:	00003517          	auipc	a0,0x3
    4864:	31050513          	addi	a0,a0,784 # 7b70 <statistics+0x2044>
    4868:	00001097          	auipc	ra,0x1
    486c:	122080e7          	jalr	290(ra) # 598a <printf>
        exit(1);
    4870:	4505                	li	a0,1
    4872:	00001097          	auipc	ra,0x1
    4876:	da0080e7          	jalr	-608(ra) # 5612 <exit>
      fa[i] = 1;
    487a:	fb040793          	addi	a5,s0,-80
    487e:	973e                	add	a4,a4,a5
    4880:	fd770823          	sb	s7,-48(a4)
      n++;
    4884:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    4886:	4641                	li	a2,16
    4888:	f7040593          	addi	a1,s0,-144
    488c:	854a                	mv	a0,s2
    488e:	00001097          	auipc	ra,0x1
    4892:	d9c080e7          	jalr	-612(ra) # 562a <read>
    4896:	04a05a63          	blez	a0,48ea <concreate+0x172>
    if(de.inum == 0)
    489a:	f7045783          	lhu	a5,-144(s0)
    489e:	d7e5                	beqz	a5,4886 <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    48a0:	f7244783          	lbu	a5,-142(s0)
    48a4:	ff4791e3          	bne	a5,s4,4886 <concreate+0x10e>
    48a8:	f7444783          	lbu	a5,-140(s0)
    48ac:	ffe9                	bnez	a5,4886 <concreate+0x10e>
      i = de.name[1] - '0';
    48ae:	f7344783          	lbu	a5,-141(s0)
    48b2:	fd07879b          	addiw	a5,a5,-48
    48b6:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    48ba:	faeb60e3          	bltu	s6,a4,485a <concreate+0xe2>
      if(fa[i]){
    48be:	fb040793          	addi	a5,s0,-80
    48c2:	97ba                	add	a5,a5,a4
    48c4:	fd07c783          	lbu	a5,-48(a5)
    48c8:	dbcd                	beqz	a5,487a <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    48ca:	f7240613          	addi	a2,s0,-142
    48ce:	85ce                	mv	a1,s3
    48d0:	00003517          	auipc	a0,0x3
    48d4:	2c050513          	addi	a0,a0,704 # 7b90 <statistics+0x2064>
    48d8:	00001097          	auipc	ra,0x1
    48dc:	0b2080e7          	jalr	178(ra) # 598a <printf>
        exit(1);
    48e0:	4505                	li	a0,1
    48e2:	00001097          	auipc	ra,0x1
    48e6:	d30080e7          	jalr	-720(ra) # 5612 <exit>
  close(fd);
    48ea:	854a                	mv	a0,s2
    48ec:	00001097          	auipc	ra,0x1
    48f0:	d4e080e7          	jalr	-690(ra) # 563a <close>
  if(n != N){
    48f4:	02800793          	li	a5,40
    48f8:	00fa9763          	bne	s5,a5,4906 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    48fc:	4a8d                	li	s5,3
    48fe:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4900:	02800a13          	li	s4,40
    4904:	a8c9                	j	49d6 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4906:	85ce                	mv	a1,s3
    4908:	00003517          	auipc	a0,0x3
    490c:	2b050513          	addi	a0,a0,688 # 7bb8 <statistics+0x208c>
    4910:	00001097          	auipc	ra,0x1
    4914:	07a080e7          	jalr	122(ra) # 598a <printf>
    exit(1);
    4918:	4505                	li	a0,1
    491a:	00001097          	auipc	ra,0x1
    491e:	cf8080e7          	jalr	-776(ra) # 5612 <exit>
      printf("%s: fork failed\n", s);
    4922:	85ce                	mv	a1,s3
    4924:	00002517          	auipc	a0,0x2
    4928:	e2450513          	addi	a0,a0,-476 # 6748 <statistics+0xc1c>
    492c:	00001097          	auipc	ra,0x1
    4930:	05e080e7          	jalr	94(ra) # 598a <printf>
      exit(1);
    4934:	4505                	li	a0,1
    4936:	00001097          	auipc	ra,0x1
    493a:	cdc080e7          	jalr	-804(ra) # 5612 <exit>
      close(open(file, 0));
    493e:	4581                	li	a1,0
    4940:	fa840513          	addi	a0,s0,-88
    4944:	00001097          	auipc	ra,0x1
    4948:	d0e080e7          	jalr	-754(ra) # 5652 <open>
    494c:	00001097          	auipc	ra,0x1
    4950:	cee080e7          	jalr	-786(ra) # 563a <close>
      close(open(file, 0));
    4954:	4581                	li	a1,0
    4956:	fa840513          	addi	a0,s0,-88
    495a:	00001097          	auipc	ra,0x1
    495e:	cf8080e7          	jalr	-776(ra) # 5652 <open>
    4962:	00001097          	auipc	ra,0x1
    4966:	cd8080e7          	jalr	-808(ra) # 563a <close>
      close(open(file, 0));
    496a:	4581                	li	a1,0
    496c:	fa840513          	addi	a0,s0,-88
    4970:	00001097          	auipc	ra,0x1
    4974:	ce2080e7          	jalr	-798(ra) # 5652 <open>
    4978:	00001097          	auipc	ra,0x1
    497c:	cc2080e7          	jalr	-830(ra) # 563a <close>
      close(open(file, 0));
    4980:	4581                	li	a1,0
    4982:	fa840513          	addi	a0,s0,-88
    4986:	00001097          	auipc	ra,0x1
    498a:	ccc080e7          	jalr	-820(ra) # 5652 <open>
    498e:	00001097          	auipc	ra,0x1
    4992:	cac080e7          	jalr	-852(ra) # 563a <close>
      close(open(file, 0));
    4996:	4581                	li	a1,0
    4998:	fa840513          	addi	a0,s0,-88
    499c:	00001097          	auipc	ra,0x1
    49a0:	cb6080e7          	jalr	-842(ra) # 5652 <open>
    49a4:	00001097          	auipc	ra,0x1
    49a8:	c96080e7          	jalr	-874(ra) # 563a <close>
      close(open(file, 0));
    49ac:	4581                	li	a1,0
    49ae:	fa840513          	addi	a0,s0,-88
    49b2:	00001097          	auipc	ra,0x1
    49b6:	ca0080e7          	jalr	-864(ra) # 5652 <open>
    49ba:	00001097          	auipc	ra,0x1
    49be:	c80080e7          	jalr	-896(ra) # 563a <close>
    if(pid == 0)
    49c2:	08090363          	beqz	s2,4a48 <concreate+0x2d0>
      wait(0);
    49c6:	4501                	li	a0,0
    49c8:	00001097          	auipc	ra,0x1
    49cc:	c52080e7          	jalr	-942(ra) # 561a <wait>
  for(i = 0; i < N; i++){
    49d0:	2485                	addiw	s1,s1,1
    49d2:	0f448563          	beq	s1,s4,4abc <concreate+0x344>
    file[1] = '0' + i;
    49d6:	0304879b          	addiw	a5,s1,48
    49da:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    49de:	00001097          	auipc	ra,0x1
    49e2:	c2c080e7          	jalr	-980(ra) # 560a <fork>
    49e6:	892a                	mv	s2,a0
    if(pid < 0){
    49e8:	f2054de3          	bltz	a0,4922 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    49ec:	0354e73b          	remw	a4,s1,s5
    49f0:	00a767b3          	or	a5,a4,a0
    49f4:	2781                	sext.w	a5,a5
    49f6:	d7a1                	beqz	a5,493e <concreate+0x1c6>
    49f8:	01671363          	bne	a4,s6,49fe <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    49fc:	f129                	bnez	a0,493e <concreate+0x1c6>
      unlink(file);
    49fe:	fa840513          	addi	a0,s0,-88
    4a02:	00001097          	auipc	ra,0x1
    4a06:	c60080e7          	jalr	-928(ra) # 5662 <unlink>
      unlink(file);
    4a0a:	fa840513          	addi	a0,s0,-88
    4a0e:	00001097          	auipc	ra,0x1
    4a12:	c54080e7          	jalr	-940(ra) # 5662 <unlink>
      unlink(file);
    4a16:	fa840513          	addi	a0,s0,-88
    4a1a:	00001097          	auipc	ra,0x1
    4a1e:	c48080e7          	jalr	-952(ra) # 5662 <unlink>
      unlink(file);
    4a22:	fa840513          	addi	a0,s0,-88
    4a26:	00001097          	auipc	ra,0x1
    4a2a:	c3c080e7          	jalr	-964(ra) # 5662 <unlink>
      unlink(file);
    4a2e:	fa840513          	addi	a0,s0,-88
    4a32:	00001097          	auipc	ra,0x1
    4a36:	c30080e7          	jalr	-976(ra) # 5662 <unlink>
      unlink(file);
    4a3a:	fa840513          	addi	a0,s0,-88
    4a3e:	00001097          	auipc	ra,0x1
    4a42:	c24080e7          	jalr	-988(ra) # 5662 <unlink>
    4a46:	bfb5                	j	49c2 <concreate+0x24a>
      exit(0);
    4a48:	4501                	li	a0,0
    4a4a:	00001097          	auipc	ra,0x1
    4a4e:	bc8080e7          	jalr	-1080(ra) # 5612 <exit>
      close(fd);
    4a52:	00001097          	auipc	ra,0x1
    4a56:	be8080e7          	jalr	-1048(ra) # 563a <close>
    if(pid == 0) {
    4a5a:	bb65                	j	4812 <concreate+0x9a>
      close(fd);
    4a5c:	00001097          	auipc	ra,0x1
    4a60:	bde080e7          	jalr	-1058(ra) # 563a <close>
      wait(&xstatus);
    4a64:	f6c40513          	addi	a0,s0,-148
    4a68:	00001097          	auipc	ra,0x1
    4a6c:	bb2080e7          	jalr	-1102(ra) # 561a <wait>
      if(xstatus != 0)
    4a70:	f6c42483          	lw	s1,-148(s0)
    4a74:	da0494e3          	bnez	s1,481c <concreate+0xa4>
  for(i = 0; i < N; i++){
    4a78:	2905                	addiw	s2,s2,1
    4a7a:	db4906e3          	beq	s2,s4,4826 <concreate+0xae>
    file[1] = '0' + i;
    4a7e:	0309079b          	addiw	a5,s2,48
    4a82:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4a86:	fa840513          	addi	a0,s0,-88
    4a8a:	00001097          	auipc	ra,0x1
    4a8e:	bd8080e7          	jalr	-1064(ra) # 5662 <unlink>
    pid = fork();
    4a92:	00001097          	auipc	ra,0x1
    4a96:	b78080e7          	jalr	-1160(ra) # 560a <fork>
    if(pid && (i % 3) == 1){
    4a9a:	d20503e3          	beqz	a0,47c0 <concreate+0x48>
    4a9e:	036967bb          	remw	a5,s2,s6
    4aa2:	d15787e3          	beq	a5,s5,47b0 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4aa6:	20200593          	li	a1,514
    4aaa:	fa840513          	addi	a0,s0,-88
    4aae:	00001097          	auipc	ra,0x1
    4ab2:	ba4080e7          	jalr	-1116(ra) # 5652 <open>
      if(fd < 0){
    4ab6:	fa0553e3          	bgez	a0,4a5c <concreate+0x2e4>
    4aba:	b31d                	j	47e0 <concreate+0x68>
}
    4abc:	60ea                	ld	ra,152(sp)
    4abe:	644a                	ld	s0,144(sp)
    4ac0:	64aa                	ld	s1,136(sp)
    4ac2:	690a                	ld	s2,128(sp)
    4ac4:	79e6                	ld	s3,120(sp)
    4ac6:	7a46                	ld	s4,112(sp)
    4ac8:	7aa6                	ld	s5,104(sp)
    4aca:	7b06                	ld	s6,96(sp)
    4acc:	6be6                	ld	s7,88(sp)
    4ace:	610d                	addi	sp,sp,160
    4ad0:	8082                	ret

0000000000004ad2 <bigfile>:
{
    4ad2:	7139                	addi	sp,sp,-64
    4ad4:	fc06                	sd	ra,56(sp)
    4ad6:	f822                	sd	s0,48(sp)
    4ad8:	f426                	sd	s1,40(sp)
    4ada:	f04a                	sd	s2,32(sp)
    4adc:	ec4e                	sd	s3,24(sp)
    4ade:	e852                	sd	s4,16(sp)
    4ae0:	e456                	sd	s5,8(sp)
    4ae2:	0080                	addi	s0,sp,64
    4ae4:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4ae6:	00003517          	auipc	a0,0x3
    4aea:	10a50513          	addi	a0,a0,266 # 7bf0 <statistics+0x20c4>
    4aee:	00001097          	auipc	ra,0x1
    4af2:	b74080e7          	jalr	-1164(ra) # 5662 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4af6:	20200593          	li	a1,514
    4afa:	00003517          	auipc	a0,0x3
    4afe:	0f650513          	addi	a0,a0,246 # 7bf0 <statistics+0x20c4>
    4b02:	00001097          	auipc	ra,0x1
    4b06:	b50080e7          	jalr	-1200(ra) # 5652 <open>
    4b0a:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4b0c:	4481                	li	s1,0
    memset(buf, i, SZ);
    4b0e:	00007917          	auipc	s2,0x7
    4b12:	04290913          	addi	s2,s2,66 # bb50 <buf>
  for(i = 0; i < N; i++){
    4b16:	4a51                	li	s4,20
  if(fd < 0){
    4b18:	0a054063          	bltz	a0,4bb8 <bigfile+0xe6>
    memset(buf, i, SZ);
    4b1c:	25800613          	li	a2,600
    4b20:	85a6                	mv	a1,s1
    4b22:	854a                	mv	a0,s2
    4b24:	00001097          	auipc	ra,0x1
    4b28:	8ea080e7          	jalr	-1814(ra) # 540e <memset>
    if(write(fd, buf, SZ) != SZ){
    4b2c:	25800613          	li	a2,600
    4b30:	85ca                	mv	a1,s2
    4b32:	854e                	mv	a0,s3
    4b34:	00001097          	auipc	ra,0x1
    4b38:	afe080e7          	jalr	-1282(ra) # 5632 <write>
    4b3c:	25800793          	li	a5,600
    4b40:	08f51a63          	bne	a0,a5,4bd4 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4b44:	2485                	addiw	s1,s1,1
    4b46:	fd449be3          	bne	s1,s4,4b1c <bigfile+0x4a>
  close(fd);
    4b4a:	854e                	mv	a0,s3
    4b4c:	00001097          	auipc	ra,0x1
    4b50:	aee080e7          	jalr	-1298(ra) # 563a <close>
  fd = open("bigfile.dat", 0);
    4b54:	4581                	li	a1,0
    4b56:	00003517          	auipc	a0,0x3
    4b5a:	09a50513          	addi	a0,a0,154 # 7bf0 <statistics+0x20c4>
    4b5e:	00001097          	auipc	ra,0x1
    4b62:	af4080e7          	jalr	-1292(ra) # 5652 <open>
    4b66:	8a2a                	mv	s4,a0
  total = 0;
    4b68:	4981                	li	s3,0
  for(i = 0; ; i++){
    4b6a:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4b6c:	00007917          	auipc	s2,0x7
    4b70:	fe490913          	addi	s2,s2,-28 # bb50 <buf>
  if(fd < 0){
    4b74:	06054e63          	bltz	a0,4bf0 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4b78:	12c00613          	li	a2,300
    4b7c:	85ca                	mv	a1,s2
    4b7e:	8552                	mv	a0,s4
    4b80:	00001097          	auipc	ra,0x1
    4b84:	aaa080e7          	jalr	-1366(ra) # 562a <read>
    if(cc < 0){
    4b88:	08054263          	bltz	a0,4c0c <bigfile+0x13a>
    if(cc == 0)
    4b8c:	c971                	beqz	a0,4c60 <bigfile+0x18e>
    if(cc != SZ/2){
    4b8e:	12c00793          	li	a5,300
    4b92:	08f51b63          	bne	a0,a5,4c28 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4b96:	01f4d79b          	srliw	a5,s1,0x1f
    4b9a:	9fa5                	addw	a5,a5,s1
    4b9c:	4017d79b          	sraiw	a5,a5,0x1
    4ba0:	00094703          	lbu	a4,0(s2)
    4ba4:	0af71063          	bne	a4,a5,4c44 <bigfile+0x172>
    4ba8:	12b94703          	lbu	a4,299(s2)
    4bac:	08f71c63          	bne	a4,a5,4c44 <bigfile+0x172>
    total += cc;
    4bb0:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4bb4:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4bb6:	b7c9                	j	4b78 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4bb8:	85d6                	mv	a1,s5
    4bba:	00003517          	auipc	a0,0x3
    4bbe:	04650513          	addi	a0,a0,70 # 7c00 <statistics+0x20d4>
    4bc2:	00001097          	auipc	ra,0x1
    4bc6:	dc8080e7          	jalr	-568(ra) # 598a <printf>
    exit(1);
    4bca:	4505                	li	a0,1
    4bcc:	00001097          	auipc	ra,0x1
    4bd0:	a46080e7          	jalr	-1466(ra) # 5612 <exit>
      printf("%s: write bigfile failed\n", s);
    4bd4:	85d6                	mv	a1,s5
    4bd6:	00003517          	auipc	a0,0x3
    4bda:	04a50513          	addi	a0,a0,74 # 7c20 <statistics+0x20f4>
    4bde:	00001097          	auipc	ra,0x1
    4be2:	dac080e7          	jalr	-596(ra) # 598a <printf>
      exit(1);
    4be6:	4505                	li	a0,1
    4be8:	00001097          	auipc	ra,0x1
    4bec:	a2a080e7          	jalr	-1494(ra) # 5612 <exit>
    printf("%s: cannot open bigfile\n", s);
    4bf0:	85d6                	mv	a1,s5
    4bf2:	00003517          	auipc	a0,0x3
    4bf6:	04e50513          	addi	a0,a0,78 # 7c40 <statistics+0x2114>
    4bfa:	00001097          	auipc	ra,0x1
    4bfe:	d90080e7          	jalr	-624(ra) # 598a <printf>
    exit(1);
    4c02:	4505                	li	a0,1
    4c04:	00001097          	auipc	ra,0x1
    4c08:	a0e080e7          	jalr	-1522(ra) # 5612 <exit>
      printf("%s: read bigfile failed\n", s);
    4c0c:	85d6                	mv	a1,s5
    4c0e:	00003517          	auipc	a0,0x3
    4c12:	05250513          	addi	a0,a0,82 # 7c60 <statistics+0x2134>
    4c16:	00001097          	auipc	ra,0x1
    4c1a:	d74080e7          	jalr	-652(ra) # 598a <printf>
      exit(1);
    4c1e:	4505                	li	a0,1
    4c20:	00001097          	auipc	ra,0x1
    4c24:	9f2080e7          	jalr	-1550(ra) # 5612 <exit>
      printf("%s: short read bigfile\n", s);
    4c28:	85d6                	mv	a1,s5
    4c2a:	00003517          	auipc	a0,0x3
    4c2e:	05650513          	addi	a0,a0,86 # 7c80 <statistics+0x2154>
    4c32:	00001097          	auipc	ra,0x1
    4c36:	d58080e7          	jalr	-680(ra) # 598a <printf>
      exit(1);
    4c3a:	4505                	li	a0,1
    4c3c:	00001097          	auipc	ra,0x1
    4c40:	9d6080e7          	jalr	-1578(ra) # 5612 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4c44:	85d6                	mv	a1,s5
    4c46:	00003517          	auipc	a0,0x3
    4c4a:	05250513          	addi	a0,a0,82 # 7c98 <statistics+0x216c>
    4c4e:	00001097          	auipc	ra,0x1
    4c52:	d3c080e7          	jalr	-708(ra) # 598a <printf>
      exit(1);
    4c56:	4505                	li	a0,1
    4c58:	00001097          	auipc	ra,0x1
    4c5c:	9ba080e7          	jalr	-1606(ra) # 5612 <exit>
  close(fd);
    4c60:	8552                	mv	a0,s4
    4c62:	00001097          	auipc	ra,0x1
    4c66:	9d8080e7          	jalr	-1576(ra) # 563a <close>
  if(total != N*SZ){
    4c6a:	678d                	lui	a5,0x3
    4c6c:	ee078793          	addi	a5,a5,-288 # 2ee0 <exitiputtest+0x48>
    4c70:	02f99363          	bne	s3,a5,4c96 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4c74:	00003517          	auipc	a0,0x3
    4c78:	f7c50513          	addi	a0,a0,-132 # 7bf0 <statistics+0x20c4>
    4c7c:	00001097          	auipc	ra,0x1
    4c80:	9e6080e7          	jalr	-1562(ra) # 5662 <unlink>
}
    4c84:	70e2                	ld	ra,56(sp)
    4c86:	7442                	ld	s0,48(sp)
    4c88:	74a2                	ld	s1,40(sp)
    4c8a:	7902                	ld	s2,32(sp)
    4c8c:	69e2                	ld	s3,24(sp)
    4c8e:	6a42                	ld	s4,16(sp)
    4c90:	6aa2                	ld	s5,8(sp)
    4c92:	6121                	addi	sp,sp,64
    4c94:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4c96:	85d6                	mv	a1,s5
    4c98:	00003517          	auipc	a0,0x3
    4c9c:	02050513          	addi	a0,a0,32 # 7cb8 <statistics+0x218c>
    4ca0:	00001097          	auipc	ra,0x1
    4ca4:	cea080e7          	jalr	-790(ra) # 598a <printf>
    exit(1);
    4ca8:	4505                	li	a0,1
    4caa:	00001097          	auipc	ra,0x1
    4cae:	968080e7          	jalr	-1688(ra) # 5612 <exit>

0000000000004cb2 <fsfull>:
{
    4cb2:	7171                	addi	sp,sp,-176
    4cb4:	f506                	sd	ra,168(sp)
    4cb6:	f122                	sd	s0,160(sp)
    4cb8:	ed26                	sd	s1,152(sp)
    4cba:	e94a                	sd	s2,144(sp)
    4cbc:	e54e                	sd	s3,136(sp)
    4cbe:	e152                	sd	s4,128(sp)
    4cc0:	fcd6                	sd	s5,120(sp)
    4cc2:	f8da                	sd	s6,112(sp)
    4cc4:	f4de                	sd	s7,104(sp)
    4cc6:	f0e2                	sd	s8,96(sp)
    4cc8:	ece6                	sd	s9,88(sp)
    4cca:	e8ea                	sd	s10,80(sp)
    4ccc:	e4ee                	sd	s11,72(sp)
    4cce:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4cd0:	00003517          	auipc	a0,0x3
    4cd4:	00850513          	addi	a0,a0,8 # 7cd8 <statistics+0x21ac>
    4cd8:	00001097          	auipc	ra,0x1
    4cdc:	cb2080e7          	jalr	-846(ra) # 598a <printf>
  for(nfiles = 0; ; nfiles++){
    4ce0:	4481                	li	s1,0
    name[0] = 'f';
    4ce2:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4ce6:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4cea:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4cee:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4cf0:	00003c97          	auipc	s9,0x3
    4cf4:	ff8c8c93          	addi	s9,s9,-8 # 7ce8 <statistics+0x21bc>
    int total = 0;
    4cf8:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4cfa:	00007a17          	auipc	s4,0x7
    4cfe:	e56a0a13          	addi	s4,s4,-426 # bb50 <buf>
    name[0] = 'f';
    4d02:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d06:	0384c7bb          	divw	a5,s1,s8
    4d0a:	0307879b          	addiw	a5,a5,48
    4d0e:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4d12:	0384e7bb          	remw	a5,s1,s8
    4d16:	0377c7bb          	divw	a5,a5,s7
    4d1a:	0307879b          	addiw	a5,a5,48
    4d1e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4d22:	0374e7bb          	remw	a5,s1,s7
    4d26:	0367c7bb          	divw	a5,a5,s6
    4d2a:	0307879b          	addiw	a5,a5,48
    4d2e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4d32:	0364e7bb          	remw	a5,s1,s6
    4d36:	0307879b          	addiw	a5,a5,48
    4d3a:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4d3e:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4d42:	f5040593          	addi	a1,s0,-176
    4d46:	8566                	mv	a0,s9
    4d48:	00001097          	auipc	ra,0x1
    4d4c:	c42080e7          	jalr	-958(ra) # 598a <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4d50:	20200593          	li	a1,514
    4d54:	f5040513          	addi	a0,s0,-176
    4d58:	00001097          	auipc	ra,0x1
    4d5c:	8fa080e7          	jalr	-1798(ra) # 5652 <open>
    4d60:	892a                	mv	s2,a0
    if(fd < 0){
    4d62:	0a055663          	bgez	a0,4e0e <fsfull+0x15c>
      printf("open %s failed\n", name);
    4d66:	f5040593          	addi	a1,s0,-176
    4d6a:	00003517          	auipc	a0,0x3
    4d6e:	f8e50513          	addi	a0,a0,-114 # 7cf8 <statistics+0x21cc>
    4d72:	00001097          	auipc	ra,0x1
    4d76:	c18080e7          	jalr	-1000(ra) # 598a <printf>
  while(nfiles >= 0){
    4d7a:	0604c363          	bltz	s1,4de0 <fsfull+0x12e>
    name[0] = 'f';
    4d7e:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4d82:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d86:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d8a:	4929                	li	s2,10
  while(nfiles >= 0){
    4d8c:	5afd                	li	s5,-1
    name[0] = 'f';
    4d8e:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d92:	0344c7bb          	divw	a5,s1,s4
    4d96:	0307879b          	addiw	a5,a5,48
    4d9a:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4d9e:	0344e7bb          	remw	a5,s1,s4
    4da2:	0337c7bb          	divw	a5,a5,s3
    4da6:	0307879b          	addiw	a5,a5,48
    4daa:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4dae:	0334e7bb          	remw	a5,s1,s3
    4db2:	0327c7bb          	divw	a5,a5,s2
    4db6:	0307879b          	addiw	a5,a5,48
    4dba:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4dbe:	0324e7bb          	remw	a5,s1,s2
    4dc2:	0307879b          	addiw	a5,a5,48
    4dc6:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4dca:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4dce:	f5040513          	addi	a0,s0,-176
    4dd2:	00001097          	auipc	ra,0x1
    4dd6:	890080e7          	jalr	-1904(ra) # 5662 <unlink>
    nfiles--;
    4dda:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4ddc:	fb5499e3          	bne	s1,s5,4d8e <fsfull+0xdc>
  printf("fsfull test finished\n");
    4de0:	00003517          	auipc	a0,0x3
    4de4:	f3850513          	addi	a0,a0,-200 # 7d18 <statistics+0x21ec>
    4de8:	00001097          	auipc	ra,0x1
    4dec:	ba2080e7          	jalr	-1118(ra) # 598a <printf>
}
    4df0:	70aa                	ld	ra,168(sp)
    4df2:	740a                	ld	s0,160(sp)
    4df4:	64ea                	ld	s1,152(sp)
    4df6:	694a                	ld	s2,144(sp)
    4df8:	69aa                	ld	s3,136(sp)
    4dfa:	6a0a                	ld	s4,128(sp)
    4dfc:	7ae6                	ld	s5,120(sp)
    4dfe:	7b46                	ld	s6,112(sp)
    4e00:	7ba6                	ld	s7,104(sp)
    4e02:	7c06                	ld	s8,96(sp)
    4e04:	6ce6                	ld	s9,88(sp)
    4e06:	6d46                	ld	s10,80(sp)
    4e08:	6da6                	ld	s11,72(sp)
    4e0a:	614d                	addi	sp,sp,176
    4e0c:	8082                	ret
    int total = 0;
    4e0e:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4e10:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4e14:	40000613          	li	a2,1024
    4e18:	85d2                	mv	a1,s4
    4e1a:	854a                	mv	a0,s2
    4e1c:	00001097          	auipc	ra,0x1
    4e20:	816080e7          	jalr	-2026(ra) # 5632 <write>
      if(cc < BSIZE)
    4e24:	00aad563          	bge	s5,a0,4e2e <fsfull+0x17c>
      total += cc;
    4e28:	00a989bb          	addw	s3,s3,a0
    while(1){
    4e2c:	b7e5                	j	4e14 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4e2e:	85ce                	mv	a1,s3
    4e30:	00003517          	auipc	a0,0x3
    4e34:	ed850513          	addi	a0,a0,-296 # 7d08 <statistics+0x21dc>
    4e38:	00001097          	auipc	ra,0x1
    4e3c:	b52080e7          	jalr	-1198(ra) # 598a <printf>
    close(fd);
    4e40:	854a                	mv	a0,s2
    4e42:	00000097          	auipc	ra,0x0
    4e46:	7f8080e7          	jalr	2040(ra) # 563a <close>
    if(total == 0)
    4e4a:	f20988e3          	beqz	s3,4d7a <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4e4e:	2485                	addiw	s1,s1,1
    4e50:	bd4d                	j	4d02 <fsfull+0x50>

0000000000004e52 <rand>:
{
    4e52:	1141                	addi	sp,sp,-16
    4e54:	e422                	sd	s0,8(sp)
    4e56:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4e58:	00003717          	auipc	a4,0x3
    4e5c:	4d070713          	addi	a4,a4,1232 # 8328 <randstate>
    4e60:	6308                	ld	a0,0(a4)
    4e62:	001967b7          	lui	a5,0x196
    4e66:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187aad>
    4e6a:	02f50533          	mul	a0,a0,a5
    4e6e:	3c6ef7b7          	lui	a5,0x3c6ef
    4e72:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e07ff>
    4e76:	953e                	add	a0,a0,a5
    4e78:	e308                	sd	a0,0(a4)
}
    4e7a:	2501                	sext.w	a0,a0
    4e7c:	6422                	ld	s0,8(sp)
    4e7e:	0141                	addi	sp,sp,16
    4e80:	8082                	ret

0000000000004e82 <badwrite>:
{
    4e82:	7179                	addi	sp,sp,-48
    4e84:	f406                	sd	ra,40(sp)
    4e86:	f022                	sd	s0,32(sp)
    4e88:	ec26                	sd	s1,24(sp)
    4e8a:	e84a                	sd	s2,16(sp)
    4e8c:	e44e                	sd	s3,8(sp)
    4e8e:	e052                	sd	s4,0(sp)
    4e90:	1800                	addi	s0,sp,48
  unlink("junk");
    4e92:	00003517          	auipc	a0,0x3
    4e96:	e9e50513          	addi	a0,a0,-354 # 7d30 <statistics+0x2204>
    4e9a:	00000097          	auipc	ra,0x0
    4e9e:	7c8080e7          	jalr	1992(ra) # 5662 <unlink>
    4ea2:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4ea6:	00003997          	auipc	s3,0x3
    4eaa:	e8a98993          	addi	s3,s3,-374 # 7d30 <statistics+0x2204>
    write(fd, (char*)0xffffffffffL, 1);
    4eae:	5a7d                	li	s4,-1
    4eb0:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4eb4:	20100593          	li	a1,513
    4eb8:	854e                	mv	a0,s3
    4eba:	00000097          	auipc	ra,0x0
    4ebe:	798080e7          	jalr	1944(ra) # 5652 <open>
    4ec2:	84aa                	mv	s1,a0
    if(fd < 0){
    4ec4:	06054b63          	bltz	a0,4f3a <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4ec8:	4605                	li	a2,1
    4eca:	85d2                	mv	a1,s4
    4ecc:	00000097          	auipc	ra,0x0
    4ed0:	766080e7          	jalr	1894(ra) # 5632 <write>
    close(fd);
    4ed4:	8526                	mv	a0,s1
    4ed6:	00000097          	auipc	ra,0x0
    4eda:	764080e7          	jalr	1892(ra) # 563a <close>
    unlink("junk");
    4ede:	854e                	mv	a0,s3
    4ee0:	00000097          	auipc	ra,0x0
    4ee4:	782080e7          	jalr	1922(ra) # 5662 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4ee8:	397d                	addiw	s2,s2,-1
    4eea:	fc0915e3          	bnez	s2,4eb4 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4eee:	20100593          	li	a1,513
    4ef2:	00003517          	auipc	a0,0x3
    4ef6:	e3e50513          	addi	a0,a0,-450 # 7d30 <statistics+0x2204>
    4efa:	00000097          	auipc	ra,0x0
    4efe:	758080e7          	jalr	1880(ra) # 5652 <open>
    4f02:	84aa                	mv	s1,a0
  if(fd < 0){
    4f04:	04054863          	bltz	a0,4f54 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4f08:	4605                	li	a2,1
    4f0a:	00001597          	auipc	a1,0x1
    4f0e:	07658593          	addi	a1,a1,118 # 5f80 <statistics+0x454>
    4f12:	00000097          	auipc	ra,0x0
    4f16:	720080e7          	jalr	1824(ra) # 5632 <write>
    4f1a:	4785                	li	a5,1
    4f1c:	04f50963          	beq	a0,a5,4f6e <badwrite+0xec>
    printf("write failed\n");
    4f20:	00003517          	auipc	a0,0x3
    4f24:	e3050513          	addi	a0,a0,-464 # 7d50 <statistics+0x2224>
    4f28:	00001097          	auipc	ra,0x1
    4f2c:	a62080e7          	jalr	-1438(ra) # 598a <printf>
    exit(1);
    4f30:	4505                	li	a0,1
    4f32:	00000097          	auipc	ra,0x0
    4f36:	6e0080e7          	jalr	1760(ra) # 5612 <exit>
      printf("open junk failed\n");
    4f3a:	00003517          	auipc	a0,0x3
    4f3e:	dfe50513          	addi	a0,a0,-514 # 7d38 <statistics+0x220c>
    4f42:	00001097          	auipc	ra,0x1
    4f46:	a48080e7          	jalr	-1464(ra) # 598a <printf>
      exit(1);
    4f4a:	4505                	li	a0,1
    4f4c:	00000097          	auipc	ra,0x0
    4f50:	6c6080e7          	jalr	1734(ra) # 5612 <exit>
    printf("open junk failed\n");
    4f54:	00003517          	auipc	a0,0x3
    4f58:	de450513          	addi	a0,a0,-540 # 7d38 <statistics+0x220c>
    4f5c:	00001097          	auipc	ra,0x1
    4f60:	a2e080e7          	jalr	-1490(ra) # 598a <printf>
    exit(1);
    4f64:	4505                	li	a0,1
    4f66:	00000097          	auipc	ra,0x0
    4f6a:	6ac080e7          	jalr	1708(ra) # 5612 <exit>
  close(fd);
    4f6e:	8526                	mv	a0,s1
    4f70:	00000097          	auipc	ra,0x0
    4f74:	6ca080e7          	jalr	1738(ra) # 563a <close>
  unlink("junk");
    4f78:	00003517          	auipc	a0,0x3
    4f7c:	db850513          	addi	a0,a0,-584 # 7d30 <statistics+0x2204>
    4f80:	00000097          	auipc	ra,0x0
    4f84:	6e2080e7          	jalr	1762(ra) # 5662 <unlink>
  exit(0);
    4f88:	4501                	li	a0,0
    4f8a:	00000097          	auipc	ra,0x0
    4f8e:	688080e7          	jalr	1672(ra) # 5612 <exit>

0000000000004f92 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4f92:	7139                	addi	sp,sp,-64
    4f94:	fc06                	sd	ra,56(sp)
    4f96:	f822                	sd	s0,48(sp)
    4f98:	f426                	sd	s1,40(sp)
    4f9a:	f04a                	sd	s2,32(sp)
    4f9c:	ec4e                	sd	s3,24(sp)
    4f9e:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4fa0:	fc840513          	addi	a0,s0,-56
    4fa4:	00000097          	auipc	ra,0x0
    4fa8:	67e080e7          	jalr	1662(ra) # 5622 <pipe>
    4fac:	06054763          	bltz	a0,501a <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4fb0:	00000097          	auipc	ra,0x0
    4fb4:	65a080e7          	jalr	1626(ra) # 560a <fork>

  if(pid < 0){
    4fb8:	06054e63          	bltz	a0,5034 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4fbc:	ed51                	bnez	a0,5058 <countfree+0xc6>
    close(fds[0]);
    4fbe:	fc842503          	lw	a0,-56(s0)
    4fc2:	00000097          	auipc	ra,0x0
    4fc6:	678080e7          	jalr	1656(ra) # 563a <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4fca:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4fcc:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4fce:	00001997          	auipc	s3,0x1
    4fd2:	fb298993          	addi	s3,s3,-78 # 5f80 <statistics+0x454>
      uint64 a = (uint64) sbrk(4096);
    4fd6:	6505                	lui	a0,0x1
    4fd8:	00000097          	auipc	ra,0x0
    4fdc:	6c2080e7          	jalr	1730(ra) # 569a <sbrk>
      if(a == 0xffffffffffffffff){
    4fe0:	07250763          	beq	a0,s2,504e <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    4fe4:	6785                	lui	a5,0x1
    4fe6:	953e                	add	a0,a0,a5
    4fe8:	fe950fa3          	sb	s1,-1(a0) # fff <bigdir+0x9d>
      if(write(fds[1], "x", 1) != 1){
    4fec:	8626                	mv	a2,s1
    4fee:	85ce                	mv	a1,s3
    4ff0:	fcc42503          	lw	a0,-52(s0)
    4ff4:	00000097          	auipc	ra,0x0
    4ff8:	63e080e7          	jalr	1598(ra) # 5632 <write>
    4ffc:	fc950de3          	beq	a0,s1,4fd6 <countfree+0x44>
        printf("write() failed in countfree()\n");
    5000:	00003517          	auipc	a0,0x3
    5004:	da050513          	addi	a0,a0,-608 # 7da0 <statistics+0x2274>
    5008:	00001097          	auipc	ra,0x1
    500c:	982080e7          	jalr	-1662(ra) # 598a <printf>
        exit(1);
    5010:	4505                	li	a0,1
    5012:	00000097          	auipc	ra,0x0
    5016:	600080e7          	jalr	1536(ra) # 5612 <exit>
    printf("pipe() failed in countfree()\n");
    501a:	00003517          	auipc	a0,0x3
    501e:	d4650513          	addi	a0,a0,-698 # 7d60 <statistics+0x2234>
    5022:	00001097          	auipc	ra,0x1
    5026:	968080e7          	jalr	-1688(ra) # 598a <printf>
    exit(1);
    502a:	4505                	li	a0,1
    502c:	00000097          	auipc	ra,0x0
    5030:	5e6080e7          	jalr	1510(ra) # 5612 <exit>
    printf("fork failed in countfree()\n");
    5034:	00003517          	auipc	a0,0x3
    5038:	d4c50513          	addi	a0,a0,-692 # 7d80 <statistics+0x2254>
    503c:	00001097          	auipc	ra,0x1
    5040:	94e080e7          	jalr	-1714(ra) # 598a <printf>
    exit(1);
    5044:	4505                	li	a0,1
    5046:	00000097          	auipc	ra,0x0
    504a:	5cc080e7          	jalr	1484(ra) # 5612 <exit>
      }
    }

    exit(0);
    504e:	4501                	li	a0,0
    5050:	00000097          	auipc	ra,0x0
    5054:	5c2080e7          	jalr	1474(ra) # 5612 <exit>
  }

  close(fds[1]);
    5058:	fcc42503          	lw	a0,-52(s0)
    505c:	00000097          	auipc	ra,0x0
    5060:	5de080e7          	jalr	1502(ra) # 563a <close>

  int n = 0;
    5064:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    5066:	4605                	li	a2,1
    5068:	fc740593          	addi	a1,s0,-57
    506c:	fc842503          	lw	a0,-56(s0)
    5070:	00000097          	auipc	ra,0x0
    5074:	5ba080e7          	jalr	1466(ra) # 562a <read>
    if(cc < 0){
    5078:	00054563          	bltz	a0,5082 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    507c:	c105                	beqz	a0,509c <countfree+0x10a>
      break;
    n += 1;
    507e:	2485                	addiw	s1,s1,1
  while(1){
    5080:	b7dd                	j	5066 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5082:	00003517          	auipc	a0,0x3
    5086:	d3e50513          	addi	a0,a0,-706 # 7dc0 <statistics+0x2294>
    508a:	00001097          	auipc	ra,0x1
    508e:	900080e7          	jalr	-1792(ra) # 598a <printf>
      exit(1);
    5092:	4505                	li	a0,1
    5094:	00000097          	auipc	ra,0x0
    5098:	57e080e7          	jalr	1406(ra) # 5612 <exit>
  }

  close(fds[0]);
    509c:	fc842503          	lw	a0,-56(s0)
    50a0:	00000097          	auipc	ra,0x0
    50a4:	59a080e7          	jalr	1434(ra) # 563a <close>
  wait((int*)0);
    50a8:	4501                	li	a0,0
    50aa:	00000097          	auipc	ra,0x0
    50ae:	570080e7          	jalr	1392(ra) # 561a <wait>
  
  return n;
}
    50b2:	8526                	mv	a0,s1
    50b4:	70e2                	ld	ra,56(sp)
    50b6:	7442                	ld	s0,48(sp)
    50b8:	74a2                	ld	s1,40(sp)
    50ba:	7902                	ld	s2,32(sp)
    50bc:	69e2                	ld	s3,24(sp)
    50be:	6121                	addi	sp,sp,64
    50c0:	8082                	ret

00000000000050c2 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    50c2:	7179                	addi	sp,sp,-48
    50c4:	f406                	sd	ra,40(sp)
    50c6:	f022                	sd	s0,32(sp)
    50c8:	ec26                	sd	s1,24(sp)
    50ca:	e84a                	sd	s2,16(sp)
    50cc:	1800                	addi	s0,sp,48
    50ce:	84aa                	mv	s1,a0
    50d0:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    50d2:	00003517          	auipc	a0,0x3
    50d6:	d0e50513          	addi	a0,a0,-754 # 7de0 <statistics+0x22b4>
    50da:	00001097          	auipc	ra,0x1
    50de:	8b0080e7          	jalr	-1872(ra) # 598a <printf>
  if((pid = fork()) < 0) {
    50e2:	00000097          	auipc	ra,0x0
    50e6:	528080e7          	jalr	1320(ra) # 560a <fork>
    50ea:	02054e63          	bltz	a0,5126 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    50ee:	c929                	beqz	a0,5140 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    50f0:	fdc40513          	addi	a0,s0,-36
    50f4:	00000097          	auipc	ra,0x0
    50f8:	526080e7          	jalr	1318(ra) # 561a <wait>
    if(xstatus != 0) 
    50fc:	fdc42783          	lw	a5,-36(s0)
    5100:	c7b9                	beqz	a5,514e <run+0x8c>
      printf("FAILED\n");
    5102:	00003517          	auipc	a0,0x3
    5106:	d0650513          	addi	a0,a0,-762 # 7e08 <statistics+0x22dc>
    510a:	00001097          	auipc	ra,0x1
    510e:	880080e7          	jalr	-1920(ra) # 598a <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5112:	fdc42503          	lw	a0,-36(s0)
  }
}
    5116:	00153513          	seqz	a0,a0
    511a:	70a2                	ld	ra,40(sp)
    511c:	7402                	ld	s0,32(sp)
    511e:	64e2                	ld	s1,24(sp)
    5120:	6942                	ld	s2,16(sp)
    5122:	6145                	addi	sp,sp,48
    5124:	8082                	ret
    printf("runtest: fork error\n");
    5126:	00003517          	auipc	a0,0x3
    512a:	cca50513          	addi	a0,a0,-822 # 7df0 <statistics+0x22c4>
    512e:	00001097          	auipc	ra,0x1
    5132:	85c080e7          	jalr	-1956(ra) # 598a <printf>
    exit(1);
    5136:	4505                	li	a0,1
    5138:	00000097          	auipc	ra,0x0
    513c:	4da080e7          	jalr	1242(ra) # 5612 <exit>
    f(s);
    5140:	854a                	mv	a0,s2
    5142:	9482                	jalr	s1
    exit(0);
    5144:	4501                	li	a0,0
    5146:	00000097          	auipc	ra,0x0
    514a:	4cc080e7          	jalr	1228(ra) # 5612 <exit>
      printf("OK\n");
    514e:	00003517          	auipc	a0,0x3
    5152:	cc250513          	addi	a0,a0,-830 # 7e10 <statistics+0x22e4>
    5156:	00001097          	auipc	ra,0x1
    515a:	834080e7          	jalr	-1996(ra) # 598a <printf>
    515e:	bf55                	j	5112 <run+0x50>

0000000000005160 <main>:

int
main(int argc, char *argv[])
{
    5160:	c1010113          	addi	sp,sp,-1008
    5164:	3e113423          	sd	ra,1000(sp)
    5168:	3e813023          	sd	s0,992(sp)
    516c:	3c913c23          	sd	s1,984(sp)
    5170:	3d213823          	sd	s2,976(sp)
    5174:	3d313423          	sd	s3,968(sp)
    5178:	3d413023          	sd	s4,960(sp)
    517c:	3b513c23          	sd	s5,952(sp)
    5180:	3b613823          	sd	s6,944(sp)
    5184:	1f80                	addi	s0,sp,1008
    5186:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5188:	4789                	li	a5,2
    518a:	08f50b63          	beq	a0,a5,5220 <main+0xc0>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    518e:	4785                	li	a5,1
  char *justone = 0;
    5190:	4901                	li	s2,0
  } else if(argc > 1){
    5192:	0ca7c563          	blt	a5,a0,525c <main+0xfc>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    5196:	00003797          	auipc	a5,0x3
    519a:	d9278793          	addi	a5,a5,-622 # 7f28 <statistics+0x23fc>
    519e:	c1040713          	addi	a4,s0,-1008
    51a2:	00003817          	auipc	a6,0x3
    51a6:	12680813          	addi	a6,a6,294 # 82c8 <statistics+0x279c>
    51aa:	6388                	ld	a0,0(a5)
    51ac:	678c                	ld	a1,8(a5)
    51ae:	6b90                	ld	a2,16(a5)
    51b0:	6f94                	ld	a3,24(a5)
    51b2:	e308                	sd	a0,0(a4)
    51b4:	e70c                	sd	a1,8(a4)
    51b6:	eb10                	sd	a2,16(a4)
    51b8:	ef14                	sd	a3,24(a4)
    51ba:	02078793          	addi	a5,a5,32
    51be:	02070713          	addi	a4,a4,32
    51c2:	ff0794e3          	bne	a5,a6,51aa <main+0x4a>
    51c6:	6394                	ld	a3,0(a5)
    51c8:	679c                	ld	a5,8(a5)
    51ca:	e314                	sd	a3,0(a4)
    51cc:	e71c                	sd	a5,8(a4)
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    51ce:	00003517          	auipc	a0,0x3
    51d2:	cfa50513          	addi	a0,a0,-774 # 7ec8 <statistics+0x239c>
    51d6:	00000097          	auipc	ra,0x0
    51da:	7b4080e7          	jalr	1972(ra) # 598a <printf>
  int free0 = countfree();
    51de:	00000097          	auipc	ra,0x0
    51e2:	db4080e7          	jalr	-588(ra) # 4f92 <countfree>
    51e6:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    51e8:	c1843503          	ld	a0,-1000(s0)
    51ec:	c1040493          	addi	s1,s0,-1008
  int fail = 0;
    51f0:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    51f2:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    51f4:	e55d                	bnez	a0,52a2 <main+0x142>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    51f6:	00000097          	auipc	ra,0x0
    51fa:	d9c080e7          	jalr	-612(ra) # 4f92 <countfree>
    51fe:	85aa                	mv	a1,a0
    5200:	0f455163          	bge	a0,s4,52e2 <main+0x182>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5204:	8652                	mv	a2,s4
    5206:	00003517          	auipc	a0,0x3
    520a:	c7a50513          	addi	a0,a0,-902 # 7e80 <statistics+0x2354>
    520e:	00000097          	auipc	ra,0x0
    5212:	77c080e7          	jalr	1916(ra) # 598a <printf>
    exit(1);
    5216:	4505                	li	a0,1
    5218:	00000097          	auipc	ra,0x0
    521c:	3fa080e7          	jalr	1018(ra) # 5612 <exit>
    5220:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5222:	00003597          	auipc	a1,0x3
    5226:	bf658593          	addi	a1,a1,-1034 # 7e18 <statistics+0x22ec>
    522a:	6488                	ld	a0,8(s1)
    522c:	00000097          	auipc	ra,0x0
    5230:	18c080e7          	jalr	396(ra) # 53b8 <strcmp>
    5234:	10050563          	beqz	a0,533e <main+0x1de>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5238:	00003597          	auipc	a1,0x3
    523c:	cc858593          	addi	a1,a1,-824 # 7f00 <statistics+0x23d4>
    5240:	6488                	ld	a0,8(s1)
    5242:	00000097          	auipc	ra,0x0
    5246:	176080e7          	jalr	374(ra) # 53b8 <strcmp>
    524a:	c97d                	beqz	a0,5340 <main+0x1e0>
  } else if(argc == 2 && argv[1][0] != '-'){
    524c:	0084b903          	ld	s2,8(s1)
    5250:	00094703          	lbu	a4,0(s2)
    5254:	02d00793          	li	a5,45
    5258:	f2f71fe3          	bne	a4,a5,5196 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    525c:	00003517          	auipc	a0,0x3
    5260:	bc450513          	addi	a0,a0,-1084 # 7e20 <statistics+0x22f4>
    5264:	00000097          	auipc	ra,0x0
    5268:	726080e7          	jalr	1830(ra) # 598a <printf>
    exit(1);
    526c:	4505                	li	a0,1
    526e:	00000097          	auipc	ra,0x0
    5272:	3a4080e7          	jalr	932(ra) # 5612 <exit>
          exit(1);
    5276:	4505                	li	a0,1
    5278:	00000097          	auipc	ra,0x0
    527c:	39a080e7          	jalr	922(ra) # 5612 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5280:	40a905bb          	subw	a1,s2,a0
    5284:	855a                	mv	a0,s6
    5286:	00000097          	auipc	ra,0x0
    528a:	704080e7          	jalr	1796(ra) # 598a <printf>
        if(continuous != 2)
    528e:	09498463          	beq	s3,s4,5316 <main+0x1b6>
          exit(1);
    5292:	4505                	li	a0,1
    5294:	00000097          	auipc	ra,0x0
    5298:	37e080e7          	jalr	894(ra) # 5612 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    529c:	04c1                	addi	s1,s1,16
    529e:	6488                	ld	a0,8(s1)
    52a0:	c115                	beqz	a0,52c4 <main+0x164>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    52a2:	00090863          	beqz	s2,52b2 <main+0x152>
    52a6:	85ca                	mv	a1,s2
    52a8:	00000097          	auipc	ra,0x0
    52ac:	110080e7          	jalr	272(ra) # 53b8 <strcmp>
    52b0:	f575                	bnez	a0,529c <main+0x13c>
      if(!run(t->f, t->s))
    52b2:	648c                	ld	a1,8(s1)
    52b4:	6088                	ld	a0,0(s1)
    52b6:	00000097          	auipc	ra,0x0
    52ba:	e0c080e7          	jalr	-500(ra) # 50c2 <run>
    52be:	fd79                	bnez	a0,529c <main+0x13c>
        fail = 1;
    52c0:	89d6                	mv	s3,s5
    52c2:	bfe9                	j	529c <main+0x13c>
  if(fail){
    52c4:	f20989e3          	beqz	s3,51f6 <main+0x96>
    printf("SOME TESTS FAILED\n");
    52c8:	00003517          	auipc	a0,0x3
    52cc:	ba050513          	addi	a0,a0,-1120 # 7e68 <statistics+0x233c>
    52d0:	00000097          	auipc	ra,0x0
    52d4:	6ba080e7          	jalr	1722(ra) # 598a <printf>
    exit(1);
    52d8:	4505                	li	a0,1
    52da:	00000097          	auipc	ra,0x0
    52de:	338080e7          	jalr	824(ra) # 5612 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    52e2:	00003517          	auipc	a0,0x3
    52e6:	bce50513          	addi	a0,a0,-1074 # 7eb0 <statistics+0x2384>
    52ea:	00000097          	auipc	ra,0x0
    52ee:	6a0080e7          	jalr	1696(ra) # 598a <printf>
    exit(0);
    52f2:	4501                	li	a0,0
    52f4:	00000097          	auipc	ra,0x0
    52f8:	31e080e7          	jalr	798(ra) # 5612 <exit>
        printf("SOME TESTS FAILED\n");
    52fc:	8556                	mv	a0,s5
    52fe:	00000097          	auipc	ra,0x0
    5302:	68c080e7          	jalr	1676(ra) # 598a <printf>
        if(continuous != 2)
    5306:	f74998e3          	bne	s3,s4,5276 <main+0x116>
      int free1 = countfree();
    530a:	00000097          	auipc	ra,0x0
    530e:	c88080e7          	jalr	-888(ra) # 4f92 <countfree>
      if(free1 < free0){
    5312:	f72547e3          	blt	a0,s2,5280 <main+0x120>
      int free0 = countfree();
    5316:	00000097          	auipc	ra,0x0
    531a:	c7c080e7          	jalr	-900(ra) # 4f92 <countfree>
    531e:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5320:	c1843583          	ld	a1,-1000(s0)
    5324:	d1fd                	beqz	a1,530a <main+0x1aa>
    5326:	c1040493          	addi	s1,s0,-1008
        if(!run(t->f, t->s)){
    532a:	6088                	ld	a0,0(s1)
    532c:	00000097          	auipc	ra,0x0
    5330:	d96080e7          	jalr	-618(ra) # 50c2 <run>
    5334:	d561                	beqz	a0,52fc <main+0x19c>
      for (struct test *t = tests; t->s != 0; t++) {
    5336:	04c1                	addi	s1,s1,16
    5338:	648c                	ld	a1,8(s1)
    533a:	f9e5                	bnez	a1,532a <main+0x1ca>
    533c:	b7f9                	j	530a <main+0x1aa>
    continuous = 1;
    533e:	4985                	li	s3,1
  } tests[] = {
    5340:	00003797          	auipc	a5,0x3
    5344:	be878793          	addi	a5,a5,-1048 # 7f28 <statistics+0x23fc>
    5348:	c1040713          	addi	a4,s0,-1008
    534c:	00003817          	auipc	a6,0x3
    5350:	f7c80813          	addi	a6,a6,-132 # 82c8 <statistics+0x279c>
    5354:	6388                	ld	a0,0(a5)
    5356:	678c                	ld	a1,8(a5)
    5358:	6b90                	ld	a2,16(a5)
    535a:	6f94                	ld	a3,24(a5)
    535c:	e308                	sd	a0,0(a4)
    535e:	e70c                	sd	a1,8(a4)
    5360:	eb10                	sd	a2,16(a4)
    5362:	ef14                	sd	a3,24(a4)
    5364:	02078793          	addi	a5,a5,32
    5368:	02070713          	addi	a4,a4,32
    536c:	ff0794e3          	bne	a5,a6,5354 <main+0x1f4>
    5370:	6394                	ld	a3,0(a5)
    5372:	679c                	ld	a5,8(a5)
    5374:	e314                	sd	a3,0(a4)
    5376:	e71c                	sd	a5,8(a4)
    printf("continuous usertests starting\n");
    5378:	00003517          	auipc	a0,0x3
    537c:	b6850513          	addi	a0,a0,-1176 # 7ee0 <statistics+0x23b4>
    5380:	00000097          	auipc	ra,0x0
    5384:	60a080e7          	jalr	1546(ra) # 598a <printf>
        printf("SOME TESTS FAILED\n");
    5388:	00003a97          	auipc	s5,0x3
    538c:	ae0a8a93          	addi	s5,s5,-1312 # 7e68 <statistics+0x233c>
        if(continuous != 2)
    5390:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5392:	00003b17          	auipc	s6,0x3
    5396:	ab6b0b13          	addi	s6,s6,-1354 # 7e48 <statistics+0x231c>
    539a:	bfb5                	j	5316 <main+0x1b6>

000000000000539c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    539c:	1141                	addi	sp,sp,-16
    539e:	e422                	sd	s0,8(sp)
    53a0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    53a2:	87aa                	mv	a5,a0
    53a4:	0585                	addi	a1,a1,1
    53a6:	0785                	addi	a5,a5,1
    53a8:	fff5c703          	lbu	a4,-1(a1)
    53ac:	fee78fa3          	sb	a4,-1(a5)
    53b0:	fb75                	bnez	a4,53a4 <strcpy+0x8>
    ;
  return os;
}
    53b2:	6422                	ld	s0,8(sp)
    53b4:	0141                	addi	sp,sp,16
    53b6:	8082                	ret

00000000000053b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    53b8:	1141                	addi	sp,sp,-16
    53ba:	e422                	sd	s0,8(sp)
    53bc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    53be:	00054783          	lbu	a5,0(a0)
    53c2:	cb91                	beqz	a5,53d6 <strcmp+0x1e>
    53c4:	0005c703          	lbu	a4,0(a1)
    53c8:	00f71763          	bne	a4,a5,53d6 <strcmp+0x1e>
    p++, q++;
    53cc:	0505                	addi	a0,a0,1
    53ce:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    53d0:	00054783          	lbu	a5,0(a0)
    53d4:	fbe5                	bnez	a5,53c4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    53d6:	0005c503          	lbu	a0,0(a1)
}
    53da:	40a7853b          	subw	a0,a5,a0
    53de:	6422                	ld	s0,8(sp)
    53e0:	0141                	addi	sp,sp,16
    53e2:	8082                	ret

00000000000053e4 <strlen>:

uint
strlen(const char *s)
{
    53e4:	1141                	addi	sp,sp,-16
    53e6:	e422                	sd	s0,8(sp)
    53e8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    53ea:	00054783          	lbu	a5,0(a0)
    53ee:	cf91                	beqz	a5,540a <strlen+0x26>
    53f0:	0505                	addi	a0,a0,1
    53f2:	87aa                	mv	a5,a0
    53f4:	4685                	li	a3,1
    53f6:	9e89                	subw	a3,a3,a0
    53f8:	00f6853b          	addw	a0,a3,a5
    53fc:	0785                	addi	a5,a5,1
    53fe:	fff7c703          	lbu	a4,-1(a5)
    5402:	fb7d                	bnez	a4,53f8 <strlen+0x14>
    ;
  return n;
}
    5404:	6422                	ld	s0,8(sp)
    5406:	0141                	addi	sp,sp,16
    5408:	8082                	ret
  for(n = 0; s[n]; n++)
    540a:	4501                	li	a0,0
    540c:	bfe5                	j	5404 <strlen+0x20>

000000000000540e <memset>:

void*
memset(void *dst, int c, uint n)
{
    540e:	1141                	addi	sp,sp,-16
    5410:	e422                	sd	s0,8(sp)
    5412:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5414:	ce09                	beqz	a2,542e <memset+0x20>
    5416:	87aa                	mv	a5,a0
    5418:	fff6071b          	addiw	a4,a2,-1
    541c:	1702                	slli	a4,a4,0x20
    541e:	9301                	srli	a4,a4,0x20
    5420:	0705                	addi	a4,a4,1
    5422:	972a                	add	a4,a4,a0
    cdst[i] = c;
    5424:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5428:	0785                	addi	a5,a5,1
    542a:	fee79de3          	bne	a5,a4,5424 <memset+0x16>
  }
  return dst;
}
    542e:	6422                	ld	s0,8(sp)
    5430:	0141                	addi	sp,sp,16
    5432:	8082                	ret

0000000000005434 <strchr>:

char*
strchr(const char *s, char c)
{
    5434:	1141                	addi	sp,sp,-16
    5436:	e422                	sd	s0,8(sp)
    5438:	0800                	addi	s0,sp,16
  for(; *s; s++)
    543a:	00054783          	lbu	a5,0(a0)
    543e:	cb99                	beqz	a5,5454 <strchr+0x20>
    if(*s == c)
    5440:	00f58763          	beq	a1,a5,544e <strchr+0x1a>
  for(; *s; s++)
    5444:	0505                	addi	a0,a0,1
    5446:	00054783          	lbu	a5,0(a0)
    544a:	fbfd                	bnez	a5,5440 <strchr+0xc>
      return (char*)s;
  return 0;
    544c:	4501                	li	a0,0
}
    544e:	6422                	ld	s0,8(sp)
    5450:	0141                	addi	sp,sp,16
    5452:	8082                	ret
  return 0;
    5454:	4501                	li	a0,0
    5456:	bfe5                	j	544e <strchr+0x1a>

0000000000005458 <gets>:

char*
gets(char *buf, int max)
{
    5458:	711d                	addi	sp,sp,-96
    545a:	ec86                	sd	ra,88(sp)
    545c:	e8a2                	sd	s0,80(sp)
    545e:	e4a6                	sd	s1,72(sp)
    5460:	e0ca                	sd	s2,64(sp)
    5462:	fc4e                	sd	s3,56(sp)
    5464:	f852                	sd	s4,48(sp)
    5466:	f456                	sd	s5,40(sp)
    5468:	f05a                	sd	s6,32(sp)
    546a:	ec5e                	sd	s7,24(sp)
    546c:	1080                	addi	s0,sp,96
    546e:	8baa                	mv	s7,a0
    5470:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5472:	892a                	mv	s2,a0
    5474:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5476:	4aa9                	li	s5,10
    5478:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    547a:	89a6                	mv	s3,s1
    547c:	2485                	addiw	s1,s1,1
    547e:	0344d863          	bge	s1,s4,54ae <gets+0x56>
    cc = read(0, &c, 1);
    5482:	4605                	li	a2,1
    5484:	faf40593          	addi	a1,s0,-81
    5488:	4501                	li	a0,0
    548a:	00000097          	auipc	ra,0x0
    548e:	1a0080e7          	jalr	416(ra) # 562a <read>
    if(cc < 1)
    5492:	00a05e63          	blez	a0,54ae <gets+0x56>
    buf[i++] = c;
    5496:	faf44783          	lbu	a5,-81(s0)
    549a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    549e:	01578763          	beq	a5,s5,54ac <gets+0x54>
    54a2:	0905                	addi	s2,s2,1
    54a4:	fd679be3          	bne	a5,s6,547a <gets+0x22>
  for(i=0; i+1 < max; ){
    54a8:	89a6                	mv	s3,s1
    54aa:	a011                	j	54ae <gets+0x56>
    54ac:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    54ae:	99de                	add	s3,s3,s7
    54b0:	00098023          	sb	zero,0(s3)
  return buf;
}
    54b4:	855e                	mv	a0,s7
    54b6:	60e6                	ld	ra,88(sp)
    54b8:	6446                	ld	s0,80(sp)
    54ba:	64a6                	ld	s1,72(sp)
    54bc:	6906                	ld	s2,64(sp)
    54be:	79e2                	ld	s3,56(sp)
    54c0:	7a42                	ld	s4,48(sp)
    54c2:	7aa2                	ld	s5,40(sp)
    54c4:	7b02                	ld	s6,32(sp)
    54c6:	6be2                	ld	s7,24(sp)
    54c8:	6125                	addi	sp,sp,96
    54ca:	8082                	ret

00000000000054cc <stat>:

int
stat(const char *n, struct stat *st)
{
    54cc:	1101                	addi	sp,sp,-32
    54ce:	ec06                	sd	ra,24(sp)
    54d0:	e822                	sd	s0,16(sp)
    54d2:	e426                	sd	s1,8(sp)
    54d4:	e04a                	sd	s2,0(sp)
    54d6:	1000                	addi	s0,sp,32
    54d8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    54da:	4581                	li	a1,0
    54dc:	00000097          	auipc	ra,0x0
    54e0:	176080e7          	jalr	374(ra) # 5652 <open>
  if(fd < 0)
    54e4:	02054563          	bltz	a0,550e <stat+0x42>
    54e8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    54ea:	85ca                	mv	a1,s2
    54ec:	00000097          	auipc	ra,0x0
    54f0:	17e080e7          	jalr	382(ra) # 566a <fstat>
    54f4:	892a                	mv	s2,a0
  close(fd);
    54f6:	8526                	mv	a0,s1
    54f8:	00000097          	auipc	ra,0x0
    54fc:	142080e7          	jalr	322(ra) # 563a <close>
  return r;
}
    5500:	854a                	mv	a0,s2
    5502:	60e2                	ld	ra,24(sp)
    5504:	6442                	ld	s0,16(sp)
    5506:	64a2                	ld	s1,8(sp)
    5508:	6902                	ld	s2,0(sp)
    550a:	6105                	addi	sp,sp,32
    550c:	8082                	ret
    return -1;
    550e:	597d                	li	s2,-1
    5510:	bfc5                	j	5500 <stat+0x34>

0000000000005512 <atoi>:

int
atoi(const char *s)
{
    5512:	1141                	addi	sp,sp,-16
    5514:	e422                	sd	s0,8(sp)
    5516:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5518:	00054603          	lbu	a2,0(a0)
    551c:	fd06079b          	addiw	a5,a2,-48
    5520:	0ff7f793          	andi	a5,a5,255
    5524:	4725                	li	a4,9
    5526:	02f76963          	bltu	a4,a5,5558 <atoi+0x46>
    552a:	86aa                	mv	a3,a0
  n = 0;
    552c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    552e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5530:	0685                	addi	a3,a3,1
    5532:	0025179b          	slliw	a5,a0,0x2
    5536:	9fa9                	addw	a5,a5,a0
    5538:	0017979b          	slliw	a5,a5,0x1
    553c:	9fb1                	addw	a5,a5,a2
    553e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5542:	0006c603          	lbu	a2,0(a3) # 1000 <bigdir+0x9e>
    5546:	fd06071b          	addiw	a4,a2,-48
    554a:	0ff77713          	andi	a4,a4,255
    554e:	fee5f1e3          	bgeu	a1,a4,5530 <atoi+0x1e>
  return n;
}
    5552:	6422                	ld	s0,8(sp)
    5554:	0141                	addi	sp,sp,16
    5556:	8082                	ret
  n = 0;
    5558:	4501                	li	a0,0
    555a:	bfe5                	j	5552 <atoi+0x40>

000000000000555c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    555c:	1141                	addi	sp,sp,-16
    555e:	e422                	sd	s0,8(sp)
    5560:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5562:	02b57663          	bgeu	a0,a1,558e <memmove+0x32>
    while(n-- > 0)
    5566:	02c05163          	blez	a2,5588 <memmove+0x2c>
    556a:	fff6079b          	addiw	a5,a2,-1
    556e:	1782                	slli	a5,a5,0x20
    5570:	9381                	srli	a5,a5,0x20
    5572:	0785                	addi	a5,a5,1
    5574:	97aa                	add	a5,a5,a0
  dst = vdst;
    5576:	872a                	mv	a4,a0
      *dst++ = *src++;
    5578:	0585                	addi	a1,a1,1
    557a:	0705                	addi	a4,a4,1
    557c:	fff5c683          	lbu	a3,-1(a1)
    5580:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5584:	fee79ae3          	bne	a5,a4,5578 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5588:	6422                	ld	s0,8(sp)
    558a:	0141                	addi	sp,sp,16
    558c:	8082                	ret
    dst += n;
    558e:	00c50733          	add	a4,a0,a2
    src += n;
    5592:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5594:	fec05ae3          	blez	a2,5588 <memmove+0x2c>
    5598:	fff6079b          	addiw	a5,a2,-1
    559c:	1782                	slli	a5,a5,0x20
    559e:	9381                	srli	a5,a5,0x20
    55a0:	fff7c793          	not	a5,a5
    55a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    55a6:	15fd                	addi	a1,a1,-1
    55a8:	177d                	addi	a4,a4,-1
    55aa:	0005c683          	lbu	a3,0(a1)
    55ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    55b2:	fee79ae3          	bne	a5,a4,55a6 <memmove+0x4a>
    55b6:	bfc9                	j	5588 <memmove+0x2c>

00000000000055b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    55b8:	1141                	addi	sp,sp,-16
    55ba:	e422                	sd	s0,8(sp)
    55bc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    55be:	ca05                	beqz	a2,55ee <memcmp+0x36>
    55c0:	fff6069b          	addiw	a3,a2,-1
    55c4:	1682                	slli	a3,a3,0x20
    55c6:	9281                	srli	a3,a3,0x20
    55c8:	0685                	addi	a3,a3,1
    55ca:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    55cc:	00054783          	lbu	a5,0(a0)
    55d0:	0005c703          	lbu	a4,0(a1)
    55d4:	00e79863          	bne	a5,a4,55e4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    55d8:	0505                	addi	a0,a0,1
    p2++;
    55da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    55dc:	fed518e3          	bne	a0,a3,55cc <memcmp+0x14>
  }
  return 0;
    55e0:	4501                	li	a0,0
    55e2:	a019                	j	55e8 <memcmp+0x30>
      return *p1 - *p2;
    55e4:	40e7853b          	subw	a0,a5,a4
}
    55e8:	6422                	ld	s0,8(sp)
    55ea:	0141                	addi	sp,sp,16
    55ec:	8082                	ret
  return 0;
    55ee:	4501                	li	a0,0
    55f0:	bfe5                	j	55e8 <memcmp+0x30>

00000000000055f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    55f2:	1141                	addi	sp,sp,-16
    55f4:	e406                	sd	ra,8(sp)
    55f6:	e022                	sd	s0,0(sp)
    55f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    55fa:	00000097          	auipc	ra,0x0
    55fe:	f62080e7          	jalr	-158(ra) # 555c <memmove>
}
    5602:	60a2                	ld	ra,8(sp)
    5604:	6402                	ld	s0,0(sp)
    5606:	0141                	addi	sp,sp,16
    5608:	8082                	ret

000000000000560a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    560a:	4885                	li	a7,1
 ecall
    560c:	00000073          	ecall
 ret
    5610:	8082                	ret

0000000000005612 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5612:	4889                	li	a7,2
 ecall
    5614:	00000073          	ecall
 ret
    5618:	8082                	ret

000000000000561a <wait>:
.global wait
wait:
 li a7, SYS_wait
    561a:	488d                	li	a7,3
 ecall
    561c:	00000073          	ecall
 ret
    5620:	8082                	ret

0000000000005622 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5622:	4891                	li	a7,4
 ecall
    5624:	00000073          	ecall
 ret
    5628:	8082                	ret

000000000000562a <read>:
.global read
read:
 li a7, SYS_read
    562a:	4895                	li	a7,5
 ecall
    562c:	00000073          	ecall
 ret
    5630:	8082                	ret

0000000000005632 <write>:
.global write
write:
 li a7, SYS_write
    5632:	48c1                	li	a7,16
 ecall
    5634:	00000073          	ecall
 ret
    5638:	8082                	ret

000000000000563a <close>:
.global close
close:
 li a7, SYS_close
    563a:	48d5                	li	a7,21
 ecall
    563c:	00000073          	ecall
 ret
    5640:	8082                	ret

0000000000005642 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5642:	4899                	li	a7,6
 ecall
    5644:	00000073          	ecall
 ret
    5648:	8082                	ret

000000000000564a <exec>:
.global exec
exec:
 li a7, SYS_exec
    564a:	489d                	li	a7,7
 ecall
    564c:	00000073          	ecall
 ret
    5650:	8082                	ret

0000000000005652 <open>:
.global open
open:
 li a7, SYS_open
    5652:	48bd                	li	a7,15
 ecall
    5654:	00000073          	ecall
 ret
    5658:	8082                	ret

000000000000565a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    565a:	48c5                	li	a7,17
 ecall
    565c:	00000073          	ecall
 ret
    5660:	8082                	ret

0000000000005662 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5662:	48c9                	li	a7,18
 ecall
    5664:	00000073          	ecall
 ret
    5668:	8082                	ret

000000000000566a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    566a:	48a1                	li	a7,8
 ecall
    566c:	00000073          	ecall
 ret
    5670:	8082                	ret

0000000000005672 <link>:
.global link
link:
 li a7, SYS_link
    5672:	48cd                	li	a7,19
 ecall
    5674:	00000073          	ecall
 ret
    5678:	8082                	ret

000000000000567a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    567a:	48d1                	li	a7,20
 ecall
    567c:	00000073          	ecall
 ret
    5680:	8082                	ret

0000000000005682 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5682:	48a5                	li	a7,9
 ecall
    5684:	00000073          	ecall
 ret
    5688:	8082                	ret

000000000000568a <dup>:
.global dup
dup:
 li a7, SYS_dup
    568a:	48a9                	li	a7,10
 ecall
    568c:	00000073          	ecall
 ret
    5690:	8082                	ret

0000000000005692 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5692:	48ad                	li	a7,11
 ecall
    5694:	00000073          	ecall
 ret
    5698:	8082                	ret

000000000000569a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    569a:	48b1                	li	a7,12
 ecall
    569c:	00000073          	ecall
 ret
    56a0:	8082                	ret

00000000000056a2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    56a2:	48b5                	li	a7,13
 ecall
    56a4:	00000073          	ecall
 ret
    56a8:	8082                	ret

00000000000056aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    56aa:	48b9                	li	a7,14
 ecall
    56ac:	00000073          	ecall
 ret
    56b0:	8082                	ret

00000000000056b2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    56b2:	1101                	addi	sp,sp,-32
    56b4:	ec06                	sd	ra,24(sp)
    56b6:	e822                	sd	s0,16(sp)
    56b8:	1000                	addi	s0,sp,32
    56ba:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    56be:	4605                	li	a2,1
    56c0:	fef40593          	addi	a1,s0,-17
    56c4:	00000097          	auipc	ra,0x0
    56c8:	f6e080e7          	jalr	-146(ra) # 5632 <write>
}
    56cc:	60e2                	ld	ra,24(sp)
    56ce:	6442                	ld	s0,16(sp)
    56d0:	6105                	addi	sp,sp,32
    56d2:	8082                	ret

00000000000056d4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    56d4:	7139                	addi	sp,sp,-64
    56d6:	fc06                	sd	ra,56(sp)
    56d8:	f822                	sd	s0,48(sp)
    56da:	f426                	sd	s1,40(sp)
    56dc:	f04a                	sd	s2,32(sp)
    56de:	ec4e                	sd	s3,24(sp)
    56e0:	0080                	addi	s0,sp,64
    56e2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    56e4:	c299                	beqz	a3,56ea <printint+0x16>
    56e6:	0805c863          	bltz	a1,5776 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    56ea:	2581                	sext.w	a1,a1
  neg = 0;
    56ec:	4881                	li	a7,0
    56ee:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    56f2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    56f4:	2601                	sext.w	a2,a2
    56f6:	00003517          	auipc	a0,0x3
    56fa:	bea50513          	addi	a0,a0,-1046 # 82e0 <digits>
    56fe:	883a                	mv	a6,a4
    5700:	2705                	addiw	a4,a4,1
    5702:	02c5f7bb          	remuw	a5,a1,a2
    5706:	1782                	slli	a5,a5,0x20
    5708:	9381                	srli	a5,a5,0x20
    570a:	97aa                	add	a5,a5,a0
    570c:	0007c783          	lbu	a5,0(a5)
    5710:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5714:	0005879b          	sext.w	a5,a1
    5718:	02c5d5bb          	divuw	a1,a1,a2
    571c:	0685                	addi	a3,a3,1
    571e:	fec7f0e3          	bgeu	a5,a2,56fe <printint+0x2a>
  if(neg)
    5722:	00088b63          	beqz	a7,5738 <printint+0x64>
    buf[i++] = '-';
    5726:	fd040793          	addi	a5,s0,-48
    572a:	973e                	add	a4,a4,a5
    572c:	02d00793          	li	a5,45
    5730:	fef70823          	sb	a5,-16(a4)
    5734:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5738:	02e05863          	blez	a4,5768 <printint+0x94>
    573c:	fc040793          	addi	a5,s0,-64
    5740:	00e78933          	add	s2,a5,a4
    5744:	fff78993          	addi	s3,a5,-1
    5748:	99ba                	add	s3,s3,a4
    574a:	377d                	addiw	a4,a4,-1
    574c:	1702                	slli	a4,a4,0x20
    574e:	9301                	srli	a4,a4,0x20
    5750:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5754:	fff94583          	lbu	a1,-1(s2)
    5758:	8526                	mv	a0,s1
    575a:	00000097          	auipc	ra,0x0
    575e:	f58080e7          	jalr	-168(ra) # 56b2 <putc>
  while(--i >= 0)
    5762:	197d                	addi	s2,s2,-1
    5764:	ff3918e3          	bne	s2,s3,5754 <printint+0x80>
}
    5768:	70e2                	ld	ra,56(sp)
    576a:	7442                	ld	s0,48(sp)
    576c:	74a2                	ld	s1,40(sp)
    576e:	7902                	ld	s2,32(sp)
    5770:	69e2                	ld	s3,24(sp)
    5772:	6121                	addi	sp,sp,64
    5774:	8082                	ret
    x = -xx;
    5776:	40b005bb          	negw	a1,a1
    neg = 1;
    577a:	4885                	li	a7,1
    x = -xx;
    577c:	bf8d                	j	56ee <printint+0x1a>

000000000000577e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    577e:	7119                	addi	sp,sp,-128
    5780:	fc86                	sd	ra,120(sp)
    5782:	f8a2                	sd	s0,112(sp)
    5784:	f4a6                	sd	s1,104(sp)
    5786:	f0ca                	sd	s2,96(sp)
    5788:	ecce                	sd	s3,88(sp)
    578a:	e8d2                	sd	s4,80(sp)
    578c:	e4d6                	sd	s5,72(sp)
    578e:	e0da                	sd	s6,64(sp)
    5790:	fc5e                	sd	s7,56(sp)
    5792:	f862                	sd	s8,48(sp)
    5794:	f466                	sd	s9,40(sp)
    5796:	f06a                	sd	s10,32(sp)
    5798:	ec6e                	sd	s11,24(sp)
    579a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    579c:	0005c903          	lbu	s2,0(a1)
    57a0:	18090f63          	beqz	s2,593e <vprintf+0x1c0>
    57a4:	8aaa                	mv	s5,a0
    57a6:	8b32                	mv	s6,a2
    57a8:	00158493          	addi	s1,a1,1
  state = 0;
    57ac:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    57ae:	02500a13          	li	s4,37
      if(c == 'd'){
    57b2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    57b6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    57ba:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    57be:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    57c2:	00003b97          	auipc	s7,0x3
    57c6:	b1eb8b93          	addi	s7,s7,-1250 # 82e0 <digits>
    57ca:	a839                	j	57e8 <vprintf+0x6a>
        putc(fd, c);
    57cc:	85ca                	mv	a1,s2
    57ce:	8556                	mv	a0,s5
    57d0:	00000097          	auipc	ra,0x0
    57d4:	ee2080e7          	jalr	-286(ra) # 56b2 <putc>
    57d8:	a019                	j	57de <vprintf+0x60>
    } else if(state == '%'){
    57da:	01498f63          	beq	s3,s4,57f8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    57de:	0485                	addi	s1,s1,1
    57e0:	fff4c903          	lbu	s2,-1(s1)
    57e4:	14090d63          	beqz	s2,593e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    57e8:	0009079b          	sext.w	a5,s2
    if(state == 0){
    57ec:	fe0997e3          	bnez	s3,57da <vprintf+0x5c>
      if(c == '%'){
    57f0:	fd479ee3          	bne	a5,s4,57cc <vprintf+0x4e>
        state = '%';
    57f4:	89be                	mv	s3,a5
    57f6:	b7e5                	j	57de <vprintf+0x60>
      if(c == 'd'){
    57f8:	05878063          	beq	a5,s8,5838 <vprintf+0xba>
      } else if(c == 'l') {
    57fc:	05978c63          	beq	a5,s9,5854 <vprintf+0xd6>
      } else if(c == 'x') {
    5800:	07a78863          	beq	a5,s10,5870 <vprintf+0xf2>
      } else if(c == 'p') {
    5804:	09b78463          	beq	a5,s11,588c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5808:	07300713          	li	a4,115
    580c:	0ce78663          	beq	a5,a4,58d8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5810:	06300713          	li	a4,99
    5814:	0ee78e63          	beq	a5,a4,5910 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5818:	11478863          	beq	a5,s4,5928 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    581c:	85d2                	mv	a1,s4
    581e:	8556                	mv	a0,s5
    5820:	00000097          	auipc	ra,0x0
    5824:	e92080e7          	jalr	-366(ra) # 56b2 <putc>
        putc(fd, c);
    5828:	85ca                	mv	a1,s2
    582a:	8556                	mv	a0,s5
    582c:	00000097          	auipc	ra,0x0
    5830:	e86080e7          	jalr	-378(ra) # 56b2 <putc>
      }
      state = 0;
    5834:	4981                	li	s3,0
    5836:	b765                	j	57de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5838:	008b0913          	addi	s2,s6,8
    583c:	4685                	li	a3,1
    583e:	4629                	li	a2,10
    5840:	000b2583          	lw	a1,0(s6)
    5844:	8556                	mv	a0,s5
    5846:	00000097          	auipc	ra,0x0
    584a:	e8e080e7          	jalr	-370(ra) # 56d4 <printint>
    584e:	8b4a                	mv	s6,s2
      state = 0;
    5850:	4981                	li	s3,0
    5852:	b771                	j	57de <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5854:	008b0913          	addi	s2,s6,8
    5858:	4681                	li	a3,0
    585a:	4629                	li	a2,10
    585c:	000b2583          	lw	a1,0(s6)
    5860:	8556                	mv	a0,s5
    5862:	00000097          	auipc	ra,0x0
    5866:	e72080e7          	jalr	-398(ra) # 56d4 <printint>
    586a:	8b4a                	mv	s6,s2
      state = 0;
    586c:	4981                	li	s3,0
    586e:	bf85                	j	57de <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5870:	008b0913          	addi	s2,s6,8
    5874:	4681                	li	a3,0
    5876:	4641                	li	a2,16
    5878:	000b2583          	lw	a1,0(s6)
    587c:	8556                	mv	a0,s5
    587e:	00000097          	auipc	ra,0x0
    5882:	e56080e7          	jalr	-426(ra) # 56d4 <printint>
    5886:	8b4a                	mv	s6,s2
      state = 0;
    5888:	4981                	li	s3,0
    588a:	bf91                	j	57de <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    588c:	008b0793          	addi	a5,s6,8
    5890:	f8f43423          	sd	a5,-120(s0)
    5894:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5898:	03000593          	li	a1,48
    589c:	8556                	mv	a0,s5
    589e:	00000097          	auipc	ra,0x0
    58a2:	e14080e7          	jalr	-492(ra) # 56b2 <putc>
  putc(fd, 'x');
    58a6:	85ea                	mv	a1,s10
    58a8:	8556                	mv	a0,s5
    58aa:	00000097          	auipc	ra,0x0
    58ae:	e08080e7          	jalr	-504(ra) # 56b2 <putc>
    58b2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    58b4:	03c9d793          	srli	a5,s3,0x3c
    58b8:	97de                	add	a5,a5,s7
    58ba:	0007c583          	lbu	a1,0(a5)
    58be:	8556                	mv	a0,s5
    58c0:	00000097          	auipc	ra,0x0
    58c4:	df2080e7          	jalr	-526(ra) # 56b2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    58c8:	0992                	slli	s3,s3,0x4
    58ca:	397d                	addiw	s2,s2,-1
    58cc:	fe0914e3          	bnez	s2,58b4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    58d0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    58d4:	4981                	li	s3,0
    58d6:	b721                	j	57de <vprintf+0x60>
        s = va_arg(ap, char*);
    58d8:	008b0993          	addi	s3,s6,8
    58dc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    58e0:	02090163          	beqz	s2,5902 <vprintf+0x184>
        while(*s != 0){
    58e4:	00094583          	lbu	a1,0(s2)
    58e8:	c9a1                	beqz	a1,5938 <vprintf+0x1ba>
          putc(fd, *s);
    58ea:	8556                	mv	a0,s5
    58ec:	00000097          	auipc	ra,0x0
    58f0:	dc6080e7          	jalr	-570(ra) # 56b2 <putc>
          s++;
    58f4:	0905                	addi	s2,s2,1
        while(*s != 0){
    58f6:	00094583          	lbu	a1,0(s2)
    58fa:	f9e5                	bnez	a1,58ea <vprintf+0x16c>
        s = va_arg(ap, char*);
    58fc:	8b4e                	mv	s6,s3
      state = 0;
    58fe:	4981                	li	s3,0
    5900:	bdf9                	j	57de <vprintf+0x60>
          s = "(null)";
    5902:	00003917          	auipc	s2,0x3
    5906:	9d690913          	addi	s2,s2,-1578 # 82d8 <statistics+0x27ac>
        while(*s != 0){
    590a:	02800593          	li	a1,40
    590e:	bff1                	j	58ea <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5910:	008b0913          	addi	s2,s6,8
    5914:	000b4583          	lbu	a1,0(s6)
    5918:	8556                	mv	a0,s5
    591a:	00000097          	auipc	ra,0x0
    591e:	d98080e7          	jalr	-616(ra) # 56b2 <putc>
    5922:	8b4a                	mv	s6,s2
      state = 0;
    5924:	4981                	li	s3,0
    5926:	bd65                	j	57de <vprintf+0x60>
        putc(fd, c);
    5928:	85d2                	mv	a1,s4
    592a:	8556                	mv	a0,s5
    592c:	00000097          	auipc	ra,0x0
    5930:	d86080e7          	jalr	-634(ra) # 56b2 <putc>
      state = 0;
    5934:	4981                	li	s3,0
    5936:	b565                	j	57de <vprintf+0x60>
        s = va_arg(ap, char*);
    5938:	8b4e                	mv	s6,s3
      state = 0;
    593a:	4981                	li	s3,0
    593c:	b54d                	j	57de <vprintf+0x60>
    }
  }
}
    593e:	70e6                	ld	ra,120(sp)
    5940:	7446                	ld	s0,112(sp)
    5942:	74a6                	ld	s1,104(sp)
    5944:	7906                	ld	s2,96(sp)
    5946:	69e6                	ld	s3,88(sp)
    5948:	6a46                	ld	s4,80(sp)
    594a:	6aa6                	ld	s5,72(sp)
    594c:	6b06                	ld	s6,64(sp)
    594e:	7be2                	ld	s7,56(sp)
    5950:	7c42                	ld	s8,48(sp)
    5952:	7ca2                	ld	s9,40(sp)
    5954:	7d02                	ld	s10,32(sp)
    5956:	6de2                	ld	s11,24(sp)
    5958:	6109                	addi	sp,sp,128
    595a:	8082                	ret

000000000000595c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    595c:	715d                	addi	sp,sp,-80
    595e:	ec06                	sd	ra,24(sp)
    5960:	e822                	sd	s0,16(sp)
    5962:	1000                	addi	s0,sp,32
    5964:	e010                	sd	a2,0(s0)
    5966:	e414                	sd	a3,8(s0)
    5968:	e818                	sd	a4,16(s0)
    596a:	ec1c                	sd	a5,24(s0)
    596c:	03043023          	sd	a6,32(s0)
    5970:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5974:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5978:	8622                	mv	a2,s0
    597a:	00000097          	auipc	ra,0x0
    597e:	e04080e7          	jalr	-508(ra) # 577e <vprintf>
}
    5982:	60e2                	ld	ra,24(sp)
    5984:	6442                	ld	s0,16(sp)
    5986:	6161                	addi	sp,sp,80
    5988:	8082                	ret

000000000000598a <printf>:

void
printf(const char *fmt, ...)
{
    598a:	711d                	addi	sp,sp,-96
    598c:	ec06                	sd	ra,24(sp)
    598e:	e822                	sd	s0,16(sp)
    5990:	1000                	addi	s0,sp,32
    5992:	e40c                	sd	a1,8(s0)
    5994:	e810                	sd	a2,16(s0)
    5996:	ec14                	sd	a3,24(s0)
    5998:	f018                	sd	a4,32(s0)
    599a:	f41c                	sd	a5,40(s0)
    599c:	03043823          	sd	a6,48(s0)
    59a0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    59a4:	00840613          	addi	a2,s0,8
    59a8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    59ac:	85aa                	mv	a1,a0
    59ae:	4505                	li	a0,1
    59b0:	00000097          	auipc	ra,0x0
    59b4:	dce080e7          	jalr	-562(ra) # 577e <vprintf>
}
    59b8:	60e2                	ld	ra,24(sp)
    59ba:	6442                	ld	s0,16(sp)
    59bc:	6125                	addi	sp,sp,96
    59be:	8082                	ret

00000000000059c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    59c0:	1141                	addi	sp,sp,-16
    59c2:	e422                	sd	s0,8(sp)
    59c4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    59c6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    59ca:	00003797          	auipc	a5,0x3
    59ce:	9667b783          	ld	a5,-1690(a5) # 8330 <freep>
    59d2:	a805                	j	5a02 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    59d4:	4618                	lw	a4,8(a2)
    59d6:	9db9                	addw	a1,a1,a4
    59d8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    59dc:	6398                	ld	a4,0(a5)
    59de:	6318                	ld	a4,0(a4)
    59e0:	fee53823          	sd	a4,-16(a0)
    59e4:	a091                	j	5a28 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    59e6:	ff852703          	lw	a4,-8(a0)
    59ea:	9e39                	addw	a2,a2,a4
    59ec:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    59ee:	ff053703          	ld	a4,-16(a0)
    59f2:	e398                	sd	a4,0(a5)
    59f4:	a099                	j	5a3a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    59f6:	6398                	ld	a4,0(a5)
    59f8:	00e7e463          	bltu	a5,a4,5a00 <free+0x40>
    59fc:	00e6ea63          	bltu	a3,a4,5a10 <free+0x50>
{
    5a00:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a02:	fed7fae3          	bgeu	a5,a3,59f6 <free+0x36>
    5a06:	6398                	ld	a4,0(a5)
    5a08:	00e6e463          	bltu	a3,a4,5a10 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a0c:	fee7eae3          	bltu	a5,a4,5a00 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5a10:	ff852583          	lw	a1,-8(a0)
    5a14:	6390                	ld	a2,0(a5)
    5a16:	02059713          	slli	a4,a1,0x20
    5a1a:	9301                	srli	a4,a4,0x20
    5a1c:	0712                	slli	a4,a4,0x4
    5a1e:	9736                	add	a4,a4,a3
    5a20:	fae60ae3          	beq	a2,a4,59d4 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5a24:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5a28:	4790                	lw	a2,8(a5)
    5a2a:	02061713          	slli	a4,a2,0x20
    5a2e:	9301                	srli	a4,a4,0x20
    5a30:	0712                	slli	a4,a4,0x4
    5a32:	973e                	add	a4,a4,a5
    5a34:	fae689e3          	beq	a3,a4,59e6 <free+0x26>
  } else
    p->s.ptr = bp;
    5a38:	e394                	sd	a3,0(a5)
  freep = p;
    5a3a:	00003717          	auipc	a4,0x3
    5a3e:	8ef73b23          	sd	a5,-1802(a4) # 8330 <freep>
}
    5a42:	6422                	ld	s0,8(sp)
    5a44:	0141                	addi	sp,sp,16
    5a46:	8082                	ret

0000000000005a48 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5a48:	7139                	addi	sp,sp,-64
    5a4a:	fc06                	sd	ra,56(sp)
    5a4c:	f822                	sd	s0,48(sp)
    5a4e:	f426                	sd	s1,40(sp)
    5a50:	f04a                	sd	s2,32(sp)
    5a52:	ec4e                	sd	s3,24(sp)
    5a54:	e852                	sd	s4,16(sp)
    5a56:	e456                	sd	s5,8(sp)
    5a58:	e05a                	sd	s6,0(sp)
    5a5a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5a5c:	02051493          	slli	s1,a0,0x20
    5a60:	9081                	srli	s1,s1,0x20
    5a62:	04bd                	addi	s1,s1,15
    5a64:	8091                	srli	s1,s1,0x4
    5a66:	0014899b          	addiw	s3,s1,1
    5a6a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5a6c:	00003517          	auipc	a0,0x3
    5a70:	8c453503          	ld	a0,-1852(a0) # 8330 <freep>
    5a74:	c515                	beqz	a0,5aa0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5a76:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5a78:	4798                	lw	a4,8(a5)
    5a7a:	02977f63          	bgeu	a4,s1,5ab8 <malloc+0x70>
    5a7e:	8a4e                	mv	s4,s3
    5a80:	0009871b          	sext.w	a4,s3
    5a84:	6685                	lui	a3,0x1
    5a86:	00d77363          	bgeu	a4,a3,5a8c <malloc+0x44>
    5a8a:	6a05                	lui	s4,0x1
    5a8c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5a90:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5a94:	00003917          	auipc	s2,0x3
    5a98:	89c90913          	addi	s2,s2,-1892 # 8330 <freep>
  if(p == (char*)-1)
    5a9c:	5afd                	li	s5,-1
    5a9e:	a88d                	j	5b10 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5aa0:	00009797          	auipc	a5,0x9
    5aa4:	0b078793          	addi	a5,a5,176 # eb50 <base>
    5aa8:	00003717          	auipc	a4,0x3
    5aac:	88f73423          	sd	a5,-1912(a4) # 8330 <freep>
    5ab0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5ab2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5ab6:	b7e1                	j	5a7e <malloc+0x36>
      if(p->s.size == nunits)
    5ab8:	02e48b63          	beq	s1,a4,5aee <malloc+0xa6>
        p->s.size -= nunits;
    5abc:	4137073b          	subw	a4,a4,s3
    5ac0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5ac2:	1702                	slli	a4,a4,0x20
    5ac4:	9301                	srli	a4,a4,0x20
    5ac6:	0712                	slli	a4,a4,0x4
    5ac8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5aca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5ace:	00003717          	auipc	a4,0x3
    5ad2:	86a73123          	sd	a0,-1950(a4) # 8330 <freep>
      return (void*)(p + 1);
    5ad6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5ada:	70e2                	ld	ra,56(sp)
    5adc:	7442                	ld	s0,48(sp)
    5ade:	74a2                	ld	s1,40(sp)
    5ae0:	7902                	ld	s2,32(sp)
    5ae2:	69e2                	ld	s3,24(sp)
    5ae4:	6a42                	ld	s4,16(sp)
    5ae6:	6aa2                	ld	s5,8(sp)
    5ae8:	6b02                	ld	s6,0(sp)
    5aea:	6121                	addi	sp,sp,64
    5aec:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5aee:	6398                	ld	a4,0(a5)
    5af0:	e118                	sd	a4,0(a0)
    5af2:	bff1                	j	5ace <malloc+0x86>
  hp->s.size = nu;
    5af4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5af8:	0541                	addi	a0,a0,16
    5afa:	00000097          	auipc	ra,0x0
    5afe:	ec6080e7          	jalr	-314(ra) # 59c0 <free>
  return freep;
    5b02:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5b06:	d971                	beqz	a0,5ada <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5b08:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5b0a:	4798                	lw	a4,8(a5)
    5b0c:	fa9776e3          	bgeu	a4,s1,5ab8 <malloc+0x70>
    if(p == freep)
    5b10:	00093703          	ld	a4,0(s2)
    5b14:	853e                	mv	a0,a5
    5b16:	fef719e3          	bne	a4,a5,5b08 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    5b1a:	8552                	mv	a0,s4
    5b1c:	00000097          	auipc	ra,0x0
    5b20:	b7e080e7          	jalr	-1154(ra) # 569a <sbrk>
  if(p == (char*)-1)
    5b24:	fd5518e3          	bne	a0,s5,5af4 <malloc+0xac>
        return 0;
    5b28:	4501                	li	a0,0
    5b2a:	bf45                	j	5ada <malloc+0x92>

0000000000005b2c <statistics>:
#include "kernel/fcntl.h"
#include "user/user.h"

int
statistics(void *buf, int sz)
{
    5b2c:	7179                	addi	sp,sp,-48
    5b2e:	f406                	sd	ra,40(sp)
    5b30:	f022                	sd	s0,32(sp)
    5b32:	ec26                	sd	s1,24(sp)
    5b34:	e84a                	sd	s2,16(sp)
    5b36:	e44e                	sd	s3,8(sp)
    5b38:	e052                	sd	s4,0(sp)
    5b3a:	1800                	addi	s0,sp,48
    5b3c:	8a2a                	mv	s4,a0
    5b3e:	892e                	mv	s2,a1
  int fd, i, n;
  
  fd = open("statistics", O_RDONLY);
    5b40:	4581                	li	a1,0
    5b42:	00002517          	auipc	a0,0x2
    5b46:	7b650513          	addi	a0,a0,1974 # 82f8 <digits+0x18>
    5b4a:	00000097          	auipc	ra,0x0
    5b4e:	b08080e7          	jalr	-1272(ra) # 5652 <open>
  if(fd < 0) {
    5b52:	04054263          	bltz	a0,5b96 <statistics+0x6a>
    5b56:	89aa                	mv	s3,a0
      fprintf(2, "stats: open failed\n");
      exit(1);
  }
  for (i = 0; i < sz; ) {
    5b58:	4481                	li	s1,0
    5b5a:	03205063          	blez	s2,5b7a <statistics+0x4e>
    if ((n = read(fd, buf+i, sz-i)) < 0) {
    5b5e:	4099063b          	subw	a2,s2,s1
    5b62:	009a05b3          	add	a1,s4,s1
    5b66:	854e                	mv	a0,s3
    5b68:	00000097          	auipc	ra,0x0
    5b6c:	ac2080e7          	jalr	-1342(ra) # 562a <read>
    5b70:	00054563          	bltz	a0,5b7a <statistics+0x4e>
      break;
    }
    i += n;
    5b74:	9ca9                	addw	s1,s1,a0
  for (i = 0; i < sz; ) {
    5b76:	ff24c4e3          	blt	s1,s2,5b5e <statistics+0x32>
  }
  close(fd);
    5b7a:	854e                	mv	a0,s3
    5b7c:	00000097          	auipc	ra,0x0
    5b80:	abe080e7          	jalr	-1346(ra) # 563a <close>
  return i;
}
    5b84:	8526                	mv	a0,s1
    5b86:	70a2                	ld	ra,40(sp)
    5b88:	7402                	ld	s0,32(sp)
    5b8a:	64e2                	ld	s1,24(sp)
    5b8c:	6942                	ld	s2,16(sp)
    5b8e:	69a2                	ld	s3,8(sp)
    5b90:	6a02                	ld	s4,0(sp)
    5b92:	6145                	addi	sp,sp,48
    5b94:	8082                	ret
      fprintf(2, "stats: open failed\n");
    5b96:	00002597          	auipc	a1,0x2
    5b9a:	77258593          	addi	a1,a1,1906 # 8308 <digits+0x28>
    5b9e:	4509                	li	a0,2
    5ba0:	00000097          	auipc	ra,0x0
    5ba4:	dbc080e7          	jalr	-580(ra) # 595c <fprintf>
      exit(1);
    5ba8:	4505                	li	a0,1
    5baa:	00000097          	auipc	ra,0x0
    5bae:	a68080e7          	jalr	-1432(ra) # 5612 <exit>
