# Release Process

คู่มือการ release Helm charts สำหรับโปรเจกต์ OneChart

## ภาพรวม

โปรเจกต์นี้ใช้ GitHub Actions สำหรับการ release อัตโนมัติ โดยจะ package และ publish Helm charts ไปยัง:
- **GitHub Pages**: https://minkbear.github.io/onechart (Traditional Helm repository)
- **OCI Registry**: oci://ghcr.io/minkbear (GitHub Container Registry)

Charts ที่จะถูก release:
- `onechart` - Generic Helm chart สำหรับ application deployments
- `cron-job` - Helm chart สำหรับ CronJob workloads
- `static-site` - Helm chart สำหรับ static site deployments

## Prerequisites

### ความต้องการ
- Git access และสิทธิ์สร้าง tags ใน repository
- GitHub repository ต้องมี secret `HELM_TOKEN` สำหรับ push ไปยัง GHCR

### Tools ที่ต้องติดตั้ง (สำหรับ manual release)
```bash
# Helm
brew install helm

# Helm plugins
helm plugin install https://github.com/helm-unittest/helm-unittest

# kubeval (optional - สำหรับ validation)
brew install kubeval
```

## Version Management

โปรเจกต์ใช้ [Semantic Versioning](https://semver.org/) ในรูปแบบ `MAJOR.MINOR.PATCH`:

- **MAJOR**: Breaking changes ที่ไม่สามารถ backward compatible ได้
- **MINOR**: เพิ่มฟีเจอร์ใหม่แบบ backward compatible
- **PATCH**: Bug fixes แบบ backward compatible

### Version Synchronization

**สำคัญ**: เวอร์ชันของทั้ง 3 charts ต้องเหมือนกันเสมอ
- `charts/onechart/Chart.yaml`
- `charts/cron-job/Chart.yaml`
- `charts/static-site/Chart.yaml`

GitHub Actions จะตรวจสอบความถูกต้องอัตโนมัติก่อน release

## Release Steps

### Option 1: Automated Release (แนะนำ)

#### 1. เตรียม Release

ตรวจสอบและอัพเดทเวอร์ชันในไฟล์ Chart.yaml ทั้ง 3 ไฟล์:

```bash
# ตรวจสอบเวอร์ชันปัจจุบัน
grep "^version:" charts/*/Chart.yaml

# ผลลัพธ์ควรจะเป็น
# charts/cron-job/Chart.yaml:version: 0.74.0
# charts/onechart/Chart.yaml:version: 0.74.0
# charts/static-site/Chart.yaml:version: 0.74.0
```

หากต้องการเปลี่ยนเวอร์ชัน ให้แก้ไขไฟล์ `Chart.yaml` ทั้ง 3 ไฟล์ให้มีเวอร์ชันเดียวกัน

#### 2. Run Tests

ตรวจสอบว่าทุกอย่างทำงานได้ถูกต้อง:

```bash
# รัน test suite ทั้งหมด
make all

# หรือรันแยกส่วน
make lint      # Helm lint
make kubeval   # Kubernetes manifest validation
make test      # Helm unit tests
make package   # Package charts
```

#### 3. Commit และ Push Changes

```bash
git add .
git commit -m "Prepare release v0.74.0"
git push origin master
```

#### 4. สร้างและ Push Git Tag

```bash
# สร้าง tag (ต้องมี prefix 'v')
git tag v0.74.0

# Push tag ไปยัง GitHub
git push origin v0.74.0
```

#### 5. ตรวจสอบ GitHub Actions

เมื่อ push tag แล้ว GitHub Actions จะทำงานอัตโนมัติ:

1. ไปที่ https://github.com/minkbear/onechart/actions
2. ดู workflow run "Release"
3. รอจนกว่า workflow จะเสร็จสมบูรณ์

### Option 2: Manual Release

สำหรับกรณีที่ต้องการ release แบบ manual หรือทดสอบก่อน push:

```bash
# 1. Update dependencies และ run tests
make all

# 2. ตรวจสอบไฟล์ที่ถูกสร้าง
ls -lh docs/*.tgz

# 3. สร้าง GitHub Release manually
# ไปที่ https://github.com/minkbear/onechart/releases/new
# สร้าง release ด้วย tag v0.74.0

# 4. Push to GHCR (ต้องมี HELM_TOKEN)
echo $HELM_TOKEN | helm registry login ghcr.io --username minkbear --password-stdin
helm push docs/onechart-0.74.0.tgz oci://ghcr.io/minkbear
helm push docs/cron-job-0.74.0.tgz oci://ghcr.io/minkbear
helm push docs/static-site-0.74.0.tgz oci://ghcr.io/minkbear
```

## GitHub Actions Workflow Details

ไฟล์: [.github/workflows/release.yml](.github/workflows/release.yml)

### Trigger
Workflow จะทำงานเมื่อมี tag ที่ขึ้นต้นด้วย `v` ถูก push

### Steps Overview

1. **Extract Versions**
   - ดึงเวอร์ชันจาก Git tag
   - ดึงเวอร์ชันจาก Chart.yaml ทั้ง 3 charts

2. **Version Validation**
   - ตรวจสอบว่า tag version ตรงกับ chart versions หรือไม่
   - หากไม่ตรงกัน workflow จะ fail

3. **Create GitHub Release**
   - สร้าง GitHub Release อัตโนมัติ
   - ใช้ tag version เป็นชื่อ release

4. **Package Helm Charts**
   - Run `make package` เพื่อสร้าง `.tgz` files
   - สร้างไฟล์ใน `docs/` directory
   - อัพเดท `docs/index.yaml` (Helm repository index)

5. **Publish to GitHub Pages**
   - Commit และ push `docs/` directory ไปยัง `master`
   - GitHub Pages จะ serve อัตโนมัติจาก `docs/` folder

6. **Publish to GitHub Container Registry (GHCR)**
   - Login to ghcr.io ด้วย `HELM_TOKEN`
   - Push charts ไปยัง `oci://ghcr.io/minkbear`

7. **Auto Version Bump**
   - เพิ่ม minor version อัตโนมัติ
   - เช่น `0.74.0` → `0.75.0`
   - อัพเดท Chart.yaml ทั้ง 3 ไฟล์
   - Commit และ push กลับ `master`

### Required Secrets

ต้องตั้งค่า secret ใน GitHub repository:

```
HELM_TOKEN - GitHub Personal Access Token สำหรับ push ไปยัง GHCR
  Permissions: write:packages, read:packages
```

## Post-Release Verification

### 1. ตรวจสอบ GitHub Release
```bash
# ดูที่ Releases page
open https://github.com/minkbear/onechart/releases
```

### 2. ตรวจสอบ GitHub Pages
```bash
# Test Helm repository
helm repo add onechart-test https://minkbear.github.io/onechart
helm repo update
helm search repo onechart-test/onechart --versions | head -5

# ควรเห็นเวอร์ชันใหม่ (0.74.0)
```

### 3. ตรวจสอบ OCI Registry
```bash
# Pull from GHCR
helm pull oci://ghcr.io/minkbear/onechart --version 0.74.0
helm pull oci://ghcr.io/minkbear/cron-job --version 0.74.0
helm pull oci://ghcr.io/minkbear/static-site --version 0.74.0
```

### 4. ตรวจสอบ Version Bump
```bash
# ตรวจสอบว่า master branch มี version bump แล้ว
git pull origin master
grep "^version:" charts/*/Chart.yaml

# ควรเห็นเวอร์ชันถัดไป (เช่น 0.75.0)
```


## Troubleshooting

### ❌ Workflow Failed: Version Mismatch

**ปัญหา**: Tag version ไม่ตรงกับ Chart.yaml version

**วิธีแก้**:
```bash
# 1. ลบ tag
git tag -d v0.74.0
git push --delete origin v0.74.0

# 2. แก้ไข Chart.yaml ให้ตรงกับ tag
# แก้ไขทั้ง 3 ไฟล์ให้เป็น 0.74.0

# 3. Commit และ push
git add .
git commit -m "Fix version to 0.74.0"
git push origin master

# 4. สร้าง tag ใหม่
git tag v0.74.0
git push origin v0.74.0
```

### ❌ GHCR Push Failed

**ปัญหา**: ไม่สามารถ push ไปยัง GitHub Container Registry ได้

**วิธีแก้**:
1. ตรวจสอบว่ามี `HELM_TOKEN` secret ใน repository settings
2. ตรวจสอบว่า token มี permission `write:packages`
3. ตรวจสอบว่า package name ถูกต้อง (`ghcr.io/minkbear`)

### ❌ Tests Failed

**ปัญหา**: `make all` หรือ unit tests fail

**วิธีแก้**:
```bash
# ดู error messages
make lint
make test

# แก้ไข templates หรือ tests ตาม error messages
# จากนั้น run tests อีกครั้ง
```

### ❌ Version Bump Conflict

**ปัญหา**: Auto version bump สร้าง conflict

**วิธีแก้**:
- ไม่ควรแก้ไข master ในช่วงที่ workflow กำลังทำงาน
- รอให้ workflow เสร็จสิ้น แล้วค่อย pull master
- หากเกิด conflict ให้ resolve แล้ว push

## Release Channels

### 1. GitHub Pages (Helm Repository)
- URL: https://minkbear.github.io/onechart
- Type: Traditional Helm repository
- Authentication: ไม่ต้อง

**การใช้งาน**:
```bash
helm repo add onechart https://minkbear.github.io/onechart
helm repo update
helm install my-app onechart/onechart --version 0.74.0
```

### 2. OCI Registry (GHCR)
- URL: oci://ghcr.io/minkbear
- Type: OCI-based registry
- Authentication: ไม่ต้อง (packages เป็น public)
- Packages:
  - `oci://ghcr.io/minkbear/onechart`
  - `oci://ghcr.io/minkbear/cron-job`
  - `oci://ghcr.io/minkbear/static-site`

**การใช้งาน**:
```bash
helm install my-app oci://ghcr.io/minkbear/onechart --version 0.74.0
helm pull oci://ghcr.io/minkbear/onechart --version 0.74.0
```

## Best Practices

### 1. Pre-Release Checklist
- [ ] Run `make all` และผ่านทั้งหมด
- [ ] ตรวจสอบ CHANGELOG (ถ้ามี)
- [ ] อัพเดทเวอร์ชันทั้ง 3 charts ให้เหมือนกัน
- [ ] ตรวจสอบ breaking changes และอัพเดทเอกสาร
- [ ] Test กับ values files ตัวอย่าง

### 2. Version Strategy
- **Patch release (0.74.x)**: Bug fixes, minor tweaks
- **Minor release (0.x.0)**: New features, เพิ่มฟีลด์ใหม่
- **Major release (x.0.0)**: Breaking changes, เปลี่ยน API

### 3. Release Frequency
- Patch releases: ตามความจำเป็น (bug fixes)
- Minor releases: ทุก 2-4 สัปดาห์ (feature additions)
- Major releases: เมื่อมี breaking changes เท่านั้น

### 4. Communication
- สร้าง GitHub Release notes ที่ชัดเจน
- ระบุ breaking changes อย่างชัดเจน
- ให้ migration guide สำหรับ major releases

## Quick Reference

```bash
# ตรวจสอบเวอร์ชันปัจจุบัน
grep "^version:" charts/*/Chart.yaml

# Run full test suite
make all

# สร้าง release
git tag v0.74.0
git push origin v0.74.0

# ดู workflow status
open https://github.com/minkbear/onechart/actions

# ตรวจสอบ release
helm pull oci://ghcr.io/minkbear/onechart --version 0.74.0
```

## Related Files

- [.github/workflows/release.yml](.github/workflows/release.yml) - Release automation
- [Makefile](Makefile) - Build และ test commands
- [charts/onechart/Chart.yaml](charts/onechart/Chart.yaml) - OneChart version
- [charts/cron-job/Chart.yaml](charts/cron-job/Chart.yaml) - CronJob chart version
- [charts/static-site/Chart.yaml](charts/static-site/Chart.yaml) - Static site chart version
