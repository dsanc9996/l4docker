import shutil
import subprocess
import sys
import time
from concurrent import futures
from pathlib import Path

import requests


STEAMCMD = Path("/home/louis/steamcmd.sh")
# L4D2 App ID
APP_ID = "550"
MAX_WORKERS = 4
MAX_RETRIES = 3
RETRY_DELAY_SECONDS = 5
DOWNLOAD_ROOT = Path("/tmp/workshop")
OUTPUT = Path("/overlay/addons")
COLLECTION_URL = (
    "https://api.steampowered.com/"
    "ISteamRemoteStorage/GetCollectionDetails/v1/"
)


def get_addon_ids(collection_id: str) -> list[str]:
    response = requests.post(
        COLLECTION_URL,
        data={
            "collectioncount": 1,
            "publishedfileids[0]": collection_id,
        },
        timeout=30,
    )
    response.raise_for_status()
    collection = response.json()["response"]["collectiondetails"][0]

    if collection["result"] != 1:
        raise RuntimeError(f"Could not resolve collection {collection_id}")

    return [child["publishedfileid"] for child in collection["children"]]


def download_batch(worker_id: int, workshop_ids: list[str]) -> None:
    # Separate install roots keep concurrent downloads' Workshop state apart.
    download_root = DOWNLOAD_ROOT / f"worker-{worker_id}"
    download_root.mkdir(parents=True, exist_ok=True)
    command = [
        str(STEAMCMD),
        "+force_install_dir",
        str(download_root),
        "+login",
        "anonymous",
    ]
    for workshop_id in workshop_ids:
        command.extend(
            ["+workshop_download_item", APP_ID, workshop_id, "validate"]
        )
    command.append("+quit")
    subprocess.run(command, check=True)
    for workshop_id in workshop_ids:
        install_addon(workshop_id, download_root)


def retry(function, *args) -> None:
    for attempt in range(MAX_RETRIES + 1):
        try:
            return function(*args)
        except (subprocess.CalledProcessError, RuntimeError) as error:
            if attempt == MAX_RETRIES:
                raise
            print(f"Retry {attempt + 1}/{MAX_RETRIES}: {error}", flush=True)
            time.sleep(RETRY_DELAY_SECONDS)


def download_addons(workshop_ids: list[str]) -> None:
    with futures.ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        # Each batch logs in once and keeps that session for all its downloads.
        # Spread neighboring campaigns across workers with every-Nth-item slices.
        downloads = [
            executor.submit(
                retry, download_batch, worker_id, workshop_ids[worker_id::MAX_WORKERS]
            )
            for worker_id in range(min(MAX_WORKERS, len(workshop_ids)))
        ]
        for download in futures.as_completed(downloads):
            download.result()


def install_addon(workshop_id: str, download_root: Path) -> None:
    downloaded = (
        download_root
        / "steamapps"
        / "workshop"
        / "content"
        / APP_ID
        / workshop_id
    )
    workshop_files = list(downloaded.glob("*_legacy.bin"))
    if len(workshop_files) != 1:
        raise RuntimeError(
            f"Expected one legacy.bin for Workshop item {workshop_id}, "
            f"found {len(workshop_files)}"
        )
    workshop_file = workshop_files[0]

    OUTPUT.mkdir(parents=True, exist_ok=True)
    destination = OUTPUT / f"{workshop_id}.vpk"
    shutil.copy2(workshop_file, destination)
    print(f"Installed {destination.name}")


if len(sys.argv) != 2:
    raise SystemExit(f"Usage: {sys.argv[0]} COLLECTION_ID")

addon_ids = get_addon_ids(sys.argv[1])
download_addons(addon_ids)
