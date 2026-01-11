# ML Slicer Wrapper

FastAPI+docker wrapper around the [`ml-slicer`](https://github.com/tahh1/ml-slicer) tool. It accepts a file upload, runs the slicer, and returns a zip of the results.

## What it does

- POST a file to `/slice`
- Runs `ml-slicer` with the uploaded file
- Zips the output directory and returns `results.zip`

## API

### POST /slice

- Multipart form field: `file`
- Response: `results.zip` (application/zip)

Example:

```bash
curl -X POST \
  -F "file=@/path/to/input.py" \
  http://localhost:8000/slice \
  --output results.zip
```

## Docker

Build:

```bash
docker build -t ml-slicer-wrapper .
```

Run:

```bash
docker run --rm -p 8000:8000 ml-slicer-wrapper
```

## Notes

- Temp files are cleaned up after each request.
- `ml-slicer` is installed in the Docker image and built with its Pyright dependency.
