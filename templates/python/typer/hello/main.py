"""Main module of the CLI."""

import typer


def main() -> None:
    "'Hello Worl' CLI."
    print("Hello World")


if __name__ == "__main__":
    typer.run(main)
