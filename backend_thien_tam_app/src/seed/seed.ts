import dotenv from "dotenv";
dotenv.config();
import { connectDB } from "../db";
import Reading from "../models/Reading";
import Topic from "../models/Topic";
import { startOfLocalDay } from "../utils/date";

// Authentic Buddhist topics based on traditional teachings
const authenticTopics = [
  {
    name: 'Tứ Diệu Đế',
    slug: 'tu-dieu-de',
    description: 'Bốn chân lý cao quý - nền tảng của giáo lý Phật giáo.',
    color: '#4CAF50', // Green
    icon: 'spa',
    isActive: true,
    sortOrder: 10,
  },
  {
    name: 'Bát Chánh Đạo',
    slug: 'bat-chanh-dao',
    description: 'Con đường tám nhánh dẫn đến giác ngộ.',
    color: '#2196F3', // Blue
    icon: 'route',
    isActive: true,
    sortOrder: 20,
  },
  {
    name: 'Từ Bi',
    slug: 'tu-bi',
    description: 'Tình yêu thương và lòng trắc ẩn đối với tất cả chúng sinh.',
    color: '#F44336', // Red
    icon: 'favorite',
    isActive: true,
    sortOrder: 30,
  },
  {
    name: 'Chính Niệm',
    slug: 'chinh-niem',
    description: 'Thực hành chính niệm trong đời sống hàng ngày.',
    color: '#FF9800', // Orange
    icon: 'psychology',
    isActive: true,
    sortOrder: 40,
  },
  {
    name: 'Vô Thường',
    slug: 'vo-thuong',
    description: 'Tính chất thay đổi của mọi sự vật và hiện tượng.',
    color: '#9C27B0', // Purple
    icon: 'schedule',
    isActive: true,
    sortOrder: 50,
  },
  {
    name: 'Nhân Quả',
    slug: 'nhan-qua',
    description: 'Luật nhân quả và nghiệp trong Phật giáo.',
    color: '#00BCD4', // Cyan
    icon: 'timeline',
    isActive: true,
    sortOrder: 60,
  },
  {
    name: 'Giải Thoát',
    slug: 'giai-thoat',
    description: 'Sự giải thoát khỏi khổ đau và luân hồi.',
    color: '#795548', // Brown
    icon: 'flight',
    isActive: true,
    sortOrder: 70,
  },
  {
    name: 'Kinh Điển',
    slug: 'kinh-dien',
    description: 'Những bài kinh quan trọng và lời dạy của Đức Phật.',
    color: '#607D8B', // Blue Grey
    icon: 'menu_book',
    isActive: true,
    sortOrder: 80,
  },
];

