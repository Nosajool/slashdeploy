require 'rails_helper'

RSpec.describe Environment, type: :model do
  describe '.named' do
    before do
      repo = Repository.with_name('remind101/acme-inc')
      repo.environments.create!(name: 'production', aliases: %w(prod p))
      repo.environments.create!(name: 'staging', aliases: %w(stage s))
    end

    it 'generates expected sql' do
      sql = Environment.named('production').to_sql
      expect(sql).to eq <<-SQL.strip_heredoc.strip
      SELECT "environments".* FROM "environments" WHERE ("environments"."name" = 'production' OR "environments"."aliases" @> '{production}')
      SQL
    end

    it 'finds by name' do
      relation = Environment.named('production')
      expect(relation.count).to eq 1
      expect(relation.first.name).to eq 'production'
    end

    it 'finds by alias' do
      relation = Environment.named('prod')
      expect(relation.count).to eq 1
      expect(relation.first.name).to eq 'production'
    end
  end

  describe '#in_channel' do
    it 'defaults to true for production environments' do
      environment = Environment.new(name: 'production')
      expect(environment.in_channel).to be_truthy
    end

    it 'defaults to false for other environments' do
      environment = Environment.new(name: 'staging')
      expect(environment.in_channel).to be_falsy
    end
  end

  describe '#aliases=' do
    it 'filters out aliases that match the name' do
      repo = Repository.with_name('remind101/acme-inc')
      environment = repo.environment('production')
      environment.aliases = %w(production prod)
      expect(environment.aliases).to eq %w(prod)

      environment.update_attributes! aliases: %w(production prod)
      environment.reload
      expect(environment.aliases).to eq %w(prod)
    end

    it 'does not allow you to create aliases that match a different environment for the same repository' do
      repo = Repository.with_name('remind101/acme-inc')
      production = repo.environment('production')
      production.update_attributes! aliases: %w(prod)

      staging = repo.environment('staging')
      staging.update_attributes aliases: %w(prod)
      expect(staging.errors[:aliases]).to eq ['includes the name of an existing environment for this repository']
    end
  end
end
