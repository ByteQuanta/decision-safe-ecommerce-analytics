from dotenv import load_dotenv
load_dotenv()

import kagglehub
import shutil
from pathlib import Path


def main():
    project_root = Path(__file__).resolve().parents[2]
    raw_data_dir = project_root / "data" / "raw" / "olist"

    raw_data_dir.mkdir(parents=True, exist_ok=True)

    print("Downloading Olist dataset from Kaggle...")
    download_path = kagglehub.dataset_download(
        "olistbr/brazilian-ecommerce"
    )

    print(f"Dataset downloaded to cache: {download_path}")
    print("Copying files to project raw data directory...")

    for file in Path(download_path).glob("*"):
        shutil.copy(file, raw_data_dir / file.name)

    print(f"Raw dataset copied to: {raw_data_dir}")


if __name__ == "__main__":
    main()

