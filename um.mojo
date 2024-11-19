import builtin.file
import builtin.io
import time

fn main() raises:
    var program = List[UInt32]()
    var f = file.open("sandmark.umz", "r")
    while True:
        var byts = f.read_bytes(4)
        if len(byts) < 4:
            break
        var i: UInt32 = 0
        for n in range(4):
            i = (i << 8) + byts[n].cast[DType.uint8]().cast[DType.uint32]()
        program.append(i)
    var platters = List[List[UInt32]](program)
    var reg = SIMD[DType.uint32, 8](0,0,0,0,0,0,0,0)
    var finger = 0
    var iteration = 0
    var start = time.now()
    while True:
        var v = platters.__get_ref(0)[].__get_ref(finger)[]
        finger = finger+1
        var op = v >> 28
        var a = int((v >> 6) & 0b111)
        var b = int((v >> 3) & 0b111)
        var c = int((v >> 0) & 0b111)
        iteration = iteration + 1
        if iteration % 1000000 == 0:
            print((Float32(iteration) * 1e9) / Float32(time.now()-start), " ops/sec")
        if op == 0:
            if reg[c] != 0:
                reg[a] = reg[b]
        elif op == 1:
            reg[a] = platters.__get_ref(int(reg[b]))[].__get_ref(int(reg[c]))[]
        elif op == 2:
            platters.__get_ref(int(reg[a]))[].__get_ref(int(reg[b]))[] = reg[c]
        elif op == 3:
            reg[a] = reg[b] + reg[c]
        elif op == 4:
            reg[a] = reg[b] * reg[c]
        elif op == 5:
            reg[a] = reg[b] / reg[c]
        elif op == 6:
            reg[a] = ~(reg[b] & reg[c])
        elif op == 8:
            var newplatter = List[UInt32]()
            newplatter.resize(int(reg[c]), 0)
            platters.append(newplatter)
            reg[b] = len(platters) - 1
        elif op == 9:
            platters[int(reg[c])].resize(0)
        elif op == 10:
            io._put(chr(int(reg[c])))
        elif op == 12:
            if reg[b] != 0:
                platters[0] = platters[int(reg[b])]
            finger = int(reg[c])
        elif op == 13:
            reg[int((v >> 25) & 0b111)] = v & 0b1111111111111111111111111
        else:
            print("unhandled opcode: " + str(op))
            break
