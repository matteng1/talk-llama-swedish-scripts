#!/usr/bin/env bash
############### Works in bash and on Debian and derivatives (Ubuntu, Mint, ...) ################
#### Whisper.cpp
# * Make sure cuda is installed if nvidia card is available.
# https://developer.nvidia.com/cuda-downloads

# Rudimentary check for aplay
if ! aplay --version > /dev/null 2>&1; then
        echo "aplay needs to be installed!"
        exit 1
fi


# Check if sdl2 is installed.
if ! sdl2-config --version > /dev/null 2>&1; then
	sudo apt-get install libsdl2-dev
fi

# Get whisper.cpp with swedish umlauts and model settings
git clone --depth 1 https://github.com/matteng1/whisper.cpp.git
cd whisper.cpp

### Check if cuda is installed and there is at least one nvidia card.
shopt -s nocasematch
GPU_COMPILE=""
if ! nvcc --version > /dev/null 2>&1; then
	echo "Cuda not detected. Compiling for CPU."
else
	if [[ $(eval $(which lspci)| grep -i '.* vga .* nvidia .*') == *' nvidia '* ]]; then GPU_COMPILE="-DGGML_CUDA=1"; fi
fi

# Build whisper with examples. Remove "-j$(($(grep -c "^processor" /proc/cpuinfo) - 1))" for more sane, slower compile
cmake -B build -S . -DWHISPER_SDL2=ON ${GPU_COMPILE}
cmake --build build -j$(($(grep -c "^processor" /proc/cpuinfo) - 1)) --config Release

# Get whisper models. Small and medium.
curl -L -o ./models/sv-kb-whisper-medium-q5_0.bin https://huggingface.co/KBLab/kb-whisper-medium/resolve/main/ggml-model-q5_0.bin
curl -L -o ./models/sv-kb-whisper-small-q5_0.bin https://huggingface.co/KBLab/kb-whisper-small/resolve/main/ggml-model-q5_0.bin

# Backup speak script and replace it. If backup exists - do not overwrite original backup.
BAK=""
if [ -f ./examples/talk-llama/speak.bak ]; then BAK=".bak"; fi
cp ./examples/talk-llama/speak ./examples/talk-llama/speak.bak${BAK}
echo 'cat $2 | ./piper/piper -q --model ./piper/voices/lisa.onnx --output-raw | aplay -q -r 22050 -f S16_LE -t raw -' >./examples/talk-llama/speak 

cd ..
# Create swedish prompt file
cat > ./prompt.txt << EOF
Textåtergivning av en oändlig dialog, där {0} interagerar med en AI-assistent vid namn {1}.
{1} är hjälpsam, vänlig, ärlig, vänskaplig, bra på att skriva och misslyckas aldrig med att svara på {0}s önskemål omedelbart och med detaljer och precision.
Det finns inga kommentarer som (30 sekunder har passerat...) eller (för sig själv), bara vad {0} och {1} säger högt till varandra.
Texten inkluderar endast text, den inkluderar inte markering som HTML och Markdown.
{1} svarar med korta och koncisa svar.
{0}{4} Hej, {1}!
{1}{4} Hej {0}! Hur kan jag hjälpa dig idag?
{0}{4} Hur mycket är klockan?
{1}{4} Den är {2}..
{0}{4} Vilket år är det?
{1}{4} Det är {3}.
{0}{4} Vad är en katt?
{1}{4} En katt är en domesticerad art av liten rovdjursdäggdjur. Det är den enda domesticerade arten i familjen kattdjur.
{0}{4} Säg en färg.
{1}{4} Blå
{0}{4})

EOF

#### Piper.
wget https://github.com/rhasspy/piper/releases/latest/download/piper_linux_$(uname -m).tar.gz
tar -xf piper_*.tar.gz && rm piper_*.tar.gz
# Voices. Lisa and Nst
mkdir -p ./piper/voices
curl -L -o ./piper/voices/lisa.onnx https://huggingface.co/rhasspy/piper-voices/resolve/main/sv/sv_SE/lisa/medium/sv_SE-lisa-medium.onnx
curl -L -o ./piper/voices/lisa.onnx.json https://huggingface.co/rhasspy/piper-voices/resolve/main/sv/sv_SE/lisa/medium/sv_SE-lisa-medium.onnx.json
curl -L -o ./piper/voices/nst.onnx https://huggingface.co/rhasspy/piper-voices/resolve/main/sv/sv_SE/nst/medium/sv_SE-nst-medium.onnx
curl -L -o ./piper/voices/nst.onnx.json https://huggingface.co/rhasspy/piper-voices/resolve/main/sv/sv_SE/nst/medium/sv_SE-nst-medium.onnx.json

# Create llm dir
mkdir gguf

# Create download gguf scripts
cat > ./gguf/download_6.8GiB_unsloth_gemma3_12b_4k_m_qat.sh << EOF
#!/usr/bin/env bash
curl -L -O https://huggingface.co/unsloth/gemma-3-12b-it-qat-GGUF/resolve/main/gemma-3-12b-it-qat-Q4_K_M.gguf
EOF
cat > ./gguf/download_2.4GiB_unsloth_gemma3_4b_4k_m_qat.sh << EOF
#!/usr/bin/env bash
curl -L -O https://huggingface.co/unsloth/gemma-3-4b-it-qat-GGUF/resolve/main/gemma-3-4b-it-qat-Q4_K_M.gguf
EOF
cat > ./gguf/download_16.5GiB_unsloth_gemma3_27b_4k_m_qat.sh << EOF
#!/usr/bin/env bash
curl -L -O https://huggingface.co/unsloth/gemma-3-27b-it-qat-GGUF/resolve/main/gemma-3-27b-it-qat-Q4_K_M.gguf
EOF

chmod +x ./gguf/*.sh
