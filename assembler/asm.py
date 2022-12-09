import re
import time
import argparse


parser = argparse.ArgumentParser(prog='assembler',
                                 description='create binary from asm',
                                 epilog='primarily made to be used for vhdl projects')

parser.add_argument('inputfile', metavar='inputfile', type=str,help='input file path')
parser.add_argument('-o',help='output file name,defaults to a.txt',default="a.txt")
parser.add_argument('-f',help='file format,defaults to hex',choices =['bin','hex'], default="bin")


args = parser.parse_args()

# Note that encoding for ADI and LHI are changed from specifications
opcode = {
"ADD" : "0001","ADC" : "0001",
"ADZ" : "0001","ADL" : "0001",
"ADI" : "1111","NDU" : "0010",
"NDC" : "0010","NDZ" : "0010",
"LHI" : "1110",
"LW"  : "0111","SW"  : "0101",
"LM"  : "1100","SM"  : "1101",
"BEQ" : "1000","JAL" : "1001",
"JLR" : "1010","JRI" : "1011"
}

NumReg = 8
logNumReg = 3

def fstr2int(s): # function to handle multiple string formats
    if   s[-1] == 'B' : return int(s[:-1],2)
    elif s[-1] == 'H' : return int(s[:-1],16)
    elif s[-1] == 'D' : return int(s[:-1],10)
    return int(s)

start_time = time.time()

filename = args.inputfile
outfile = args.o
file_format = args.f

try:
    with open(filename) as file: lines = file.readlines()
except:
    print ("Error: Invalid file {}".format(filename))
    quit()

with open(outfile,'w') as out:
    i = 1 # to keep track of current line being processed
    j = 1 # to keep track of current instr being processed
    for line in lines:
        line = line.rstrip().strip()
        if(len(line)!=0 and line[0] != '*'): # ignoring blank lines and comments
            asm_split = re.split('[\\s,]+',line.upper()) # making case insensitive
            opcode_s = opcode.get(asm_split[0]) 

            if opcode_s == None : #-----check for validity------#
                print ("SyntaxError in line-{} \"{}\": Not a valid instruction".format(i,asm_split[0]))
                quit()

            instr = opcode_s
            
            if(opcode_s == "0001" or opcode_s == "0010"): 
                #-----Syntax Error and check for validity for regNum------#
                try:
                    if not(asm_split[1][0] == 'R' and asm_split[2][0] == 'R'and asm_split[3][0] == 'R') :  raise NameError
                    C = int(asm_split[1][1:])
                    A = int(asm_split[2][1:])
                    B = int(asm_split[3][1:])
                    if not(C<NumReg and B<NumReg and A<NumReg) :raise ValueError
                    RC = f'{C:03b}' 
                    RA = f'{A:03b}'
                    RB = f'{B:03b}'
                except ValueError:
                    print("KeyError in line-{} :0-7 are only valid registers".format(i))
                    quit()
                except NameError:
                    print("SyntaxError in line-{} : Invalid Register Name".format(i))
                    quit()

                CZ = "00"
                if asm_split[0] == "ADD" or asm_split[0] == "NDU" : CZ = "00"
                if asm_split[0] == "ADC" or asm_split[0] == "NDC" : CZ = "10"
                if asm_split[0] == "ADZ" or asm_split[0] == "NDZ" : CZ = "01"
                if asm_split[0] == "ADL" : CZ = "11"
                instr+=RA+RB+RC+'0'+CZ

            elif opcode_s == "0000" or opcode_s == "0111" or opcode_s == "0101" or opcode_s == "1000" or opcode_s == "1010" :
                # I-type Instruction
                
                try: #-----Syntax Error and check for validity for regNum------#
                    if not(asm_split[1][0] == 'R' and asm_split[2][0] == 'R') :  raise NameError
                    A = int(asm_split[1][1:])
                    B = int(asm_split[2][1:])
                    if not(B<NumReg and A<NumReg) :raise ValueError
                    RA   = f'{A:03b}'
                    RB   = f'{B:03b}'
                except ValueError:
                    print("KeyError in line-{} :0-7 are only valid registers".format(i))
                    quit()
                except NameError:
                    print("SyntaxError in line-{} : Invalid Register Name".format(i))
                    quit()

                if opcode_s != "1010":
                    try: 
                        if not(asm_split[3][0] == '#') :  raise NameError
                        try:
                            imm = fstr2int(asm_split[3][1:])
                        except:
                            print("SyntaxError in line-{} : Invalid format specifier".format(i))
                            quit()
                        if not(imm<pow(2,6)) :raise ValueError
                        IMM6 = f'{imm:06b}'#----formatting error----
                    except ValueError:
                        print("ValueError in line-{} :00h-3fh are only valid values".format(i))
                        quit()
                    except NameError:
                        print("SyntaxError in line-{} : Invalid constant specifier".format(i))
                        quit()
                    IMM6 = f'{imm:06b}'#---formatting error----
                else : IMM6 = f'{0:06b}'
                instr+=RA+RB+IMM6

            else:
                # J-type Instruction

                try: #-----Syntax Error --------
                    if not(asm_split[1][0] == 'R') :  raise NameError
                    A = int(asm_split[1][1:])
                    if not(B<NumReg and A<NumReg) :raise ValueError
                    RA   = f'{A:03b}'
                except ValueError:
                    print("KeyError in line-{} :0-7 are only valid registers".format(i))
                    quit()
                except NameError:
                    print("SyntaxError in line-{} : Invalid Register Name".format(i))
                    quit()

                try: 
                    imm = fstr2int(asm_split[2][1:])
                    try:
                        imm = fstr2int(asm_split[2][1:])
                    except:
                        print("SyntaxError in line-{} : Invalid format specifier".format(i))
                        quit()
                    if not(imm<pow(2,9)) :raise ValueError
                    IMM9 = f'{imm:09b}'#-----Value Error and formatting error----
                except ValueError:
                    print("ValueError in line-{} :000h-1ffh are only valid values".format(i))
                    quit()
                except NameError:
                    print("SyntaxError in line-{} : Invalid constant specifier".format(i))
                    quit()
            
                instr+=RA+IMM9

            if file_format=="bin" : out.write(instr+'\n')
            elif file_format=="hex": out.write("x\"{0:0>4X}\"\n".format(int(instr,2))) # format as hex string and then write to the file

            j+=1
    
        i+=1

print("Execution finished in {:.4f} seconds".format(time.time()-start_time))
print("Total instructions : {}".format(j-1))
