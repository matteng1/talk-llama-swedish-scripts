# talk-llama-swedish-scripts
Bash scripts for installing, compiling and running the whisper.cpp talk-llama example with swedish tts and stt. <br />
Works on debian PC.
## Prerequisites
* Working aplay for text-to-speech
* Cuda installed if using an Nvidia GPU
## Install
**NOTE: Bash only.**
* Download the three scripts to a suitable folder.
```shell
mkdir talk-llama-swedish && cd talk-llama-swedish

wget https://github.com/matteng1/talk-llama-swedish-scripts/raw/refs/heads/main/install.sh
wget https://github.com/matteng1/talk-llama-swedish-scripts/raw/refs/heads/main/switch_voice.sh
wget https://github.com/matteng1/talk-llama-swedish-scripts/raw/refs/heads/main/run.sh
chmod +x *.sh
```
* Run install.sh, which will download approximately 1 GiB of swedish stt and tts models.
```shell
./install.sh
```
* Download gguf to ./gguf/ folder (scripts are supplied)
```shell
cd gguf
./download_2.4GiB_unsloth_gemma3_4b_4k_m_qat.sh
cd ..
```
* Switch voice for text-to-speech with switch_voice.sh if preferred.
```shell
./switch_voice.sh
```

* Run run.sh
```shell
./run.sh
```
