
user/_uthread:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_init>:
struct thread *current_thread;
extern void thread_switch(uint64, uint64);
              
void 
thread_init(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
   8:	00001517          	auipc	a0,0x1
   c:	d6050513          	addi	a0,a0,-672 # d68 <all_thread>
  10:	00001797          	auipc	a5,0x1
  14:	d4a7b423          	sd	a0,-696(a5) # d58 <current_thread>
  current_thread->state = RUNNING;
  18:	4785                	li	a5,1
  1a:	d93c                	sw	a5,112(a0)
  thread_switch((uint64)(&current_thread->context),(uint64)(&current_thread->context));
  1c:	85aa                	mv	a1,a0
  1e:	00000097          	auipc	ra,0x0
  22:	3ca080e7          	jalr	970(ra) # 3e8 <thread_switch>
}
  26:	60a2                	ld	ra,8(sp)
  28:	6402                	ld	s0,0(sp)
  2a:	0141                	addi	sp,sp,16
  2c:	8082                	ret

000000000000002e <thread_schedule>:

void 
thread_schedule(void)
{
  2e:	1141                	addi	sp,sp,-16
  30:	e406                	sd	ra,8(sp)
  32:	e022                	sd	s0,0(sp)
  34:	0800                	addi	s0,sp,16
  struct thread *t, *next_thread;

  /* Find another runnable thread. */
  next_thread = 0;
  t = current_thread + 1;
  36:	00001517          	auipc	a0,0x1
  3a:	d2253503          	ld	a0,-734(a0) # d58 <current_thread>
  3e:	6589                	lui	a1,0x2
  40:	07858593          	addi	a1,a1,120 # 2078 <__global_pointer$+0xb3f>
  44:	95aa                	add	a1,a1,a0
  46:	4791                	li	a5,4
  for(int i = 0; i < MAX_THREAD; i++){
    if(t >= all_thread + MAX_THREAD)
  48:	00009817          	auipc	a6,0x9
  4c:	f0080813          	addi	a6,a6,-256 # 8f48 <base>
      t = all_thread;
    //printf("%d %d ",(int)(t-&all_thread[0]),t->state);    
    if(t->state == RUNNABLE) {
  50:	4609                	li	a2,2
      next_thread = t;
      break;
    }
    t = t + 1;
  52:	6689                	lui	a3,0x2
  54:	07868693          	addi	a3,a3,120 # 2078 <__global_pointer$+0xb3f>
  58:	a039                	j	66 <thread_schedule+0x38>
    if(t->state == RUNNABLE) {
  5a:	59b8                	lw	a4,112(a1)
  5c:	02c70963          	beq	a4,a2,8e <thread_schedule+0x60>
    t = t + 1;
  60:	95b6                	add	a1,a1,a3
  for(int i = 0; i < MAX_THREAD; i++){
  62:	37fd                	addiw	a5,a5,-1
  64:	cb81                	beqz	a5,74 <thread_schedule+0x46>
    if(t >= all_thread + MAX_THREAD)
  66:	ff05eae3          	bltu	a1,a6,5a <thread_schedule+0x2c>
      t = all_thread;
  6a:	00001597          	auipc	a1,0x1
  6e:	cfe58593          	addi	a1,a1,-770 # d68 <all_thread>
  72:	b7e5                	j	5a <thread_schedule+0x2c>
  }

  if (next_thread == 0) {
    printf("thread_schedule: no runnable threads\n");
  74:	00001517          	auipc	a0,0x1
  78:	b5450513          	addi	a0,a0,-1196 # bc8 <malloc+0xea>
  7c:	00001097          	auipc	ra,0x1
  80:	9aa080e7          	jalr	-1622(ra) # a26 <printf>
    exit(-1);
  84:	557d                	li	a0,-1
  86:	00000097          	auipc	ra,0x0
  8a:	638080e7          	jalr	1592(ra) # 6be <exit>
  }

  //printf("%d",(int)(next_thread-&all_thread[0]));

  if (current_thread != next_thread) {         /* switch threads?  */
  8e:	00b50c63          	beq	a0,a1,a6 <thread_schedule+0x78>
    next_thread->state = RUNNING;
  92:	4785                	li	a5,1
  94:	d9bc                	sw	a5,112(a1)
    t = current_thread;
    current_thread = next_thread;
  96:	00001797          	auipc	a5,0x1
  9a:	ccb7b123          	sd	a1,-830(a5) # d58 <current_thread>
    /* YOUR CODE HERE
     * Invoke thread_switch to switch from t to next_thread:
     * thread_switch(??, ??);
     */
    //printf("%ld %ld\n",t->context.ra,next_thread->context.ra);
    thread_switch((uint64)(&t->context),(uint64)(&next_thread->context));
  9e:	00000097          	auipc	ra,0x0
  a2:	34a080e7          	jalr	842(ra) # 3e8 <thread_switch>

  } else
    next_thread = 0;
}
  a6:	60a2                	ld	ra,8(sp)
  a8:	6402                	ld	s0,0(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret

00000000000000ae <thread_create>:

void 
thread_create(void (*func)())
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e422                	sd	s0,8(sp)
  b2:	0800                	addi	s0,sp,16
  struct thread *t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  b4:	00001797          	auipc	a5,0x1
  b8:	cb478793          	addi	a5,a5,-844 # d68 <all_thread>
  bc:	6689                	lui	a3,0x2
  be:	07868693          	addi	a3,a3,120 # 2078 <__global_pointer$+0xb3f>
  c2:	00009617          	auipc	a2,0x9
  c6:	e8660613          	addi	a2,a2,-378 # 8f48 <base>
    if (t->state == FREE) break;
  ca:	5bb8                	lw	a4,112(a5)
  cc:	c701                	beqz	a4,d4 <thread_create+0x26>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  ce:	97b6                	add	a5,a5,a3
  d0:	fec79de3          	bne	a5,a2,ca <thread_create+0x1c>
  }
  t->state = RUNNABLE;
  d4:	4709                	li	a4,2
  d6:	dbb8                	sw	a4,112(a5)
  // YOUR CODE HERE
  t->context.ra=(uint64)func;
  d8:	e788                	sd	a0,8(a5)
  t->context.sp=(uint64)(t->stack+STACK_SIZE-1);
  da:	6709                	lui	a4,0x2
  dc:	07370713          	addi	a4,a4,115 # 2073 <__global_pointer$+0xb3a>
  e0:	973e                	add	a4,a4,a5
  e2:	e398                	sd	a4,0(a5)
}
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret

00000000000000ea <thread_yield>:

void 
thread_yield(void)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e406                	sd	ra,8(sp)
  ee:	e022                	sd	s0,0(sp)
  f0:	0800                	addi	s0,sp,16
  current_thread->state = RUNNABLE;
  f2:	00001797          	auipc	a5,0x1
  f6:	c667b783          	ld	a5,-922(a5) # d58 <current_thread>
  fa:	4709                	li	a4,2
  fc:	dbb8                	sw	a4,112(a5)
  thread_schedule();
  fe:	00000097          	auipc	ra,0x0
 102:	f30080e7          	jalr	-208(ra) # 2e <thread_schedule>
}
 106:	60a2                	ld	ra,8(sp)
 108:	6402                	ld	s0,0(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret

000000000000010e <thread_a>:
volatile int a_started, b_started, c_started;
volatile int a_n, b_n, c_n;

void 
thread_a(void)
{
 10e:	7179                	addi	sp,sp,-48
 110:	f406                	sd	ra,40(sp)
 112:	f022                	sd	s0,32(sp)
 114:	ec26                	sd	s1,24(sp)
 116:	e84a                	sd	s2,16(sp)
 118:	e44e                	sd	s3,8(sp)
 11a:	e052                	sd	s4,0(sp)
 11c:	1800                	addi	s0,sp,48
  int i;
  printf("thread_a started\n");
 11e:	00001517          	auipc	a0,0x1
 122:	ad250513          	addi	a0,a0,-1326 # bf0 <malloc+0x112>
 126:	00001097          	auipc	ra,0x1
 12a:	900080e7          	jalr	-1792(ra) # a26 <printf>
  a_started = 1;
 12e:	4785                	li	a5,1
 130:	00001717          	auipc	a4,0x1
 134:	c2f72223          	sw	a5,-988(a4) # d54 <a_started>
  while(b_started == 0 || c_started == 0)
 138:	00001497          	auipc	s1,0x1
 13c:	c1848493          	addi	s1,s1,-1000 # d50 <b_started>
 140:	00001917          	auipc	s2,0x1
 144:	c0c90913          	addi	s2,s2,-1012 # d4c <c_started>
 148:	a029                	j	152 <thread_a+0x44>
    thread_yield();
 14a:	00000097          	auipc	ra,0x0
 14e:	fa0080e7          	jalr	-96(ra) # ea <thread_yield>
  while(b_started == 0 || c_started == 0)
 152:	409c                	lw	a5,0(s1)
 154:	2781                	sext.w	a5,a5
 156:	dbf5                	beqz	a5,14a <thread_a+0x3c>
 158:	00092783          	lw	a5,0(s2)
 15c:	2781                	sext.w	a5,a5
 15e:	d7f5                	beqz	a5,14a <thread_a+0x3c>
  
  for (i = 0; i < 100; i++) {
 160:	4481                	li	s1,0
    printf("thread_a %d\n", i);
 162:	00001a17          	auipc	s4,0x1
 166:	aa6a0a13          	addi	s4,s4,-1370 # c08 <malloc+0x12a>
    a_n += 1;
 16a:	00001917          	auipc	s2,0x1
 16e:	bde90913          	addi	s2,s2,-1058 # d48 <a_n>
  for (i = 0; i < 100; i++) {
 172:	06400993          	li	s3,100
    printf("thread_a %d\n", i);
 176:	85a6                	mv	a1,s1
 178:	8552                	mv	a0,s4
 17a:	00001097          	auipc	ra,0x1
 17e:	8ac080e7          	jalr	-1876(ra) # a26 <printf>
    a_n += 1;
 182:	00092783          	lw	a5,0(s2)
 186:	2785                	addiw	a5,a5,1
 188:	00f92023          	sw	a5,0(s2)
    thread_yield();
 18c:	00000097          	auipc	ra,0x0
 190:	f5e080e7          	jalr	-162(ra) # ea <thread_yield>
  for (i = 0; i < 100; i++) {
 194:	2485                	addiw	s1,s1,1
 196:	ff3490e3          	bne	s1,s3,176 <thread_a+0x68>
  }
  printf("thread_a: exit after %d\n", a_n);
 19a:	00001597          	auipc	a1,0x1
 19e:	bae5a583          	lw	a1,-1106(a1) # d48 <a_n>
 1a2:	00001517          	auipc	a0,0x1
 1a6:	a7650513          	addi	a0,a0,-1418 # c18 <malloc+0x13a>
 1aa:	00001097          	auipc	ra,0x1
 1ae:	87c080e7          	jalr	-1924(ra) # a26 <printf>

  current_thread->state = FREE;
 1b2:	00001797          	auipc	a5,0x1
 1b6:	ba67b783          	ld	a5,-1114(a5) # d58 <current_thread>
 1ba:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 1be:	00000097          	auipc	ra,0x0
 1c2:	e70080e7          	jalr	-400(ra) # 2e <thread_schedule>
}
 1c6:	70a2                	ld	ra,40(sp)
 1c8:	7402                	ld	s0,32(sp)
 1ca:	64e2                	ld	s1,24(sp)
 1cc:	6942                	ld	s2,16(sp)
 1ce:	69a2                	ld	s3,8(sp)
 1d0:	6a02                	ld	s4,0(sp)
 1d2:	6145                	addi	sp,sp,48
 1d4:	8082                	ret

00000000000001d6 <thread_b>:

void 
thread_b(void)
{
 1d6:	7179                	addi	sp,sp,-48
 1d8:	f406                	sd	ra,40(sp)
 1da:	f022                	sd	s0,32(sp)
 1dc:	ec26                	sd	s1,24(sp)
 1de:	e84a                	sd	s2,16(sp)
 1e0:	e44e                	sd	s3,8(sp)
 1e2:	e052                	sd	s4,0(sp)
 1e4:	1800                	addi	s0,sp,48
  int i;
  printf("thread_b started\n");
 1e6:	00001517          	auipc	a0,0x1
 1ea:	a5250513          	addi	a0,a0,-1454 # c38 <malloc+0x15a>
 1ee:	00001097          	auipc	ra,0x1
 1f2:	838080e7          	jalr	-1992(ra) # a26 <printf>
  b_started = 1;
 1f6:	4785                	li	a5,1
 1f8:	00001717          	auipc	a4,0x1
 1fc:	b4f72c23          	sw	a5,-1192(a4) # d50 <b_started>
  while(a_started == 0 || c_started == 0)
 200:	00001497          	auipc	s1,0x1
 204:	b5448493          	addi	s1,s1,-1196 # d54 <a_started>
 208:	00001917          	auipc	s2,0x1
 20c:	b4490913          	addi	s2,s2,-1212 # d4c <c_started>
 210:	a029                	j	21a <thread_b+0x44>
    thread_yield();
 212:	00000097          	auipc	ra,0x0
 216:	ed8080e7          	jalr	-296(ra) # ea <thread_yield>
  while(a_started == 0 || c_started == 0)
 21a:	409c                	lw	a5,0(s1)
 21c:	2781                	sext.w	a5,a5
 21e:	dbf5                	beqz	a5,212 <thread_b+0x3c>
 220:	00092783          	lw	a5,0(s2)
 224:	2781                	sext.w	a5,a5
 226:	d7f5                	beqz	a5,212 <thread_b+0x3c>
  
  for (i = 0; i < 100; i++) {
 228:	4481                	li	s1,0
    printf("thread_b %d\n", i);
 22a:	00001a17          	auipc	s4,0x1
 22e:	a26a0a13          	addi	s4,s4,-1498 # c50 <malloc+0x172>
    b_n += 1;
 232:	00001917          	auipc	s2,0x1
 236:	b1290913          	addi	s2,s2,-1262 # d44 <b_n>
  for (i = 0; i < 100; i++) {
 23a:	06400993          	li	s3,100
    printf("thread_b %d\n", i);
 23e:	85a6                	mv	a1,s1
 240:	8552                	mv	a0,s4
 242:	00000097          	auipc	ra,0x0
 246:	7e4080e7          	jalr	2020(ra) # a26 <printf>
    b_n += 1;
 24a:	00092783          	lw	a5,0(s2)
 24e:	2785                	addiw	a5,a5,1
 250:	00f92023          	sw	a5,0(s2)
    thread_yield();
 254:	00000097          	auipc	ra,0x0
 258:	e96080e7          	jalr	-362(ra) # ea <thread_yield>
  for (i = 0; i < 100; i++) {
 25c:	2485                	addiw	s1,s1,1
 25e:	ff3490e3          	bne	s1,s3,23e <thread_b+0x68>
  }
  printf("thread_b: exit after %d\n", b_n);
 262:	00001597          	auipc	a1,0x1
 266:	ae25a583          	lw	a1,-1310(a1) # d44 <b_n>
 26a:	00001517          	auipc	a0,0x1
 26e:	9f650513          	addi	a0,a0,-1546 # c60 <malloc+0x182>
 272:	00000097          	auipc	ra,0x0
 276:	7b4080e7          	jalr	1972(ra) # a26 <printf>

  current_thread->state = FREE;
 27a:	00001797          	auipc	a5,0x1
 27e:	ade7b783          	ld	a5,-1314(a5) # d58 <current_thread>
 282:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 286:	00000097          	auipc	ra,0x0
 28a:	da8080e7          	jalr	-600(ra) # 2e <thread_schedule>
}
 28e:	70a2                	ld	ra,40(sp)
 290:	7402                	ld	s0,32(sp)
 292:	64e2                	ld	s1,24(sp)
 294:	6942                	ld	s2,16(sp)
 296:	69a2                	ld	s3,8(sp)
 298:	6a02                	ld	s4,0(sp)
 29a:	6145                	addi	sp,sp,48
 29c:	8082                	ret

000000000000029e <thread_c>:

void 
thread_c(void)
{
 29e:	7179                	addi	sp,sp,-48
 2a0:	f406                	sd	ra,40(sp)
 2a2:	f022                	sd	s0,32(sp)
 2a4:	ec26                	sd	s1,24(sp)
 2a6:	e84a                	sd	s2,16(sp)
 2a8:	e44e                	sd	s3,8(sp)
 2aa:	e052                	sd	s4,0(sp)
 2ac:	1800                	addi	s0,sp,48
  int i;
  printf("thread_c started\n");
 2ae:	00001517          	auipc	a0,0x1
 2b2:	9d250513          	addi	a0,a0,-1582 # c80 <malloc+0x1a2>
 2b6:	00000097          	auipc	ra,0x0
 2ba:	770080e7          	jalr	1904(ra) # a26 <printf>
  c_started = 1;
 2be:	4785                	li	a5,1
 2c0:	00001717          	auipc	a4,0x1
 2c4:	a8f72623          	sw	a5,-1396(a4) # d4c <c_started>
  while(a_started == 0 || b_started == 0)
 2c8:	00001497          	auipc	s1,0x1
 2cc:	a8c48493          	addi	s1,s1,-1396 # d54 <a_started>
 2d0:	00001917          	auipc	s2,0x1
 2d4:	a8090913          	addi	s2,s2,-1408 # d50 <b_started>
 2d8:	a029                	j	2e2 <thread_c+0x44>
    thread_yield();
 2da:	00000097          	auipc	ra,0x0
 2de:	e10080e7          	jalr	-496(ra) # ea <thread_yield>
  while(a_started == 0 || b_started == 0)
 2e2:	409c                	lw	a5,0(s1)
 2e4:	2781                	sext.w	a5,a5
 2e6:	dbf5                	beqz	a5,2da <thread_c+0x3c>
 2e8:	00092783          	lw	a5,0(s2)
 2ec:	2781                	sext.w	a5,a5
 2ee:	d7f5                	beqz	a5,2da <thread_c+0x3c>
  
  for (i = 0; i < 100; i++) {
 2f0:	4481                	li	s1,0
    printf("thread_c %d\n", i);
 2f2:	00001a17          	auipc	s4,0x1
 2f6:	9a6a0a13          	addi	s4,s4,-1626 # c98 <malloc+0x1ba>
    c_n += 1;
 2fa:	00001917          	auipc	s2,0x1
 2fe:	a4690913          	addi	s2,s2,-1466 # d40 <c_n>
  for (i = 0; i < 100; i++) {
 302:	06400993          	li	s3,100
    printf("thread_c %d\n", i);
 306:	85a6                	mv	a1,s1
 308:	8552                	mv	a0,s4
 30a:	00000097          	auipc	ra,0x0
 30e:	71c080e7          	jalr	1820(ra) # a26 <printf>
    c_n += 1;
 312:	00092783          	lw	a5,0(s2)
 316:	2785                	addiw	a5,a5,1
 318:	00f92023          	sw	a5,0(s2)
    thread_yield();
 31c:	00000097          	auipc	ra,0x0
 320:	dce080e7          	jalr	-562(ra) # ea <thread_yield>
  for (i = 0; i < 100; i++) {
 324:	2485                	addiw	s1,s1,1
 326:	ff3490e3          	bne	s1,s3,306 <thread_c+0x68>
  }
  printf("thread_c: exit after %d\n", c_n);
 32a:	00001597          	auipc	a1,0x1
 32e:	a165a583          	lw	a1,-1514(a1) # d40 <c_n>
 332:	00001517          	auipc	a0,0x1
 336:	97650513          	addi	a0,a0,-1674 # ca8 <malloc+0x1ca>
 33a:	00000097          	auipc	ra,0x0
 33e:	6ec080e7          	jalr	1772(ra) # a26 <printf>

  current_thread->state = FREE;
 342:	00001797          	auipc	a5,0x1
 346:	a167b783          	ld	a5,-1514(a5) # d58 <current_thread>
 34a:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 34e:	00000097          	auipc	ra,0x0
 352:	ce0080e7          	jalr	-800(ra) # 2e <thread_schedule>
}
 356:	70a2                	ld	ra,40(sp)
 358:	7402                	ld	s0,32(sp)
 35a:	64e2                	ld	s1,24(sp)
 35c:	6942                	ld	s2,16(sp)
 35e:	69a2                	ld	s3,8(sp)
 360:	6a02                	ld	s4,0(sp)
 362:	6145                	addi	sp,sp,48
 364:	8082                	ret

0000000000000366 <main>:

int 
main(int argc, char *argv[]) 
{
 366:	1141                	addi	sp,sp,-16
 368:	e406                	sd	ra,8(sp)
 36a:	e022                	sd	s0,0(sp)
 36c:	0800                	addi	s0,sp,16
  a_started = b_started = c_started = 0;
 36e:	00001797          	auipc	a5,0x1
 372:	9c07af23          	sw	zero,-1570(a5) # d4c <c_started>
 376:	00001797          	auipc	a5,0x1
 37a:	9c07ad23          	sw	zero,-1574(a5) # d50 <b_started>
 37e:	00001797          	auipc	a5,0x1
 382:	9c07ab23          	sw	zero,-1578(a5) # d54 <a_started>
  a_n = b_n = c_n = 0;
 386:	00001797          	auipc	a5,0x1
 38a:	9a07ad23          	sw	zero,-1606(a5) # d40 <c_n>
 38e:	00001797          	auipc	a5,0x1
 392:	9a07ab23          	sw	zero,-1610(a5) # d44 <b_n>
 396:	00001797          	auipc	a5,0x1
 39a:	9a07a923          	sw	zero,-1614(a5) # d48 <a_n>
  thread_init();
 39e:	00000097          	auipc	ra,0x0
 3a2:	c62080e7          	jalr	-926(ra) # 0 <thread_init>
  thread_create(thread_a);
 3a6:	00000517          	auipc	a0,0x0
 3aa:	d6850513          	addi	a0,a0,-664 # 10e <thread_a>
 3ae:	00000097          	auipc	ra,0x0
 3b2:	d00080e7          	jalr	-768(ra) # ae <thread_create>
  thread_create(thread_b);
 3b6:	00000517          	auipc	a0,0x0
 3ba:	e2050513          	addi	a0,a0,-480 # 1d6 <thread_b>
 3be:	00000097          	auipc	ra,0x0
 3c2:	cf0080e7          	jalr	-784(ra) # ae <thread_create>
  thread_create(thread_c);
 3c6:	00000517          	auipc	a0,0x0
 3ca:	ed850513          	addi	a0,a0,-296 # 29e <thread_c>
 3ce:	00000097          	auipc	ra,0x0
 3d2:	ce0080e7          	jalr	-800(ra) # ae <thread_create>
  thread_schedule();
 3d6:	00000097          	auipc	ra,0x0
 3da:	c58080e7          	jalr	-936(ra) # 2e <thread_schedule>
  exit(0);
 3de:	4501                	li	a0,0
 3e0:	00000097          	auipc	ra,0x0
 3e4:	2de080e7          	jalr	734(ra) # 6be <exit>

00000000000003e8 <thread_switch>:
         */

.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
        sd sp, 0(a0)
 3e8:	00253023          	sd	sp,0(a0)
        sd ra, 8(a0)
 3ec:	00153423          	sd	ra,8(a0)
        sd s0, 16(a0)
 3f0:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
 3f2:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
 3f4:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
 3f8:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
 3fc:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
 400:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
 404:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
 408:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
 40c:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
 410:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
 414:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
 418:	07b53423          	sd	s11,104(a0)

        ld sp, 0(a1)
 41c:	0005b103          	ld	sp,0(a1)
        ld ra, 8(a1)
 420:	0085b083          	ld	ra,8(a1)
        ld s0, 16(a1)
 424:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
 426:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
 428:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
 42c:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
 430:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
 434:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
 438:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
 43c:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
 440:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
 444:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
 448:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
 44c:	0685bd83          	ld	s11,104(a1)
        

		ret    /* return to ra */
 450:	8082                	ret

0000000000000452 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 452:	1141                	addi	sp,sp,-16
 454:	e422                	sd	s0,8(sp)
 456:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 458:	87aa                	mv	a5,a0
 45a:	0585                	addi	a1,a1,1
 45c:	0785                	addi	a5,a5,1
 45e:	fff5c703          	lbu	a4,-1(a1)
 462:	fee78fa3          	sb	a4,-1(a5)
 466:	fb75                	bnez	a4,45a <strcpy+0x8>
    ;
  return os;
}
 468:	6422                	ld	s0,8(sp)
 46a:	0141                	addi	sp,sp,16
 46c:	8082                	ret

000000000000046e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e422                	sd	s0,8(sp)
 472:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 474:	00054783          	lbu	a5,0(a0)
 478:	cb91                	beqz	a5,48c <strcmp+0x1e>
 47a:	0005c703          	lbu	a4,0(a1)
 47e:	00f71763          	bne	a4,a5,48c <strcmp+0x1e>
    p++, q++;
 482:	0505                	addi	a0,a0,1
 484:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 486:	00054783          	lbu	a5,0(a0)
 48a:	fbe5                	bnez	a5,47a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 48c:	0005c503          	lbu	a0,0(a1)
}
 490:	40a7853b          	subw	a0,a5,a0
 494:	6422                	ld	s0,8(sp)
 496:	0141                	addi	sp,sp,16
 498:	8082                	ret

000000000000049a <strlen>:

uint
strlen(const char *s)
{
 49a:	1141                	addi	sp,sp,-16
 49c:	e422                	sd	s0,8(sp)
 49e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4a0:	00054783          	lbu	a5,0(a0)
 4a4:	cf91                	beqz	a5,4c0 <strlen+0x26>
 4a6:	0505                	addi	a0,a0,1
 4a8:	87aa                	mv	a5,a0
 4aa:	86be                	mv	a3,a5
 4ac:	0785                	addi	a5,a5,1
 4ae:	fff7c703          	lbu	a4,-1(a5)
 4b2:	ff65                	bnez	a4,4aa <strlen+0x10>
 4b4:	40a6853b          	subw	a0,a3,a0
 4b8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 4ba:	6422                	ld	s0,8(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret
  for(n = 0; s[n]; n++)
 4c0:	4501                	li	a0,0
 4c2:	bfe5                	j	4ba <strlen+0x20>

00000000000004c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4c4:	1141                	addi	sp,sp,-16
 4c6:	e422                	sd	s0,8(sp)
 4c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4ca:	ca19                	beqz	a2,4e0 <memset+0x1c>
 4cc:	87aa                	mv	a5,a0
 4ce:	1602                	slli	a2,a2,0x20
 4d0:	9201                	srli	a2,a2,0x20
 4d2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 4d6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 4da:	0785                	addi	a5,a5,1
 4dc:	fee79de3          	bne	a5,a4,4d6 <memset+0x12>
  }
  return dst;
}
 4e0:	6422                	ld	s0,8(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <strchr>:

char*
strchr(const char *s, char c)
{
 4e6:	1141                	addi	sp,sp,-16
 4e8:	e422                	sd	s0,8(sp)
 4ea:	0800                	addi	s0,sp,16
  for(; *s; s++)
 4ec:	00054783          	lbu	a5,0(a0)
 4f0:	cb99                	beqz	a5,506 <strchr+0x20>
    if(*s == c)
 4f2:	00f58763          	beq	a1,a5,500 <strchr+0x1a>
  for(; *s; s++)
 4f6:	0505                	addi	a0,a0,1
 4f8:	00054783          	lbu	a5,0(a0)
 4fc:	fbfd                	bnez	a5,4f2 <strchr+0xc>
      return (char*)s;
  return 0;
 4fe:	4501                	li	a0,0
}
 500:	6422                	ld	s0,8(sp)
 502:	0141                	addi	sp,sp,16
 504:	8082                	ret
  return 0;
 506:	4501                	li	a0,0
 508:	bfe5                	j	500 <strchr+0x1a>

000000000000050a <gets>:

char*
gets(char *buf, int max)
{
 50a:	711d                	addi	sp,sp,-96
 50c:	ec86                	sd	ra,88(sp)
 50e:	e8a2                	sd	s0,80(sp)
 510:	e4a6                	sd	s1,72(sp)
 512:	e0ca                	sd	s2,64(sp)
 514:	fc4e                	sd	s3,56(sp)
 516:	f852                	sd	s4,48(sp)
 518:	f456                	sd	s5,40(sp)
 51a:	f05a                	sd	s6,32(sp)
 51c:	ec5e                	sd	s7,24(sp)
 51e:	1080                	addi	s0,sp,96
 520:	8baa                	mv	s7,a0
 522:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 524:	892a                	mv	s2,a0
 526:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 528:	4aa9                	li	s5,10
 52a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 52c:	89a6                	mv	s3,s1
 52e:	2485                	addiw	s1,s1,1
 530:	0344d863          	bge	s1,s4,560 <gets+0x56>
    cc = read(0, &c, 1);
 534:	4605                	li	a2,1
 536:	faf40593          	addi	a1,s0,-81
 53a:	4501                	li	a0,0
 53c:	00000097          	auipc	ra,0x0
 540:	19a080e7          	jalr	410(ra) # 6d6 <read>
    if(cc < 1)
 544:	00a05e63          	blez	a0,560 <gets+0x56>
    buf[i++] = c;
 548:	faf44783          	lbu	a5,-81(s0)
 54c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 550:	01578763          	beq	a5,s5,55e <gets+0x54>
 554:	0905                	addi	s2,s2,1
 556:	fd679be3          	bne	a5,s6,52c <gets+0x22>
  for(i=0; i+1 < max; ){
 55a:	89a6                	mv	s3,s1
 55c:	a011                	j	560 <gets+0x56>
 55e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 560:	99de                	add	s3,s3,s7
 562:	00098023          	sb	zero,0(s3)
  return buf;
}
 566:	855e                	mv	a0,s7
 568:	60e6                	ld	ra,88(sp)
 56a:	6446                	ld	s0,80(sp)
 56c:	64a6                	ld	s1,72(sp)
 56e:	6906                	ld	s2,64(sp)
 570:	79e2                	ld	s3,56(sp)
 572:	7a42                	ld	s4,48(sp)
 574:	7aa2                	ld	s5,40(sp)
 576:	7b02                	ld	s6,32(sp)
 578:	6be2                	ld	s7,24(sp)
 57a:	6125                	addi	sp,sp,96
 57c:	8082                	ret

000000000000057e <stat>:

int
stat(const char *n, struct stat *st)
{
 57e:	1101                	addi	sp,sp,-32
 580:	ec06                	sd	ra,24(sp)
 582:	e822                	sd	s0,16(sp)
 584:	e426                	sd	s1,8(sp)
 586:	e04a                	sd	s2,0(sp)
 588:	1000                	addi	s0,sp,32
 58a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 58c:	4581                	li	a1,0
 58e:	00000097          	auipc	ra,0x0
 592:	170080e7          	jalr	368(ra) # 6fe <open>
  if(fd < 0)
 596:	02054563          	bltz	a0,5c0 <stat+0x42>
 59a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 59c:	85ca                	mv	a1,s2
 59e:	00000097          	auipc	ra,0x0
 5a2:	178080e7          	jalr	376(ra) # 716 <fstat>
 5a6:	892a                	mv	s2,a0
  close(fd);
 5a8:	8526                	mv	a0,s1
 5aa:	00000097          	auipc	ra,0x0
 5ae:	13c080e7          	jalr	316(ra) # 6e6 <close>
  return r;
}
 5b2:	854a                	mv	a0,s2
 5b4:	60e2                	ld	ra,24(sp)
 5b6:	6442                	ld	s0,16(sp)
 5b8:	64a2                	ld	s1,8(sp)
 5ba:	6902                	ld	s2,0(sp)
 5bc:	6105                	addi	sp,sp,32
 5be:	8082                	ret
    return -1;
 5c0:	597d                	li	s2,-1
 5c2:	bfc5                	j	5b2 <stat+0x34>

00000000000005c4 <atoi>:

int
atoi(const char *s)
{
 5c4:	1141                	addi	sp,sp,-16
 5c6:	e422                	sd	s0,8(sp)
 5c8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5ca:	00054683          	lbu	a3,0(a0)
 5ce:	fd06879b          	addiw	a5,a3,-48
 5d2:	0ff7f793          	zext.b	a5,a5
 5d6:	4625                	li	a2,9
 5d8:	02f66863          	bltu	a2,a5,608 <atoi+0x44>
 5dc:	872a                	mv	a4,a0
  n = 0;
 5de:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 5e0:	0705                	addi	a4,a4,1
 5e2:	0025179b          	slliw	a5,a0,0x2
 5e6:	9fa9                	addw	a5,a5,a0
 5e8:	0017979b          	slliw	a5,a5,0x1
 5ec:	9fb5                	addw	a5,a5,a3
 5ee:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 5f2:	00074683          	lbu	a3,0(a4)
 5f6:	fd06879b          	addiw	a5,a3,-48
 5fa:	0ff7f793          	zext.b	a5,a5
 5fe:	fef671e3          	bgeu	a2,a5,5e0 <atoi+0x1c>
  return n;
}
 602:	6422                	ld	s0,8(sp)
 604:	0141                	addi	sp,sp,16
 606:	8082                	ret
  n = 0;
 608:	4501                	li	a0,0
 60a:	bfe5                	j	602 <atoi+0x3e>

000000000000060c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 60c:	1141                	addi	sp,sp,-16
 60e:	e422                	sd	s0,8(sp)
 610:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 612:	02b57463          	bgeu	a0,a1,63a <memmove+0x2e>
    while(n-- > 0)
 616:	00c05f63          	blez	a2,634 <memmove+0x28>
 61a:	1602                	slli	a2,a2,0x20
 61c:	9201                	srli	a2,a2,0x20
 61e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 622:	872a                	mv	a4,a0
      *dst++ = *src++;
 624:	0585                	addi	a1,a1,1
 626:	0705                	addi	a4,a4,1
 628:	fff5c683          	lbu	a3,-1(a1)
 62c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 630:	fee79ae3          	bne	a5,a4,624 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 634:	6422                	ld	s0,8(sp)
 636:	0141                	addi	sp,sp,16
 638:	8082                	ret
    dst += n;
 63a:	00c50733          	add	a4,a0,a2
    src += n;
 63e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 640:	fec05ae3          	blez	a2,634 <memmove+0x28>
 644:	fff6079b          	addiw	a5,a2,-1
 648:	1782                	slli	a5,a5,0x20
 64a:	9381                	srli	a5,a5,0x20
 64c:	fff7c793          	not	a5,a5
 650:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 652:	15fd                	addi	a1,a1,-1
 654:	177d                	addi	a4,a4,-1
 656:	0005c683          	lbu	a3,0(a1)
 65a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 65e:	fee79ae3          	bne	a5,a4,652 <memmove+0x46>
 662:	bfc9                	j	634 <memmove+0x28>

0000000000000664 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 664:	1141                	addi	sp,sp,-16
 666:	e422                	sd	s0,8(sp)
 668:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 66a:	ca05                	beqz	a2,69a <memcmp+0x36>
 66c:	fff6069b          	addiw	a3,a2,-1
 670:	1682                	slli	a3,a3,0x20
 672:	9281                	srli	a3,a3,0x20
 674:	0685                	addi	a3,a3,1
 676:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 678:	00054783          	lbu	a5,0(a0)
 67c:	0005c703          	lbu	a4,0(a1)
 680:	00e79863          	bne	a5,a4,690 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 684:	0505                	addi	a0,a0,1
    p2++;
 686:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 688:	fed518e3          	bne	a0,a3,678 <memcmp+0x14>
  }
  return 0;
 68c:	4501                	li	a0,0
 68e:	a019                	j	694 <memcmp+0x30>
      return *p1 - *p2;
 690:	40e7853b          	subw	a0,a5,a4
}
 694:	6422                	ld	s0,8(sp)
 696:	0141                	addi	sp,sp,16
 698:	8082                	ret
  return 0;
 69a:	4501                	li	a0,0
 69c:	bfe5                	j	694 <memcmp+0x30>

000000000000069e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 69e:	1141                	addi	sp,sp,-16
 6a0:	e406                	sd	ra,8(sp)
 6a2:	e022                	sd	s0,0(sp)
 6a4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6a6:	00000097          	auipc	ra,0x0
 6aa:	f66080e7          	jalr	-154(ra) # 60c <memmove>
}
 6ae:	60a2                	ld	ra,8(sp)
 6b0:	6402                	ld	s0,0(sp)
 6b2:	0141                	addi	sp,sp,16
 6b4:	8082                	ret

00000000000006b6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6b6:	4885                	li	a7,1
 ecall
 6b8:	00000073          	ecall
 ret
 6bc:	8082                	ret

00000000000006be <exit>:
.global exit
exit:
 li a7, SYS_exit
 6be:	4889                	li	a7,2
 ecall
 6c0:	00000073          	ecall
 ret
 6c4:	8082                	ret

00000000000006c6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6c6:	488d                	li	a7,3
 ecall
 6c8:	00000073          	ecall
 ret
 6cc:	8082                	ret

00000000000006ce <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6ce:	4891                	li	a7,4
 ecall
 6d0:	00000073          	ecall
 ret
 6d4:	8082                	ret

00000000000006d6 <read>:
.global read
read:
 li a7, SYS_read
 6d6:	4895                	li	a7,5
 ecall
 6d8:	00000073          	ecall
 ret
 6dc:	8082                	ret

00000000000006de <write>:
.global write
write:
 li a7, SYS_write
 6de:	48c1                	li	a7,16
 ecall
 6e0:	00000073          	ecall
 ret
 6e4:	8082                	ret

00000000000006e6 <close>:
.global close
close:
 li a7, SYS_close
 6e6:	48d5                	li	a7,21
 ecall
 6e8:	00000073          	ecall
 ret
 6ec:	8082                	ret

00000000000006ee <kill>:
.global kill
kill:
 li a7, SYS_kill
 6ee:	4899                	li	a7,6
 ecall
 6f0:	00000073          	ecall
 ret
 6f4:	8082                	ret

00000000000006f6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6f6:	489d                	li	a7,7
 ecall
 6f8:	00000073          	ecall
 ret
 6fc:	8082                	ret

00000000000006fe <open>:
.global open
open:
 li a7, SYS_open
 6fe:	48bd                	li	a7,15
 ecall
 700:	00000073          	ecall
 ret
 704:	8082                	ret

0000000000000706 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 706:	48c5                	li	a7,17
 ecall
 708:	00000073          	ecall
 ret
 70c:	8082                	ret

000000000000070e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 70e:	48c9                	li	a7,18
 ecall
 710:	00000073          	ecall
 ret
 714:	8082                	ret

0000000000000716 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 716:	48a1                	li	a7,8
 ecall
 718:	00000073          	ecall
 ret
 71c:	8082                	ret

000000000000071e <link>:
.global link
link:
 li a7, SYS_link
 71e:	48cd                	li	a7,19
 ecall
 720:	00000073          	ecall
 ret
 724:	8082                	ret

0000000000000726 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 726:	48d1                	li	a7,20
 ecall
 728:	00000073          	ecall
 ret
 72c:	8082                	ret

000000000000072e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 72e:	48a5                	li	a7,9
 ecall
 730:	00000073          	ecall
 ret
 734:	8082                	ret

0000000000000736 <dup>:
.global dup
dup:
 li a7, SYS_dup
 736:	48a9                	li	a7,10
 ecall
 738:	00000073          	ecall
 ret
 73c:	8082                	ret

000000000000073e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 73e:	48ad                	li	a7,11
 ecall
 740:	00000073          	ecall
 ret
 744:	8082                	ret

0000000000000746 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 746:	48b1                	li	a7,12
 ecall
 748:	00000073          	ecall
 ret
 74c:	8082                	ret

000000000000074e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 74e:	48b5                	li	a7,13
 ecall
 750:	00000073          	ecall
 ret
 754:	8082                	ret

0000000000000756 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 756:	48b9                	li	a7,14
 ecall
 758:	00000073          	ecall
 ret
 75c:	8082                	ret

000000000000075e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 75e:	1101                	addi	sp,sp,-32
 760:	ec06                	sd	ra,24(sp)
 762:	e822                	sd	s0,16(sp)
 764:	1000                	addi	s0,sp,32
 766:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 76a:	4605                	li	a2,1
 76c:	fef40593          	addi	a1,s0,-17
 770:	00000097          	auipc	ra,0x0
 774:	f6e080e7          	jalr	-146(ra) # 6de <write>
}
 778:	60e2                	ld	ra,24(sp)
 77a:	6442                	ld	s0,16(sp)
 77c:	6105                	addi	sp,sp,32
 77e:	8082                	ret

0000000000000780 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 780:	7139                	addi	sp,sp,-64
 782:	fc06                	sd	ra,56(sp)
 784:	f822                	sd	s0,48(sp)
 786:	f426                	sd	s1,40(sp)
 788:	f04a                	sd	s2,32(sp)
 78a:	ec4e                	sd	s3,24(sp)
 78c:	0080                	addi	s0,sp,64
 78e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 790:	c299                	beqz	a3,796 <printint+0x16>
 792:	0805c963          	bltz	a1,824 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 796:	2581                	sext.w	a1,a1
  neg = 0;
 798:	4881                	li	a7,0
 79a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 79e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7a0:	2601                	sext.w	a2,a2
 7a2:	00000517          	auipc	a0,0x0
 7a6:	58650513          	addi	a0,a0,1414 # d28 <digits>
 7aa:	883a                	mv	a6,a4
 7ac:	2705                	addiw	a4,a4,1
 7ae:	02c5f7bb          	remuw	a5,a1,a2
 7b2:	1782                	slli	a5,a5,0x20
 7b4:	9381                	srli	a5,a5,0x20
 7b6:	97aa                	add	a5,a5,a0
 7b8:	0007c783          	lbu	a5,0(a5)
 7bc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 7c0:	0005879b          	sext.w	a5,a1
 7c4:	02c5d5bb          	divuw	a1,a1,a2
 7c8:	0685                	addi	a3,a3,1
 7ca:	fec7f0e3          	bgeu	a5,a2,7aa <printint+0x2a>
  if(neg)
 7ce:	00088c63          	beqz	a7,7e6 <printint+0x66>
    buf[i++] = '-';
 7d2:	fd070793          	addi	a5,a4,-48
 7d6:	00878733          	add	a4,a5,s0
 7da:	02d00793          	li	a5,45
 7de:	fef70823          	sb	a5,-16(a4)
 7e2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 7e6:	02e05863          	blez	a4,816 <printint+0x96>
 7ea:	fc040793          	addi	a5,s0,-64
 7ee:	00e78933          	add	s2,a5,a4
 7f2:	fff78993          	addi	s3,a5,-1
 7f6:	99ba                	add	s3,s3,a4
 7f8:	377d                	addiw	a4,a4,-1
 7fa:	1702                	slli	a4,a4,0x20
 7fc:	9301                	srli	a4,a4,0x20
 7fe:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 802:	fff94583          	lbu	a1,-1(s2)
 806:	8526                	mv	a0,s1
 808:	00000097          	auipc	ra,0x0
 80c:	f56080e7          	jalr	-170(ra) # 75e <putc>
  while(--i >= 0)
 810:	197d                	addi	s2,s2,-1
 812:	ff3918e3          	bne	s2,s3,802 <printint+0x82>
}
 816:	70e2                	ld	ra,56(sp)
 818:	7442                	ld	s0,48(sp)
 81a:	74a2                	ld	s1,40(sp)
 81c:	7902                	ld	s2,32(sp)
 81e:	69e2                	ld	s3,24(sp)
 820:	6121                	addi	sp,sp,64
 822:	8082                	ret
    x = -xx;
 824:	40b005bb          	negw	a1,a1
    neg = 1;
 828:	4885                	li	a7,1
    x = -xx;
 82a:	bf85                	j	79a <printint+0x1a>

000000000000082c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 82c:	715d                	addi	sp,sp,-80
 82e:	e486                	sd	ra,72(sp)
 830:	e0a2                	sd	s0,64(sp)
 832:	fc26                	sd	s1,56(sp)
 834:	f84a                	sd	s2,48(sp)
 836:	f44e                	sd	s3,40(sp)
 838:	f052                	sd	s4,32(sp)
 83a:	ec56                	sd	s5,24(sp)
 83c:	e85a                	sd	s6,16(sp)
 83e:	e45e                	sd	s7,8(sp)
 840:	e062                	sd	s8,0(sp)
 842:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 844:	0005c903          	lbu	s2,0(a1)
 848:	18090c63          	beqz	s2,9e0 <vprintf+0x1b4>
 84c:	8aaa                	mv	s5,a0
 84e:	8bb2                	mv	s7,a2
 850:	00158493          	addi	s1,a1,1
  state = 0;
 854:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 856:	02500a13          	li	s4,37
 85a:	4b55                	li	s6,21
 85c:	a839                	j	87a <vprintf+0x4e>
        putc(fd, c);
 85e:	85ca                	mv	a1,s2
 860:	8556                	mv	a0,s5
 862:	00000097          	auipc	ra,0x0
 866:	efc080e7          	jalr	-260(ra) # 75e <putc>
 86a:	a019                	j	870 <vprintf+0x44>
    } else if(state == '%'){
 86c:	01498d63          	beq	s3,s4,886 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 870:	0485                	addi	s1,s1,1
 872:	fff4c903          	lbu	s2,-1(s1)
 876:	16090563          	beqz	s2,9e0 <vprintf+0x1b4>
    if(state == 0){
 87a:	fe0999e3          	bnez	s3,86c <vprintf+0x40>
      if(c == '%'){
 87e:	ff4910e3          	bne	s2,s4,85e <vprintf+0x32>
        state = '%';
 882:	89d2                	mv	s3,s4
 884:	b7f5                	j	870 <vprintf+0x44>
      if(c == 'd'){
 886:	13490263          	beq	s2,s4,9aa <vprintf+0x17e>
 88a:	f9d9079b          	addiw	a5,s2,-99
 88e:	0ff7f793          	zext.b	a5,a5
 892:	12fb6563          	bltu	s6,a5,9bc <vprintf+0x190>
 896:	f9d9079b          	addiw	a5,s2,-99
 89a:	0ff7f713          	zext.b	a4,a5
 89e:	10eb6f63          	bltu	s6,a4,9bc <vprintf+0x190>
 8a2:	00271793          	slli	a5,a4,0x2
 8a6:	00000717          	auipc	a4,0x0
 8aa:	42a70713          	addi	a4,a4,1066 # cd0 <malloc+0x1f2>
 8ae:	97ba                	add	a5,a5,a4
 8b0:	439c                	lw	a5,0(a5)
 8b2:	97ba                	add	a5,a5,a4
 8b4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 8b6:	008b8913          	addi	s2,s7,8
 8ba:	4685                	li	a3,1
 8bc:	4629                	li	a2,10
 8be:	000ba583          	lw	a1,0(s7)
 8c2:	8556                	mv	a0,s5
 8c4:	00000097          	auipc	ra,0x0
 8c8:	ebc080e7          	jalr	-324(ra) # 780 <printint>
 8cc:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 8ce:	4981                	li	s3,0
 8d0:	b745                	j	870 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d2:	008b8913          	addi	s2,s7,8
 8d6:	4681                	li	a3,0
 8d8:	4629                	li	a2,10
 8da:	000ba583          	lw	a1,0(s7)
 8de:	8556                	mv	a0,s5
 8e0:	00000097          	auipc	ra,0x0
 8e4:	ea0080e7          	jalr	-352(ra) # 780 <printint>
 8e8:	8bca                	mv	s7,s2
      state = 0;
 8ea:	4981                	li	s3,0
 8ec:	b751                	j	870 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 8ee:	008b8913          	addi	s2,s7,8
 8f2:	4681                	li	a3,0
 8f4:	4641                	li	a2,16
 8f6:	000ba583          	lw	a1,0(s7)
 8fa:	8556                	mv	a0,s5
 8fc:	00000097          	auipc	ra,0x0
 900:	e84080e7          	jalr	-380(ra) # 780 <printint>
 904:	8bca                	mv	s7,s2
      state = 0;
 906:	4981                	li	s3,0
 908:	b7a5                	j	870 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 90a:	008b8c13          	addi	s8,s7,8
 90e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 912:	03000593          	li	a1,48
 916:	8556                	mv	a0,s5
 918:	00000097          	auipc	ra,0x0
 91c:	e46080e7          	jalr	-442(ra) # 75e <putc>
  putc(fd, 'x');
 920:	07800593          	li	a1,120
 924:	8556                	mv	a0,s5
 926:	00000097          	auipc	ra,0x0
 92a:	e38080e7          	jalr	-456(ra) # 75e <putc>
 92e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 930:	00000b97          	auipc	s7,0x0
 934:	3f8b8b93          	addi	s7,s7,1016 # d28 <digits>
 938:	03c9d793          	srli	a5,s3,0x3c
 93c:	97de                	add	a5,a5,s7
 93e:	0007c583          	lbu	a1,0(a5)
 942:	8556                	mv	a0,s5
 944:	00000097          	auipc	ra,0x0
 948:	e1a080e7          	jalr	-486(ra) # 75e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 94c:	0992                	slli	s3,s3,0x4
 94e:	397d                	addiw	s2,s2,-1
 950:	fe0914e3          	bnez	s2,938 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 954:	8be2                	mv	s7,s8
      state = 0;
 956:	4981                	li	s3,0
 958:	bf21                	j	870 <vprintf+0x44>
        s = va_arg(ap, char*);
 95a:	008b8993          	addi	s3,s7,8
 95e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 962:	02090163          	beqz	s2,984 <vprintf+0x158>
        while(*s != 0){
 966:	00094583          	lbu	a1,0(s2)
 96a:	c9a5                	beqz	a1,9da <vprintf+0x1ae>
          putc(fd, *s);
 96c:	8556                	mv	a0,s5
 96e:	00000097          	auipc	ra,0x0
 972:	df0080e7          	jalr	-528(ra) # 75e <putc>
          s++;
 976:	0905                	addi	s2,s2,1
        while(*s != 0){
 978:	00094583          	lbu	a1,0(s2)
 97c:	f9e5                	bnez	a1,96c <vprintf+0x140>
        s = va_arg(ap, char*);
 97e:	8bce                	mv	s7,s3
      state = 0;
 980:	4981                	li	s3,0
 982:	b5fd                	j	870 <vprintf+0x44>
          s = "(null)";
 984:	00000917          	auipc	s2,0x0
 988:	34490913          	addi	s2,s2,836 # cc8 <malloc+0x1ea>
        while(*s != 0){
 98c:	02800593          	li	a1,40
 990:	bff1                	j	96c <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 992:	008b8913          	addi	s2,s7,8
 996:	000bc583          	lbu	a1,0(s7)
 99a:	8556                	mv	a0,s5
 99c:	00000097          	auipc	ra,0x0
 9a0:	dc2080e7          	jalr	-574(ra) # 75e <putc>
 9a4:	8bca                	mv	s7,s2
      state = 0;
 9a6:	4981                	li	s3,0
 9a8:	b5e1                	j	870 <vprintf+0x44>
        putc(fd, c);
 9aa:	02500593          	li	a1,37
 9ae:	8556                	mv	a0,s5
 9b0:	00000097          	auipc	ra,0x0
 9b4:	dae080e7          	jalr	-594(ra) # 75e <putc>
      state = 0;
 9b8:	4981                	li	s3,0
 9ba:	bd5d                	j	870 <vprintf+0x44>
        putc(fd, '%');
 9bc:	02500593          	li	a1,37
 9c0:	8556                	mv	a0,s5
 9c2:	00000097          	auipc	ra,0x0
 9c6:	d9c080e7          	jalr	-612(ra) # 75e <putc>
        putc(fd, c);
 9ca:	85ca                	mv	a1,s2
 9cc:	8556                	mv	a0,s5
 9ce:	00000097          	auipc	ra,0x0
 9d2:	d90080e7          	jalr	-624(ra) # 75e <putc>
      state = 0;
 9d6:	4981                	li	s3,0
 9d8:	bd61                	j	870 <vprintf+0x44>
        s = va_arg(ap, char*);
 9da:	8bce                	mv	s7,s3
      state = 0;
 9dc:	4981                	li	s3,0
 9de:	bd49                	j	870 <vprintf+0x44>
    }
  }
}
 9e0:	60a6                	ld	ra,72(sp)
 9e2:	6406                	ld	s0,64(sp)
 9e4:	74e2                	ld	s1,56(sp)
 9e6:	7942                	ld	s2,48(sp)
 9e8:	79a2                	ld	s3,40(sp)
 9ea:	7a02                	ld	s4,32(sp)
 9ec:	6ae2                	ld	s5,24(sp)
 9ee:	6b42                	ld	s6,16(sp)
 9f0:	6ba2                	ld	s7,8(sp)
 9f2:	6c02                	ld	s8,0(sp)
 9f4:	6161                	addi	sp,sp,80
 9f6:	8082                	ret

00000000000009f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9f8:	715d                	addi	sp,sp,-80
 9fa:	ec06                	sd	ra,24(sp)
 9fc:	e822                	sd	s0,16(sp)
 9fe:	1000                	addi	s0,sp,32
 a00:	e010                	sd	a2,0(s0)
 a02:	e414                	sd	a3,8(s0)
 a04:	e818                	sd	a4,16(s0)
 a06:	ec1c                	sd	a5,24(s0)
 a08:	03043023          	sd	a6,32(s0)
 a0c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a10:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a14:	8622                	mv	a2,s0
 a16:	00000097          	auipc	ra,0x0
 a1a:	e16080e7          	jalr	-490(ra) # 82c <vprintf>
}
 a1e:	60e2                	ld	ra,24(sp)
 a20:	6442                	ld	s0,16(sp)
 a22:	6161                	addi	sp,sp,80
 a24:	8082                	ret

0000000000000a26 <printf>:

void
printf(const char *fmt, ...)
{
 a26:	711d                	addi	sp,sp,-96
 a28:	ec06                	sd	ra,24(sp)
 a2a:	e822                	sd	s0,16(sp)
 a2c:	1000                	addi	s0,sp,32
 a2e:	e40c                	sd	a1,8(s0)
 a30:	e810                	sd	a2,16(s0)
 a32:	ec14                	sd	a3,24(s0)
 a34:	f018                	sd	a4,32(s0)
 a36:	f41c                	sd	a5,40(s0)
 a38:	03043823          	sd	a6,48(s0)
 a3c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a40:	00840613          	addi	a2,s0,8
 a44:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a48:	85aa                	mv	a1,a0
 a4a:	4505                	li	a0,1
 a4c:	00000097          	auipc	ra,0x0
 a50:	de0080e7          	jalr	-544(ra) # 82c <vprintf>
}
 a54:	60e2                	ld	ra,24(sp)
 a56:	6442                	ld	s0,16(sp)
 a58:	6125                	addi	sp,sp,96
 a5a:	8082                	ret

0000000000000a5c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a5c:	1141                	addi	sp,sp,-16
 a5e:	e422                	sd	s0,8(sp)
 a60:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a62:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a66:	00000797          	auipc	a5,0x0
 a6a:	2fa7b783          	ld	a5,762(a5) # d60 <freep>
 a6e:	a02d                	j	a98 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a70:	4618                	lw	a4,8(a2)
 a72:	9f2d                	addw	a4,a4,a1
 a74:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a78:	6398                	ld	a4,0(a5)
 a7a:	6310                	ld	a2,0(a4)
 a7c:	a83d                	j	aba <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a7e:	ff852703          	lw	a4,-8(a0)
 a82:	9f31                	addw	a4,a4,a2
 a84:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a86:	ff053683          	ld	a3,-16(a0)
 a8a:	a091                	j	ace <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a8c:	6398                	ld	a4,0(a5)
 a8e:	00e7e463          	bltu	a5,a4,a96 <free+0x3a>
 a92:	00e6ea63          	bltu	a3,a4,aa6 <free+0x4a>
{
 a96:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a98:	fed7fae3          	bgeu	a5,a3,a8c <free+0x30>
 a9c:	6398                	ld	a4,0(a5)
 a9e:	00e6e463          	bltu	a3,a4,aa6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aa2:	fee7eae3          	bltu	a5,a4,a96 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 aa6:	ff852583          	lw	a1,-8(a0)
 aaa:	6390                	ld	a2,0(a5)
 aac:	02059813          	slli	a6,a1,0x20
 ab0:	01c85713          	srli	a4,a6,0x1c
 ab4:	9736                	add	a4,a4,a3
 ab6:	fae60de3          	beq	a2,a4,a70 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 aba:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 abe:	4790                	lw	a2,8(a5)
 ac0:	02061593          	slli	a1,a2,0x20
 ac4:	01c5d713          	srli	a4,a1,0x1c
 ac8:	973e                	add	a4,a4,a5
 aca:	fae68ae3          	beq	a3,a4,a7e <free+0x22>
    p->s.ptr = bp->s.ptr;
 ace:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 ad0:	00000717          	auipc	a4,0x0
 ad4:	28f73823          	sd	a5,656(a4) # d60 <freep>
}
 ad8:	6422                	ld	s0,8(sp)
 ada:	0141                	addi	sp,sp,16
 adc:	8082                	ret

0000000000000ade <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ade:	7139                	addi	sp,sp,-64
 ae0:	fc06                	sd	ra,56(sp)
 ae2:	f822                	sd	s0,48(sp)
 ae4:	f426                	sd	s1,40(sp)
 ae6:	f04a                	sd	s2,32(sp)
 ae8:	ec4e                	sd	s3,24(sp)
 aea:	e852                	sd	s4,16(sp)
 aec:	e456                	sd	s5,8(sp)
 aee:	e05a                	sd	s6,0(sp)
 af0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 af2:	02051493          	slli	s1,a0,0x20
 af6:	9081                	srli	s1,s1,0x20
 af8:	04bd                	addi	s1,s1,15
 afa:	8091                	srli	s1,s1,0x4
 afc:	0014899b          	addiw	s3,s1,1
 b00:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b02:	00000517          	auipc	a0,0x0
 b06:	25e53503          	ld	a0,606(a0) # d60 <freep>
 b0a:	c515                	beqz	a0,b36 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b0c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b0e:	4798                	lw	a4,8(a5)
 b10:	02977f63          	bgeu	a4,s1,b4e <malloc+0x70>
  if(nu < 4096)
 b14:	8a4e                	mv	s4,s3
 b16:	0009871b          	sext.w	a4,s3
 b1a:	6685                	lui	a3,0x1
 b1c:	00d77363          	bgeu	a4,a3,b22 <malloc+0x44>
 b20:	6a05                	lui	s4,0x1
 b22:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b26:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b2a:	00000917          	auipc	s2,0x0
 b2e:	23690913          	addi	s2,s2,566 # d60 <freep>
  if(p == (char*)-1)
 b32:	5afd                	li	s5,-1
 b34:	a895                	j	ba8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 b36:	00008797          	auipc	a5,0x8
 b3a:	41278793          	addi	a5,a5,1042 # 8f48 <base>
 b3e:	00000717          	auipc	a4,0x0
 b42:	22f73123          	sd	a5,546(a4) # d60 <freep>
 b46:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b48:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b4c:	b7e1                	j	b14 <malloc+0x36>
      if(p->s.size == nunits)
 b4e:	02e48c63          	beq	s1,a4,b86 <malloc+0xa8>
        p->s.size -= nunits;
 b52:	4137073b          	subw	a4,a4,s3
 b56:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b58:	02071693          	slli	a3,a4,0x20
 b5c:	01c6d713          	srli	a4,a3,0x1c
 b60:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b62:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b66:	00000717          	auipc	a4,0x0
 b6a:	1ea73d23          	sd	a0,506(a4) # d60 <freep>
      return (void*)(p + 1);
 b6e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b72:	70e2                	ld	ra,56(sp)
 b74:	7442                	ld	s0,48(sp)
 b76:	74a2                	ld	s1,40(sp)
 b78:	7902                	ld	s2,32(sp)
 b7a:	69e2                	ld	s3,24(sp)
 b7c:	6a42                	ld	s4,16(sp)
 b7e:	6aa2                	ld	s5,8(sp)
 b80:	6b02                	ld	s6,0(sp)
 b82:	6121                	addi	sp,sp,64
 b84:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b86:	6398                	ld	a4,0(a5)
 b88:	e118                	sd	a4,0(a0)
 b8a:	bff1                	j	b66 <malloc+0x88>
  hp->s.size = nu;
 b8c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b90:	0541                	addi	a0,a0,16
 b92:	00000097          	auipc	ra,0x0
 b96:	eca080e7          	jalr	-310(ra) # a5c <free>
  return freep;
 b9a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b9e:	d971                	beqz	a0,b72 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ba0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ba2:	4798                	lw	a4,8(a5)
 ba4:	fa9775e3          	bgeu	a4,s1,b4e <malloc+0x70>
    if(p == freep)
 ba8:	00093703          	ld	a4,0(s2)
 bac:	853e                	mv	a0,a5
 bae:	fef719e3          	bne	a4,a5,ba0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 bb2:	8552                	mv	a0,s4
 bb4:	00000097          	auipc	ra,0x0
 bb8:	b92080e7          	jalr	-1134(ra) # 746 <sbrk>
  if(p == (char*)-1)
 bbc:	fd5518e3          	bne	a0,s5,b8c <malloc+0xae>
        return 0;
 bc0:	4501                	li	a0,0
 bc2:	bf45                	j	b72 <malloc+0x94>
