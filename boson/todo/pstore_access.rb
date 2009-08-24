# from http://d.hatena.ne.jp/authorNari/20070729#1185682996
require 'pstore'

class PstoreAccess

  def initialize(cols, file_name=(File.dirname(__FILE__) + "/pstore_test"))
    @@pstore = PStore.new(file_name)
    @@pstore.transaction do
      unless @@pstore["root"]
        @@pstore["root"] ||= {}
        @@pstore["max_id"] ||= 1
      end
    end
    @table = deploy_cols(cols)
  end

  def get_table
    @table.clone
  end

  def select_all
    @@pstore.transaction do
      res_all = @@pstore["root"].values
    end
  end

  def select_id(id)
    @@pstore.transaction do
      @@pstore["root"][id]
    end
  end

  def select(key, col_name)
    @@pstore.transaction do
      res = []
      @@pstore["root"].values.each do |row|
        res << row if row[col_name] == key
      end
      return res
    end
  end

  def insert(data)
    @@pstore.transaction do
      data["p_id"] = @@pstore["max_id"] += 1
      @@pstore["root"][@@pstore["max_id"]] = data
      @@pstore.commit
    end
  end

  def update(data, id)
    @@pstore.transaction do
      data['p_id'] = id
      @@pstore["root"][id] = data
      @@pstore.commit
    end
  end

  def update_where(data, key, col_name)
    @@pstore.transaction do
      @@pstore["root"].values.each do |row|
        if row[col_name] == key
          data['p_id'] = row['p_id']
          @@pstore["root"][row['p_id']] = data
        end
      end
      @@pstore.commit
    end    
  end

  def delete_id(id)
    @@pstore.transaction do
      @@pstore["root"].delete(id)
      @@pstore.commit
    end    
  end

  def delete_where(key, col_name)
    @@pstore.transaction do
      @@pstore["root"].values.each do |row|
        if row[col_name] == key
          @@pstore["root"].delete(row['p_id'])
        end
      end
      @@pstore.commit
    end    
  end

  private
  def deploy_cols(cols)
    table = {}
    cols = "p_id " + cols
    cols_array = cols.split
    cols_array.each do |i|
      table[i] = nil
    end
    table
  end
  
end

