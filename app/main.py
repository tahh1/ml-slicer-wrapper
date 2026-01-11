from fastapi import FastAPI, UploadFile, BackgroundTasks
import tempfile, shutil
from pathlib import Path
from fastapi.responses import FileResponse
from app.runner import run_slicer

app = FastAPI()

@app.post("/slice")
async def slice_file(
    file: UploadFile,
    background_tasks: BackgroundTasks
):
    tmpdir = Path(tempfile.mkdtemp())

    input_path = tmpdir / file.filename
    with open(input_path, "wb") as f:
        shutil.copyfileobj(file.file, f)

    output_dir = tmpdir / "output"
    output_dir.mkdir()

    run_slicer(input_path, output_dir)

    zip_path = tmpdir / "results.zip"
    shutil.make_archive(
        base_name=str(zip_path.with_suffix("")),
        format="zip",
        root_dir=output_dir
    )

    background_tasks.add_task(shutil.rmtree, tmpdir)

    return FileResponse(
        zip_path,
        media_type="application/zip",
        filename="results.zip"
    )

