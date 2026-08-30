import shutil
import subprocess
import sys
from pathlib import Path

import requests


STEAMCMD = Path("/home/louis/steamcmd.sh")
# L4D2 App ID
APP_ID = "550"
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


def download_addon(workshop_id: str) -> None:
    subprocess.run(
        [
            str(STEAMCMD),
            "+force_install_dir",
            str(DOWNLOAD_ROOT),
            "+login",
            "anonymous",
            "+workshop_download_item",
            APP_ID,
            workshop_id,
            "validate",
            "+quit",
        ],
        check=True,
    )

    downloaded = (
        DOWNLOAD_ROOT
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

for addon_id in get_addon_ids(sys.argv[1]):
    download_addon(addon_id)
