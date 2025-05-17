#!/usr/bin/env bash
YOUR_NAME="Du"
ASSISTANT_NAME="Lisa"
WHISPER_MODEL="./whisper.cpp/models/sv-kb-whisper-medium-q5_0.bin"
GGUF=""
CPU_THREADS=8
NGL=32 # Comment out if only using CPU
TOP_K=64
TOP_P=0.95
MIN_P=0.01
TEMP=1.0
SEED=0
MIN_KEEP=1

# Select gguf model or ask which one.
unset MODEL
if [ $(ls ./gguf/*.gguf | wc -l) -gt 1 ]; then
	_PS3="$PS3"
	PS3="Which model do you want to use? "
	select MODEL in $(find ./gguf/*.gguf |sort); do 
		if [ -f "$MODEL" ]
		then
			GGUF=${MODEL}
			break
		else
			 echo 'Try again' >&2
		fi
	done

	PS3="$_PS3"; unset _PS3
elif [ -e ./gguf/*.gguf ]; then
	GGUF=$(ls ./gguf/*.gguf)
else
	echo "No gguf model found. Download at least one to ./gguf/ folder"
fi

./whisper.cpp/build/bin/whisper-talk-llama \
    -l sv \
    --prompt-file ./prompt.txt \
    -s ./whisper.cpp/examples/talk-llama/speak \
    -sf ./whisper.cpp/examples/talk-llama/to_speak.txt \
    -mw ./whisper.cpp/models/sv-kb-whisper-medium-q5_0.bin \
    -ml "${GGUF}" \
    -ngl ${NGL} \
    --seed ${SEED} \
    --top-k ${TOP_K}  \
    --min-keep ${MIN_KEEP} \
    --min-p ${MIN_P} \
    --temp ${TEMP} \
    -p "${YOUR_NAME}" \
    -bn "${ASSISTANT_NAME}" \
    -t ${CPU_THREADS}

