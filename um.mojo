import builtin.file

fn main() raises:
    print("Universal Machine -- output to `out.log`")
    var program = List[UInt32]()
    var out: file.FileHandle
    out = file.open("out.log", "w")
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
    var reg = List[UInt32](0,0,0,0,0,0,0,0)
    var finger = 0
    var iteration = 0
    while True:
        var v = platters[0][finger]
        finger = finger+1
        var op = v >> 28
        var a = int((v >> 6) & 0b111)
        var b = int((v >> 3) & 0b111)
        var c = int((v >> 0) & 0b111)
        # iteration = iteration + 1
        # if iteration % 10000 == 0:
        #     print("iter: " + str(iteration) + " v: " + str(v) + " op: " + str(op) + " a: " + str(a) + " b: " + str(b) + " c: " + str(c))
        #     for i in range(8):
        #         print("reg[" + str(i) + "] = " + str(reg[i]))
        if op == 0:
            if reg[c] != 0:
                reg[a] = reg[b]
        elif op == 1:
            reg[a] = platters[int(reg[b])][int(reg[c])]
        elif op == 2:
            platters[int(reg[a])][int(reg[b])] = reg[c]
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
            # print(len(platters))
            # for i in range(len(platters)):
            #     print("  " + str(len(platters[i])))
        elif op == 9:
            # TODO: Actually reclaim space in the array
            platters[int(reg[c])].resize(0, 0)
            # platters[int(reg[c])] = List[UInt32]()
        elif op == 10:
            try:
                out.write(chr(int(reg[c])))
            except:
                break
        elif op == 12:
            if reg[b] != 0:
                platters[0] = platters[int(reg[b])]
            finger = int(reg[c])
        elif op == 13:
            reg[int((v >> 25) & 0b111)] = v & 0b1111111111111111111111111
        else:
            print("unhndled opcode: " + str(op))
            break
