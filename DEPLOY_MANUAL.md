# DVG (Dokdo Volunteer Garrison) Deployment Manual

## 1. 사전 요구사항 (Prerequisites)
적용할 대상 서버는 반드시 다음 조건을 만족해야 합니다.

### 하드웨어
- AMD SEV-SNP (또는 Intel TDX) 지원 물리 서버

### OS 및 필수 패키지
대상 서버(Ubuntu/Debian 권장)에 다음 패키지가 설치되어 있어야 합니다. (컴파일러는 필요 없습니다.)
```bash
sudo apt-get update
sudo apt-get install -y qemu-system-x86 qemu-utils ovmf nftables inotify-tools
```

### 필수 커널 모듈 활성화
```bash
sudo modprobe nft_dup_ipv4
sudo modprobe nf_dup_ipv4
sudo modprobe vhost_vsock
```

---

## 2. 파일 구성 (File Structure)
이 패키지는 오직 런타임 적용에 필요한 최소한의 바이너리와 스크립트로만 구성되어 있습니다. 소스 코드는 일절 포함되지 않습니다.

*   `bin/`
    *   `brain_os.bin` (완성된 뇌 OS)
    *   `muscle_os.bin` (완성된 근육 OS)
    *   `kraftlet` (완성된 오케스트레이터 데몬 리눅스 실행 파일)
*   `scripts/`
    *   `launch_brain.sh` (뇌 구동 쉘)
    *   `launch_muscle.sh` (근육 구동 쉘)
    *   `setup_mirror_routing.sh` (미러 트래픽 라우팅 세팅)
    *   `10ms_format_trigger.sh` (자폭 복구 감시자)

---

## 3. 설치 및 실행 (Execution)

### Step 1. 타겟 앱 위치 설정
보호하고자 하는 타겟 애플리케이션 데이터를 지정된 마운트 경로에 위치시킵니다.
```bash
mkdir -p target_dir
# 보호할 타겟 앱 데이터를 target_dir/ 안에 복사합니다.
# (예시: cp -r /var/www/my_secret_app/* ./target_dir/)

# [필수] Muscle OS 데몬이 E2E 페이로드 추출 시 사용할 더미 파일 생성
echo "[E2E_PAYLOAD]: OK" > ./target_dir/dummy.txt
```

### Step 2. 더미 파일 및 펌웨어 경로 확인
스크립트가 요구하는 경로에 필수 파일들이 존재하는지 확인합니다.
```bash
# 10ms 자폭 스크립트용 더미 파일 및 디스크 이미지 스냅샷
sudo touch /var/run/mirror_vm.pid
sudo touch /var/run/mirror_vm_escape_flag
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/mirror_vm.qcow2 10G
sudo qemu-img snapshot -c pristine /var/lib/libvirt/images/mirror_vm.qcow2


# OVMF 펌웨어 경로 확인 (Ubuntu 기본 경로)
ls -la /usr/share/OVMF/OVMF_CODE.fd
```

### Step 3. 실행
모든 준비가 끝났습니다. 데몬을 실행하여 하드웨어 암호화 덫을 가동합니다.
```bash
cd bin
sudo ./kraftlet
```
