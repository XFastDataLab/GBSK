# GBSK

GBSK (Granular-Ball SKeleton clustering) is a MATLAB implementation for scalable clustering on large-scale data.
This repository packages the public code path, demo data, and reproduction entrypoints for [the accepted TPAMI paper](https://doi.org/10.1109/TPAMI.2026.3719829), including the [main script](./paper/GBSK%20main%20script.pdf) and [supplementary material](./paper/GBSK%20supplementary%20material.pdf).

## Quick Start

1. Open MATLAB R2021a or newer.
2. Add the repository to the MATLAB path:
   ```matlab
   addpath(genpath('path_to_GBSK'));
   ```
3. Run one of the public demos:
   - `algorithms/GBSK/demo1.m` for `Pendigits`
   - `algorithms/GBSK/demo2.m` for `MNIST`
   - `algorithms/GBSK/main_big.m` for `MNIST8M`

Outputs are written to `experiment outcomes/<dataset>/...` under the repository root.

## Repository Layout

- `algorithms/GBSK/`: unified GBSK / AGBSK entrypoints and shared MATLAB implementation
- `datasets/`: small datasets and demo datasets bundled with the release
- `demo/`: lightweight public demo wrappers and evaluation helper
- `experiment_records/`: historical run logs kept for reference

## Reproduction Scope

The public release focuses on the experiments explicitly described there:

- Visual demos: `SYN1`, `SYN2`, `SYN3`, `Twenty`, `Chainlink`
- Quality benchmarks: `S3`, `EngyTime`, `Twenty`, `Segmentation`, `Waveform`, `Pendigits`
- Large-scale benchmarks: `Pendigits`, `DryBean`, `MoCap`, `CoverType`, `3M2D5`, `MNIST`, `CIFAR-10`, `MNIST8M`, `AGC100M`
- Sensitivity analysis: `N-BaIoT`, `AGC100M`, `MNIST8M`
- Ablation study: `Pendigits`, `MNIST`, `N-BaIoT`, `MNIST8M`, `AGC100M`

For very large datasets, the repository keeps instructions and code paths, but not the raw data blobs by default.

## Datasets and Downloads

### Bundled in this repository

These datasets are already included under `datasets/` and should be used first when reproducing the public demos and small-scale experiments:

- `3M2D5`
- `DryBean`
- `MNIST`
- `MoCap Hand Postures` (`MoCap` in the paper)
- `Pendigits`
- `SYN1`
- `SYN2`
- `SYN3`
- `CoverType`
- `banana`

### External downloads from the appendix

The table below only lists links that are explicitly given in `appendices.tex`.
For large datasets, this README keeps the source link and usage note only; the raw data is not bundled by default.

| Dataset | Source | Labels | In repo | Note |
| --- | --- | --- | --- | --- |
| `Chainlink` | https://github.com/milaan9/Clustering-Datasets/blob/master/02.%20Synthetic/chainlink.csv | Yes | No | Synthetic demo data |
| `Twenty` | https://github.com/milaan9/Clustering-Datasets/blob/master/02.%20Synthetic/twenty.mat | Yes | No | Synthetic demo data |
| `EngyTime` | https://github.com/milaan9/Clustering-Datasets/blob/master/02.%20Synthetic/engytime.arff | Yes | No | Synthetic benchmark |
| `S3` | https://cs.joensuu.fi/sipu/datasets/s3.txt | Yes | No | Synthetic benchmark |
| `Segmentation` | https://doi.org/10.24432/C5P01G | Yes | No | UCI-style real dataset |
| `Waveform` | https://doi.org/10.24432/C5CS3C | Yes | No | Real benchmark |
| `Pendigits` | https://doi.org/10.24432/C5MG6K | Yes | Yes | Prefer the bundled copy |
| `DryBean` | https://doi.org/10.24432/C50S4B | Yes | Yes | Prefer the bundled copy |
| `CIFAR-10` | https://api.semanticscholar.org/CorpusID:18268744 | Yes | No | Large-scale benchmark |
| `MNIST` | https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/multiclass.html#mnist | Yes | Yes | Prefer the bundled copy |
| `MoCap` | https://doi.org/10.24432/C5960R | Yes | Yes | Prefer the bundled copy |
| `RCV1` | https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/multiclass.html#rcv1.multiclass | Yes | No | Large-scale benchmark |
| `CoverType` | https://doi.org/10.24432/C50K5N | Yes | Yes | Prefer the bundled copy |
| `3M2D5` | No external link given in appendix | Yes | Yes | Prefer the bundled copy |
| `N-BaIoT` | https://www.kaggle.com/datasets/mkashifn/nbaiot-dataset | No | No | Very large dataset; download separately |
| `MNIST8M` | https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/multiclass.html#mnist8m | Yes | No | Very large dataset; download separately |
| `AGC100M` | https://www.kaggle.com/datasets/caatic7/agc100m | Yes | No | Very large dataset; download separately |

### Loader notes

- The MATLAB loader resolves files by dataset name and standard filenames such as `data.mat`, `data.txt`, or `<dataset_name>_data.h5`.
- For bundled datasets, the repository copy is the recommended default.
- For missing or very large datasets, use the appendix source links above and keep the downloaded files outside the repo if desired.

## Reproducible Runs

The MATLAB shared entrypoint is `algorithms/GBSK/run_gbsk.m`.
It accepts a data matrix and a config struct with:

- `datasetName`
- `resultsRoot`
- `k`
- `numSampleSets`
- `alpha`
- `multiplierM`
- `seed`

Default AGBSK settings use `alpha = 1/sqrt(n)` and `M = 10*k`.

## Output Files

Each run writes a folder with:

- `labels.txt`
- `aggRepBallCenters.txt`
- `keyBallCenters.txt`
- `log.txt`

The log stores the seed, parameters, total runtime, and per-step runtimes.

## Smoke Test

A smoke test checks that the public entrypoints, dataset resolver, output writing, and metric reader work end to end on a small dataset.

For this repository, the recommended smoke-test set is:

- `algorithms/GBSK/demo1.m` on `Pendigits`
- `algorithms/GBSK/demo2.m` on `MNIST`
- `algorithms/GBSK/main.m` on `3M2D5`
- one competing baseline demo on the same small dataset, such as `algorithms/KMeansPlus/KMeansPlus.m` or `algorithms/FHC-LDP/main.m` when its dataset is available

Pass criteria:

- the script runs without hardcoded-path edits
- result files are written under `experiment outcomes/`
- `labels.txt` can be consumed by the evaluation helper
- missing large datasets fail fast with a clear message instead of a silent fallback

## Evaluation

To compute ACC / ARI / AMI from saved labels, run:

```bash
python demo/ClusteringQualityEvaluation.py
```

Edit the dataset name and label paths inside the script if you are evaluating a different dataset.

## Reproduction Manifest

See `reproduction_manifest.json` for a machine-readable list of the paper’s main experiment groups.

## Citation

```bibtex
@ARTICLE{11641755,
  author={Chen, Yewang and Li, Junfeng and Xia, Shuyin and Lai, Qinghong and Gao, Xinbo and Wang, Guoyin and Cheng, Dongdong and Liu, Yi and Wang, Yi},
  journal={IEEE Transactions on Pattern Analysis and Machine Intelligence}, 
  title={GBSK: Skeleton Clustering via Granular-ball Computing and Multi-Sampling for Large-Scale Data}, 
  year={2026},
  volume={},
  number={},
  pages={1-13},
  keywords={Skeleton;Algorithms;Educational institutions;Labeling;Machining;Timing;Conferences;Runtime;Accuracy;Computers;Granular-ball;Skeleton Clustering;Multiple Sampling;KDE},
  doi={10.1109/TPAMI.2026.3719825}}
```

## 中文快速开始

- 论文正文以 `./paper/GBSK main script.pdf` 为准。
- 运行 `algorithms/GBSK/demo1.m` 或 `demo/demo1.m` 可直接看 `Pendigits` 示例。
- 大规模实验建议先准备对应数据，再运行 `algorithms/GBSK/main_big.m`。
