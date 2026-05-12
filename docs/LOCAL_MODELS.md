# Local Model Downloads

GSMLG's first local-LLM release supports two preset GGUF models:

| Model | Hugging Face repository | File | Notes |
|-------|-------------------------|------|-------|
| Gemma 4 E4B IT | `ggml-org/gemma-4-E4B-it-GGUF` | `gemma-4-E4B-it-Q4_K_M.gguf` | Default local model |
| Gemma 4 E2B IT | `ggml-org/gemma-4-E2B-it-GGUF` | `gemma-4-E2B-it-Q8_0.gguf` | Smaller preset model |

The app downloads these files from Hugging Face and stores them in its
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
mkdir -p "$GSMLG_APP_CACHE/lib_llama_cpp/models/ggml-org/gemma-4-E2B-it-GGUF"

hf download \
  ggml-org/gemma-4-E2B-it-GGUF \
  gemma-4-E2B-it-Q8_0.gguf \
  --local-dir "$GSMLG_APP_CACHE/lib_llama_cpp/models/ggml-org/gemma-4-E2B-it-GGUF"
```

After downloading, restart GSMLG or reopen `Settings > Local Models`. The app
will list the model as downloaded when the preset GGUF file exists and is
non-empty.

## Notes

- The local model catalog is intentionally GGUF-only for this release.
- Multimodal, audio, and function-calling local models are deferred.
- The Hugging Face CLI command is `hf`; older installations may also provide
  `huggingface-cli`, but new docs and examples should use `hf`.
- Official CLI reference: <https://huggingface.co/docs/huggingface_hub/en/guides/cli>
