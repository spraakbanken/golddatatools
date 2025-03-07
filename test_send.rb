a = ARGV[0].to_f
b = ARGV[1].to_f
f = ARGV[2]

def plus(a,b)
    s = a + b
    return s
end

def minus(a,b)
    s = a - b
    return s
end

s = send(f, a, b)
puts s