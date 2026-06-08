# Local Model Downloads

GSMLG's first local-LLM release supports two preset Gemma 4 models. Desktop
downloads use 4-bit GGUF artifacts; Android downloads use LiteRT-LM artifacts.

## Desktop GGUF Artifacts

| Model | Hugging Face repository | File | Notes |
|-------|-------------------------|------|-------|
| Gemma 4 E4B IT | `ggml-org/gemma-4-E4B-it-GGUF` | `gemma-4-E4B-it-Q4_K_M.gguf` | Default 4-bit local model |
| Gemma 4 E2B IT | `dahus/gemma-4-e2b-it-Q4_K_M-GGUF` | `gemma-4-e2b-Q4_K_M.gguf` | Smaller 4-bit preset model |

## Android LiteRT-LM Artifacts

| Model | Hugging Face repository | File |
|-------|-------------------------|------|
| Gemma 4 E4B IT | `litert-community/gemma-4-E4B-it-litert-lm` | `gemma-4-E4B-it.litertlm` |
| Gemma 4 E2B IT | `litert-community/gemma-4-E2B-it-litert-lm` | `gemma-4-E2B-it.litertlm` |

The in-app downloader selects the Android artifacts automatically on Android.

## Cache Layout

The app downloads model files from Hugging Face and stores them in its
app-managed cache under:

```text
<app-cache-dir>/lib_llama_cpp/models/<org>/<repo>/<file>
```

For example:

```text
<app-cache-dir>/lib_llama_cpp/models/ggml-org/gemma-4-E4B-it-GGUF/gemma-4-E4B-it-Q4_K_M.gguf
```

Do not rename the downloaded files. The app detects installed models by the
preset repository and filename.

## In-App Download

1. Open `Settings > Accounts`.
2. Add a Hugging Face account token if you want authenticated downloads.
3. Open `Settings > Local Models`.
4. Download either preset model.

The app uses the configured Hugging Face token when one is available. These
models are public today, but keeping a token configured avoids rate-limit and
access changes breaking downloads.

## Pre-Seed With Hugging Face CLI

Use the Hugging Face Hub CLI when you want to download models before launching
the app, share a cache across machines, or prepare an offline desktop build.

Install or update the CLI:

```sh
python3 -m pip install -U "huggingface_hub[cli]"
```

Authenticate:

```sh
hf auth login
```

You can also use a non-interactive token:

```sh
export HF_TOKEN="hf_..."
```

Set the app cache directory for your platform. On macOS with the current bundle
identifier, the default is usually:

```sh
export GSMLG_APP_CACHE="$HOME/Library/Caches/org.gsmlg.app"
```

Download the default E4B model into the exact app cache layout:

```sh
mkdir -p "$GSMLG_APP_CACHE/lib_llama_cpp/models/ggml-org/gemma-4-E4B-it-GGUF"

hf download \
  ggml-org/gemma-4-E4B-it-GGUF \
  gemma-4-E4B-it-Q4_K_M.gguf \
  --local-dir "$GSMLG_APP_CACHE/lib_llama_cpp/models/ggml-org/gemma-4-E4B-it-GGUF"
```

Download the E2B model:

```sh
mkdir -p "$GSMLG_APP_CACHE/lib_llama_cpp/models/dahus/gemma-4-e2b-it-Q4_K_M-GGUF"

hf download \
  dahus/gemma-4-e2b-it-Q4_K_M-GGUF \
  gemma-4-e2b-Q4_K_M.gguf \
  --local-dir "$GSMLG_APP_CACHE/lib_llama_cpp/models/dahus/gemma-4-e2b-it-Q4_K_M-GGUF"
```

After downloading, restart GSMLG or reopen `Settings > Local Models`. The app
will list the model as downloaded when the preset model file exists and is
non-empty.

## Notes

- The local model catalog is intentionally limited to Gemma 4 E4B and E2B for
  this release.
- Android uses LiteRT-LM `.litertlm` artifacts; desktop uses 4-bit GGUF
  artifacts.
- Multimodal, audio, and function-calling local models are deferred.
- The Hugging Face CLI command is `hf`; older installations may also provide
  `huggingface-cli`, but new docs and examples should use `hf`.
- Official CLI reference: <https://huggingface.co/docs/huggingface_hub/en/guides/cli>