// Authentic Buddhist readings with real sources
const authenticReadings = [
  {
    title: 'Tứ Diệu Đế - Chân Lý Thứ Nhất: Khổ Đế',
    body: `"Này các Tỳ-kheo, đây là chân lý cao quý về khổ đau: Sanh là khổ, già là khổ, bệnh là khổ, chết là khổ, phải xa lìa những gì mình yêu thích là khổ, phải gặp những gì mình không ưa thích là khổ, không đạt được những gì mình mong muốn là khổ. Tóm lại, năm thủ uẩn là khổ."

Đức Phật đã chỉ ra rằng khổ đau là một thực tế không thể tránh khỏi trong cuộc sống. Không phải là bi quan, mà là nhận thức rõ ràng về bản chất của cuộc sống để có thể vượt qua nó.

Khi chúng ta hiểu được khổ đau không phải là điều gì đó cần phải tránh né, mà là điều cần được nhận diện và chuyển hóa, chúng ta sẽ có được sự bình an nội tâm thực sự.`,
    topicSlugs: ['tu-dieu-de', 'vo-thuong'],
    keywords: ['khổ đế', 'tứ diệu đế', 'khổ đau', 'thực tế cuộc sống'],
    source: 'Kinh Chuyển Pháp Luân (Dhammacakkappavattana Sutta)',
    lang: 'vi',
  },
  {
    title: 'Bát Chánh Đạo - Chính Kiến',
    body: `"Này các Tỳ-kheo, đây là chân lý cao quý về con đường dẫn đến chấm dứt khổ đau: Đó là Bát Chánh Đạo, tức là: Chính Kiến, Chính Tư Duy, Chính Ngữ, Chính Nghiệp, Chính Mạng, Chính Tinh Tấn, Chính Niệm, Chính Định."

Chính Kiến là nhận thức đúng đắn về bản chất của cuộc sống, về Tứ Diệu Đế, về luật nhân quả. Đây là nền tảng của tất cả các bước tiếp theo trên con đường tu tập.

Khi có chính kiến, chúng ta sẽ thấy rõ được đâu là thiện, đâu là ác, đâu là đúng, đâu là sai. Từ đó, mọi hành động, lời nói và suy nghĩ của chúng ta sẽ được hướng dẫn bởi trí tuệ chứ không phải bởi tham ái hay sân hận.`,
    topicSlugs: ['bat-chanh-dao', 'nhan-qua'],
    keywords: ['chính kiến', 'bát chánh đạo', 'trí tuệ', 'nhận thức'],
    source: 'Kinh Chuyển Pháp Luân (Dhammacakkappavattana Sutta)',
    lang: 'vi',
  },
  {
    title: 'Từ Bi - Tình Yêu Thương Vô Điều Kiện',
    body: `"Như một người mẹ có thể hy sinh mạng sống để bảo vệ đứa con duy nhất của mình, cũng vậy, hãy phát triển tình yêu thương vô hạn đối với tất cả chúng sinh."

Từ bi không phải là cảm xúc yếu đuối hay thương hại, mà là sức mạnh nội tâm giúp chúng ta vượt qua sự ích kỷ và hận thù. Đó là khả năng cảm nhận được nỗi đau của người khác và mong muốn giúp họ thoát khỏi khổ đau.

Khi thực hành từ bi, chúng ta không chỉ giúp đỡ người khác mà còn tự giải thoát mình khỏi những cảm xúc tiêu cực như sân hận, ganh ghét và thù địch.`,
    topicSlugs: ['tu-bi', 'chinh-niem'],
    keywords: ['từ bi', 'yêu thương', 'vô điều kiện', 'chúng sinh'],
    source: 'Kinh Từ Bi (Metta Sutta)',
    lang: 'vi',
  },
  {
    title: 'Chính Niệm - Sống Trong Hiện Tại',
    body: `"Quá khứ đã qua, tương lai chưa đến. Chỉ có hiện tại là thực tại duy nhất mà chúng ta có thể sống."

Chính niệm là khả năng ý thức rõ ràng về những gì đang xảy ra trong giây phút hiện tại, không phán xét, không phản ứng. Đó là nghệ thuật sống trọn vẹn trong từng khoảnh khắc.

Khi thực hành chính niệm, chúng ta sẽ nhận ra rằng hầu hết những lo lắng và phiền muộn của chúng ta đều liên quan đến quá khứ hoặc tương lai. Chỉ khi sống trong hiện tại, chúng ta mới có thể tìm thấy sự bình an thực sự.`,
    topicSlugs: ['chinh-niem', 'vo-thuong'],
    keywords: ['chính niệm', 'hiện tại', 'ý thức', 'bình an'],
    source: 'Kinh Niệm Xứ (Satipatthana Sutta)',
    lang: 'vi',
  },
  {
    title: 'Vô Thường - Bản Chất Của Cuộc Sống',
    body: `"Tất cả các pháp hữu vi đều vô thường. Hãy tinh tấn để đạt được giải thoát."

Vô thường không có nghĩa là cuộc sống không có ý nghĩa, mà ngược lại, nó cho chúng ta thấy giá trị quý báu của từng khoảnh khắc. Mọi thứ đều thay đổi - đó là quy luật tự nhiên của vũ trụ.

Khi chấp nhận vô thường, chúng ta sẽ không còn bám víu vào những thứ tạm thời, không còn sợ hãi trước sự thay đổi. Thay vào đó, chúng ta sẽ sống với lòng biết ơn và trân trọng từng khoảnh khắc hiện tại.`,
    topicSlugs: ['vo-thuong', 'giai-thoat'],
    keywords: ['vô thường', 'thay đổi', 'tạm thời', 'quy luật'],
    source: 'Kinh Vô Thường (Anicca Sutta)',
    lang: 'vi',
  },
  {
    title: 'Nhân Quả - Luật Của Vũ Trụ',
    body: `"Này các Tỳ-kheo, nghiệp là chủ sở hữu, nghiệp là thừa kế, nghiệp là thai tạng, nghiệp là quyến thuộc, nghiệp là nơi nương tựa."

Luật nhân quả không phải là sự trừng phạt hay thưởng phạt, mà là quy luật tự nhiên của vũ trụ. Mọi hành động đều có hậu quả tương ứng, không chỉ trong đời này mà còn trong những đời sau.

Khi hiểu rõ luật nhân quả, chúng ta sẽ có trách nhiệm hơn với mọi hành động của mình. Chúng ta sẽ cẩn thận trong việc gieo nhân thiện và tránh gieo nhân ác, vì biết rằng những gì chúng ta gieo hôm nay sẽ là những gì chúng ta gặt hái trong tương lai.`,
    topicSlugs: ['nhan-qua', 'tu-dieu-de'],
    keywords: ['nhân quả', 'nghiệp', 'hành động', 'hậu quả'],
    source: 'Kinh Nghiệp (Kamma Sutta)',
    lang: 'vi',
  },
  {
    title: 'Giải Thoát - Mục Đích Tối Thượng',
    body: `"Này các Tỳ-kheo, như biển cả chỉ có một vị là vị mặn, cũng vậy, giáo pháp này chỉ có một vị là vị giải thoát."

Giải thoát không có nghĩa là trốn chạy khỏi cuộc sống, mà là giải phóng tâm trí khỏi những ràng buộc của tham ái, sân hận và si mê. Đó là trạng thái tự do hoàn toàn của tâm hồn.

Khi đạt được giải thoát, chúng ta sẽ không còn bị chi phối bởi những cảm xúc tiêu cực, không còn bị ràng buộc bởi những dục vọng vô tận. Chúng ta sẽ sống với sự bình an và hạnh phúc chân thực.`,
    topicSlugs: ['giai-thoat', 'bat-chanh-dao'],
    keywords: ['giải thoát', 'tự do', 'bình an', 'hạnh phúc'],
    source: 'Kinh Giải Thoát (Vimutti Sutta)',
    lang: 'vi',
  },
  {
    title: 'Kinh Pháp Cú - Câu 1',
    body: `"Tâm dẫn đầu các pháp, tâm làm chủ, tâm tạo tác. Nếu nói hoặc làm với tâm ô nhiễm, thì khổ đau sẽ theo sau như bánh xe theo chân con bò kéo xe."

Câu kinh đầu tiên trong Kinh Pháp Cú nhấn mạnh tầm quan trọng của tâm trong việc tạo ra hạnh phúc hay khổ đau. Tâm là nguồn gốc của mọi hành động và là nơi quyết định chất lượng cuộc sống của chúng ta.

Khi chúng ta có thể làm chủ được tâm mình, chúng ta sẽ có thể làm chủ được cuộc sống. Mọi hành động, lời nói và suy nghĩ đều xuất phát từ tâm, vì vậy việc tu dưỡng tâm là điều quan trọng nhất trong đời sống tu tập.`,
    topicSlugs: ['kinh-dien', 'chinh-niem'],
    keywords: ['tâm', 'pháp cú', 'làm chủ', 'tu dưỡng'],
    source: 'Kinh Pháp Cú (Dhammapada) - Câu 1',
    lang: 'vi',
  },
  {
    title: 'Kinh Pháp Cú - Câu 5',
    body: `"Ở đây, người ta không thể làm cho kẻ thù hận thù mình ngừng hận thù bằng cách hận thù lại. Chỉ có thể làm cho kẻ thù ngừng hận thù bằng cách không hận thù. Đây là quy luật vĩnh cửu."

Câu kinh này dạy chúng ta về sức mạnh của tình yêu thương và sự tha thứ. Hận thù chỉ sinh ra hận thù, chỉ có tình yêu thương mới có thể chuyển hóa hận thù thành hòa bình.

Trong cuộc sống, khi gặp phải những người làm tổn thương chúng ta, phản ứng tự nhiên là muốn trả đũa. Nhưng Đức Phật dạy rằng cách tốt nhất để đối phó với hận thù là không hận thù lại, mà thay vào đó là đáp lại bằng tình yêu thương và sự tha thứ.`,
    topicSlugs: ['tu-bi', 'kinh-dien'],
    keywords: ['hận thù', 'tha thứ', 'yêu thương', 'hòa bình'],
    source: 'Kinh Pháp Cú (Dhammapada) - Câu 5',
    lang: 'vi',
  },
  {
    title: 'Kinh Pháp Cú - Câu 103',
    body: `"Dù có đánh nhau cả ngàn lần với một ngàn người, nhưng nếu có thể chiến thắng chính mình thì đó mới là chiến thắng vĩ đại nhất."

Chiến thắng vĩ đại nhất không phải là chiến thắng người khác, mà là chiến thắng chính mình - chiến thắng những tham ái, sân hận và si mê trong tâm mình.

Trong cuộc sống, chúng ta thường cố gắng chứng minh mình giỏi hơn người khác, nhưng điều đó không mang lại hạnh phúc thực sự. Chỉ khi chúng ta có thể làm chủ được những cảm xúc và dục vọng của mình, chúng ta mới có thể sống một cuộc sống hạnh phúc và ý nghĩa.`,
    topicSlugs: ['giai-thoat', 'kinh-dien'],
    keywords: ['chiến thắng', 'chính mình', 'làm chủ', 'hạnh phúc'],
    source: 'Kinh Pháp Cú (Dhammapada) - Câu 103',
    lang: 'vi',
  },
];

