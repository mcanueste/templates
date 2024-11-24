use clap::{Parser, Subcommand};

mod commands;

// Main CLI Struct
#[derive(Parser)]
#[command(name = "mycli")]
#[command(about = "A CLI tool for demonstrating clap", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

// Subcommands Enum
#[derive(Subcommand)]
enum Commands {
    Add {
        #[arg(short, long)]
        name: String,
    },
    Remove {
        #[arg(short, long)]
        id: u32,
    },
}

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Add { name } => {
            commands::add::execute(name);
        }
        Commands::Remove { id } => {
            commands::remove::execute(id);
        }
    }
}

