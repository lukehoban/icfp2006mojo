import builtin.file

fn main() raises:
    print("Universal Machine")
    var program = List[UInt32]()
    var out: file.FileHandle
    
    out = file.open("out.log", "w")
    var f = file.open("sandmark.umz", "r")
    for x in range(100000000):
        var byts = f.read_bytes(4)
        if len(byts) < 4:
            break
        var i: UInt32 = 0
        for n in range(4):
            i = (i << 8) + byts[n].cast[DType.uint8]().cast[DType.uint32]()
        program.append(i)

    print("Read program of " + str(len(program)) + " bytes.")
    var platters = List[List[UInt32]](program)
    var regs = List[UInt32](0,0,0,0,0,0,0,0)
    var finger = 0
    while True:
        var v = platters[0][finger]
        finger = finger+1
        var op = v >> 28
        var a = (v >> 6) & 0b111
        var b = (v >> 3) & 0b111
        var c = (v >> 0) & 0b111
        # print("v: " + str(v) + " op: " + str(op) + " a: " + str(a) + " b: " + str(b) + " c: " + str(c))
        if op == 0:
            if regs[int(c)] != 0:
                regs[int(a)] = regs[int(b)]
        elif op == 1:
            regs[int(a)] = platters[int(regs[int(b)])][int(regs[int(c)])]
        elif op == 2:
            platters[int(regs[int(a)])][int(regs[int(b)])] = regs[int(c)]
        elif op == 3:
            regs[int(a)] = regs[int(b)] + regs[int(c)]
        elif op == 4:
            regs[int(a)] = regs[int(b)] * regs[int(c)]
        elif op == 5:
            regs[int(a)] = regs[int(b)] / regs[int(c)]
        elif op == 6:
            regs[int(a)] = ~(regs[int(b)] & regs[int(c)])
        elif op == 8:
            var newplatter = List[UInt32]()
            newplatter.resize(int(regs[int(c)]), 0)
            platters.append(newplatter)
            regs[int(b)] = len(platters) - 1
        elif op == 9:
            # Clear out all the data?
            # platters[int(regs[int(c)])].resize(0, 0)
            platters[int(regs[int(c)])] = List[UInt32]()
            # var x = 1
        elif op == 10:
            try:
                out.write(chr(int(regs[int(c)])))
            except:
                break
            # print(chr(int(regs[int(c)])))
        elif op == 12:
            if regs[int(b)] != 0:
                platters[0] = platters[int(regs[int(b)])]
            finger = int(regs[int(c)])
        elif op == 13:
            a = (v >> 25) & 0b111
            var l = v & 0b1111111111111111111111111
            # print("v: " + str(v) + " op: " + str(op) + " a: " + str(a) + " l: " + str(l))
            regs[int(a)] = l 
        else:
            print("unhndled opcode: " + str(op))
            break