(async () => {
  try {
    await connectDB(process.env.MONGO_URI!);
    
    const today = startOfLocalDay();
    console.log(`📅 Today (local): ${today.toISOString()}`);
    
    // Drop old indexes before inserting new data
    try {
      await Reading.collection.dropIndexes();
      await Topic.collection.dropIndexes();
      console.log("🗑️  Dropped old indexes");
    } catch (e: any) {
      console.log("⚠️  No indexes to drop:", e.message);
    }
    
    // Clear existing data
    await Reading.deleteMany({});
    await Topic.deleteMany({});
    console.log("🗑️  Cleared existing data");
    
    // Seed topics
    console.log('\n📝 Seeding authentic Buddhist topics...');
    const insertedTopics = await Topic.insertMany(authenticTopics);
    console.log(`✅ Created ${insertedTopics.length} topics:`);
    insertedTopics.forEach((topic, i) => {
      console.log(`  ${i + 1}. ${topic.name} (${topic.slug})`);
    });

    // Generate readings for multiple days
    console.log('\n📚 Creating authentic Buddhist readings...');
    const readingsToInsert = [];
    
    // Create readings for 90 days (45 days before and after today)
    for (let i = -45; i <= 45; i++) {
      const date = new Date(today.getTime() + i * 86400000);
      
      // Select random reading and topic
      const readingTemplate = authenticReadings[Math.floor(Math.random() * authenticReadings.length)];
      const topicSlugs = readingTemplate.topicSlugs;
      
      const reading = {
        date: startOfLocalDay(date),
        title: readingTemplate.title,
        body: readingTemplate.body,
        topicSlugs: topicSlugs,
        keywords: readingTemplate.keywords,
        source: readingTemplate.source,
        lang: readingTemplate.lang,
      };
      
      readingsToInsert.push(reading);
    }

    const insertedReadings = await Reading.insertMany(readingsToInsert);
    console.log(`✅ Created ${insertedReadings.length} readings`);

    // Update topic reading counts
    console.log('\n📊 Updating topic reading counts...');
    for (const topic of insertedTopics) {
      const count = await Reading.countDocuments({ topicSlugs: topic.slug });
      await Topic.updateOne({ _id: topic._id }, { readingCount: count });
      console.log(`  ${topic.name}: ${count} readings`);
    }

    console.log('\n🎉 SUCCESS! Authentic Buddhist data seeded!');
    console.log('\n📖 Sources included:');
    console.log('  - Kinh Chuyển Pháp Luân (Dhammacakkappavattana Sutta)');
    console.log('  - Kinh Từ Bi (Metta Sutta)');
    console.log('  - Kinh Niệm Xứ (Satipatthana Sutta)');
    console.log('  - Kinh Vô Thường (Anicca Sutta)');
    console.log('  - Kinh Nghiệp (Kamma Sutta)');
    console.log('  - Kinh Giải Thoát (Vimutti Sutta)');
    console.log('  - Kinh Pháp Cú (Dhammapada)');
    
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
})();