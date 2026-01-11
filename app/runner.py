def run_slicer(input_file, output_dir):
    from mlslicer import run_slicer

    # Ensure souffle and node are on PATH
    run_slicer(
        input_path=str(input_file),
        output_dir=str(output_dir),
        verbose=True,
    )
