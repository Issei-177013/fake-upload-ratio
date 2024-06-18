import os
import requests
import time
from tqdm import tqdm

def download_file(url, destination, max_speed=102400, timeout=180):
    response = requests.get(url, stream=True)
    total_size = int(response.headers.get('content-length', 0))
    downloaded_size = 0
    start_time = time.time()

    try:
        with open(destination, 'wb') as f, tqdm(
            desc=destination,
            total=total_size,
            unit='B',
            unit_scale=True
        ) as pbar:
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    f.write(chunk)
                    downloaded_size += len(chunk)
                    pbar.update(len(chunk))
                    
                    elapsed_time = time.time() - start_time
                    if elapsed_time > 0:
                        download_speed = downloaded_size / elapsed_time
                    else:
                        download_speed = 0
                    
                    if download_speed > max_speed:
                        time_to_sleep = (downloaded_size / max_speed) - elapsed_time
                        if time_to_sleep > 0:
                            time.sleep(time_to_sleep)
                    
                    if elapsed_time > timeout:
                        raise TimeoutError("Download timed out")
    
    except TimeoutError:
        print("\nDownload timed out!")
        os.remove(destination)
    except Exception as e:
        print(f"\nAn error occurred: {e}")
    else:
        print("\nDownload completed!")

def main():
    file_path = "urls.txt"
    with open(file_path, "r") as file:
        urls = file.readlines()

    for url in urls:
        url = url.strip()
        if url:
            file_name = url.split("/")[-1]
            print(f"Downloading file from: {url}")
            download_file(url, file_name, max_speed=12000 * 1024, timeout=180)
            
            try:
                os.remove(file_name)
                print(f"File {file_name} removed!\n")
            except FileNotFoundError:
                print(f"File {file_name} not found!\n")

if __name__ == "__main__":
    main()
