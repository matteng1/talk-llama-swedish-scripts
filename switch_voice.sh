#!/usr/bin/env bash
if grep -q 'lisa' ./whisper.cpp/examples/talk-llama/speak; then
	echo 'cat $2 | ./piper/piper -q --model ./piper/voices/nst.onnx --output-raw | aplay -q -r 22050 -f S16_LE -t raw -' >./whisper.cpp/examples/talk-llama/speak 
	sed -i 's/\(^.*-bn "\).*\(".*\)/\1Nst\2/g' ./run.sh
	echo "Voice: nst"
else
	echo 'cat $2 | ./piper/piper -q --model ./piper/voices/lisa.onnx --output-raw | aplay -q -r 22050 -f S16_LE -t raw -' >./whisper.cpp/examples/talk-llama/speak 
        sed -i 's/\(^.*-bn "\).*\(".*\)/\1Lisa\2/g' ./run.sh
	echo "Voice: Lisa"
fi
