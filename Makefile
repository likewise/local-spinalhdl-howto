.ONESHELL:

.PHONY: all local_spinal

build: try/VexRiscv try/SpinalHDL local_spinal
	set -e
	cd try/SpinalHDL
	sbt clean compile publishLocal
	cd ../..
	cd try/VexRiscv
	sbt "runMain vexriscv.demo.Murax"

local_spinal: try/VexRiscv
	cd try/VexRiscv
	sed -i 's@ "com.github.spinalhdl"@ //"com.github.spinalhdl"@' build.sbt
	sed -i 's@[[:space:]])[[:space:]]*$$@).dependsOn(spinalHdlSim,spinalHdlCore,spinalHdlLib)\n@' build.sbt
	grep -e 'val.*spinalHdlSim' build.sbt || echo '\n\nlazy val spinalHdlSim  = ProjectRef(file("../SpinalHDL"), "sim")' >> build.sbt
	grep -e 'val.*spinalHdlCore' build.sbt || echo 'lazy val spinalHdlCore = ProjectRef(file("../SpinalHDL"), "core")' >> build.sbt
	grep -e 'val.*spinalHdlLib' build.sbt || echo 'lazy val spinalHdlLib  = ProjectRef(file("../SpinalHDL"), "lib")' >> build.sbt
	cat build.sbt
	echo
	cd ../..

try/VexRiscv:
	set -e
	mkdir -p try
	cd try/
	git clone --recurse https://github.com/SpinalHDL/VexRiscv.git
	cd ..

try/SpinalHDL: try/VexRiscv
	set -e
	mkdir -p try
	cd try/
	git clone --recurse https://github.com/SpinalHDL/SpinalHDL.git
	cd SpinalHDL
	git checkout v1.6.4
	cp -av ../VexRiscv/project/build.properties project/
	cd ..

clean:
	rm -rf try
	rm -rf ~/.ivy
	rm -rf ~/.sbt

