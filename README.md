Tooling to build the jdk22 HotSpot hsdis disassembler with nix.

This nix flake exposes `packages` and `devShell` outputs.

# Package

Install `hsdis-jdk22` by adding an input dependency on this repo.

```
{
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.hsdis-jdk22.url = "github:gmodena/hsdis-jdk22";

  outputs = inputs:
  let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.{system};
      hsdis-jdk = inputs.hsdis-jdk22.packages.${system}.default;
    in
    {
      devShell.${system} = pkgs.mkShell rec {
        name = "java-shell";
        buildInputs = [ hsdis-jdk pkgs.gradle pkgs.llvm];

        shellHook = ''
          export JAVA_HOME=${hsdis-jdk}
          PATH="${hsdis-jdk}/bin:$PATH"
        '';
      };
    };
}

```

For a full example see [here](https://github.com/gmodena/java-simd-playground).

# DevShell

Build a development environment with hsdis and jdk22 with:
```
nix develop
```

Then compile and run some java code with:
```
$ javac Main.java
$ java -Xbatch '-XX:-TieredCompilation' '-XX:CompileCommand=dontinline,Main::add*' '-XX:CompileCommand=PrintAssembly,Main::add*' Main
```

## Output
```
CompileCommand: dontinline Main.add* bool dontinline = true
CompileCommand: PrintAssembly Main.add* bool PrintAssembly = true

============================= C2-compiled nmethod ==============================
----------------------------------- Assembly -----------------------------------

Compiled method (c2) 201    1             Main::add (4 bytes)
 total in heap  [0x00007ffff0688f90,0x00007ffff06891a0] = 528
 relocation     [0x00007ffff06890e0,0x00007ffff06890f0] = 16
 main code      [0x00007ffff0689100,0x00007ffff0689150] = 80
 stub code      [0x00007ffff0689150,0x00007ffff0689168] = 24
 oops           [0x00007ffff0689168,0x00007ffff0689170] = 8
 scopes data    [0x00007ffff0689170,0x00007ffff0689178] = 8
 scopes pcs     [0x00007ffff0689178,0x00007ffff0689198] = 32
 dependencies   [0x00007ffff0689198,0x00007ffff06891a0] = 8

[Disassembly]
--------------------------------------------------------------------------------
[Constant Pool (empty)]

--------------------------------------------------------------------------------

[Verified Entry Point]
  # {method} {0x00007fff764002d8} 'add' '(II)I' in 'Main'
  # parm0:    rsi       = int
  # parm1:    rdx       = int
  #           [sp+0x20]  (sp of caller)
  0x00007ffff0689100:   	subq	$0x18, %rsp
  0x00007ffff0689107:   	movq	%rbp, 0x10(%rsp)
  0x00007ffff068910c:   	cmpl	$0x0, 0x20(%r15)
  0x00007ffff0689114:   	jne	0x2c
  0x00007ffff068911a:   	leal	(%rsi,%rdx), %eax
  0x00007ffff068911d:   	addq	$0x10, %rsp
  0x00007ffff0689121:   	popq	%rbp
  0x00007ffff0689122:   	cmpq	0x458(%r15), %rsp   ;   {poll_return}
  0x00007ffff0689129:   	ja	0x1
  0x00007ffff068912f:   	retq
  0x00007ffff0689130:   	movabsq	$0x7ffff0689122, %r10;   {internal_word}
  0x00007ffff068913a:   	movq	%r10, 0x470(%r15)
  0x00007ffff0689141:   	jmp	-0x34146            ;   {runtime_call SafepointBlob}
  0x00007ffff0689146:   	callq	-0x54cab            ;   {runtime_call StubRoutines (final stubs)}
  0x00007ffff068914b:   	jmp	-0x36
[Exception Handler]
  0x00007ffff0689150:   	jmp	-0x2a55             ;   {no_reloc}
[Deopt Handler Code]
  0x00007ffff0689155:   	callq	0x0
  0x00007ffff068915a:   	subq	$0x5, (%rsp)
  0x00007ffff068915f:   	jmp	-0x34ec4            ;   {runtime_call DeoptimizationBlob}
  0x00007ffff0689164:   	hlt
  0x00007ffff0689165:   	hlt
  0x00007ffff0689166:   	hlt
  0x00007ffff0689167:   	hlt
--------------------------------------------------------------------------------
[/Disassembly]
```

# References
- https://jornvernee.github.io/hsdis/2022/04/30/hsdis.html
