# Docker

Docker-образ на базе **Ubuntu 22.04** с набором биоинформатических программ для работы
с выравниваниями (SAM/BAM/CRAM) и вариантами (VCF/BCF).

## Состав образа

| Программа / библиотека | Версия | Дата релиза | Каталог установки |
|---|---|---|---|
| [libdeflate](https://github.com/ebiggers/libdeflate) | 1.25 | 2025-11-01 | `/soft/libdeflate-1.25` |
| [HTSlib](https://github.com/samtools/htslib) | 1.24 | 2026-07-09 | `/soft/htslib-1.24` |
| [SAMtools](https://github.com/samtools/samtools) | 1.24 | 2026-07-09 | `/soft/samtools-1.24` |
| [BCFtools](https://github.com/samtools/bcftools) | 1.24 | 2026-07-09 | `/soft/bcftools-1.24` |
| [VCFtools](https://github.com/vcftools/vcftools) | 0.1.17 | 2025-05-15 | `/soft/vcftools-0.1.17` |

## Переменные окружения

Корневой каталог со специализированным ПО задан переменной `$SOFT` = `/soft`.
Пути до исполняемых файлов добавлены в `PATH`, путь до Perl-модулей VCFtools — в `PERL5LIB`.

Дополнительно заданы переменные с полными путями до исполняемых файлов:

| Переменная | Значение |
|---|---|
| `$SAMTOOLS` | `/soft/samtools-1.24/bin/samtools` |
| `$BCFTOOLS` | `/soft/bcftools-1.24/bin/bcftools` |
| `$VCFTOOLS` | `/soft/vcftools-0.1.17/bin/vcftools` |

## Сборка Docker-образа

Из каталога с `Dockerfile`:

```bash
docker build -t bioinf-tools:1.0 .
```

Сборка без использования кэша:

```bash
docker build --no-cache -t bioinf-tools:1.0 .
```

## Запуск Docker-образа в интерактивном режиме

```bash
docker run -it --rm bioinf-tools:1.0
```

## Проверка корректности установки

Внутри контейнера:

```bash
# вызов через PATH
samtools --help
bcftools --help
vcftools --help

# вызов через переменные окружения с полными путями
$SAMTOOLS --version
$BCFTOOLS --version
$VCFTOOLS --version
```

Ожидаемый вывод `$SAMTOOLS --version` (первые строки):

```
samtools 1.24
Using htslib 1.24
```

## Структура образа

```
/soft
├── libdeflate-1.25
├── htslib-1.24
├── samtools-1.24
├── bcftools-1.24
└── vcftools-0.1.17
```
