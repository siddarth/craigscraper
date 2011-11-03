require 'pstore'

class CraigVault

  def initialize
    # initialize vault
    @craig_vault = PStore.new('craig.vault')

    # initialize bundles
    @craig_vault.transaction(false) do
      if @craig_vault[:vault].nil?
        @craig_vault[:vault] = Hash.new
        puts "Initialized vault."
      end
    end
  end

  def exists?(title, address)
    exists = false
    @craig_vault.transaction(true) do
      exists = true if @craig_vault[:vault][address] == title
    end
    return exists
  end

  def store(title, address)
    @craig_vault.transaction do
      @craig_vault[:vault][address] = title
      @craig_vault.commit
    end
  end

  def process(title, address)
    if exists?(title, address)
      return false
    else
      store(title, address)
      return true
    end
  end
end