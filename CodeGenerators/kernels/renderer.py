
import os
import re
import json
import datetime
import argparse
import inspect
from pathlib import Path
from jinja2 import Environment, FileSystemLoader,TemplateNotFound


ROOT_DIR = Path(__file__).resolve().parent.parent.parent
OUTPUT_DIR =  ROOT_DIR / "src" / "shared" / "NDarray" / "kernels"
TEMPLATES_ENV_DIR = ROOT_DIR / "CodeGenerators" / "kernels"
CONFIG_FILE = ROOT_DIR / "CodeGenerators" / "kernels" / ".config.json"
CONTEXT_FILE = ROOT_DIR / "CodeGenerators" / "kernels" / "context.json"

with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
    CONFIG = json.load(f)   
with open(CONTEXT_FILE, 'r', encoding='utf-8') as f:
    CONTEXT = json.load(f)   

env = Environment(loader=FileSystemLoader(TEMPLATES_ENV_DIR))


def generate_kernel(dtype:str):
    value_type = CONTEXT["DataType"].get(dtype if dtype[0] == "f" else dtype[0])
    if not value_type:
        raise KeyError(f"DataType '{dtype}' not found in context.json.")

    config = CONFIG.get(dtype)
    if not config:
        raise KeyError(f"Configuration for '{dtype}' not found in .config.json.")


    bit_count = int("".join(filter(str.isdigit, dtype)))
    byte_count = bit_count // 8 if bit_count else 1
    
   
    try:
        template = env.get_template("template.luau.j2")
    except TemplateNotFound :
        raise FileNotFoundError(f"Template for not found in '{TEMPLATES_ENV_DIR}'.")

  
    rendered_code = template.render(
        dtype=dtype,
        value_type=value_type,
        byte_size=byte_count,
        date=datetime.datetime.now().strftime("%Y-%m-%d %H:%M"),
        arithmetic_operators=CONTEXT["ArithmeticOperators"],
        config=CONFIG.get(dtype), 
    )

    clean_lines = ["--!strict"] + ["--!optimize 2"] + [
        line for line in rendered_code.splitlines() 
        if not line.strip().startswith("--!")
    ]

    #formating for readability

    final_code = "\n".join(clean_lines)

    final_code = re.sub(r"[ \t]+$", "", final_code, flags=re.MULTILINE)

    final_code = re.sub(r"\n{3,}", "\n\n", final_code)

    output_path = Path(OUTPUT_DIR) / f"{dtype}.kernel.luau"
    output_path.write_text(final_code, encoding="utf-8")

    print(f"\n{dtype} Kernel is generated in {OUTPUT_DIR}.\n")


def main():
    parser = argparse.ArgumentParser(description="NDArray kernel generator.")

    parser.add_argument('dtypes', metavar='DTYPE', type=str, nargs='+')

    args = parser.parse_args()

    for dtype in args.dtypes:
        generate_kernel(dtype)

if __name__ == "__main__":
    main()