class FixSchemaErrorForBlogging < ActiveRecord::Migration
  def change
  	  create_table "monologue_posts", force: true do |t|
	    t.boolean  "published"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	    t.integer  "user_id"
	    t.string   "title"
	    t.text     "content"
	    t.string   "url"
	    t.datetime "published_at"
	  end

	  add_index "monologue_posts", ["url"], name: "index_monologue_posts_on_url", unique: true

	  create_table "monologue_taggings", force: true do |t|
	    t.integer "post_id"
	    t.integer "tag_id"
	  end

	  add_index "monologue_taggings", ["post_id"], name: "index_monologue_taggings_on_post_id"
	  add_index "monologue_taggings", ["tag_id"], name: "index_monologue_taggings_on_tag_id"

	  create_table "monologue_tags", force: true do |t|
	    t.string "name"
	  end

	  add_index "monologue_tags", ["name"], name: "index_monologue_tags_on_name"

	  create_table "monologue_users", force: true do |t|
	    t.string   "name"
	    t.string   "email"
	    t.string   "password_digest"
	    t.datetime "created_at"
	    t.datetime "updated_at"
	  end
  end
end
